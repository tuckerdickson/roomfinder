/*
 
 IndoorMapViewController.swift
 roomfindr
 This file controls the map view.
 Created on 2/25/23.
 
 */

import UIKit
import CoreLocation
import MapKit
import CodeScanner
import SwiftUI

/// Controls the map view.
class IndoorMapViewController: UIViewController, UISearchBarDelegate, LevelPickerDelegate {
    
    // storyboard elements
    @IBOutlet var mapView: MKMapView!                           // the map background
    @IBOutlet weak var searchBar: UISearchBar!                  // the search bar on the map
    @IBOutlet weak var errorMessage: UILabel!                   // the message that appears on bad queries
    @IBOutlet weak var getDirectionsButton: UIButton!           // the blue get directions button
    @IBOutlet var levelPicker: LevelPickerView!                 // the level picker
        
    var venue: Venue?                                           // object of type Venue; represents Seamans Center
    private var levels: [Level] = []                            // levels of Seamans Center
    
    private var currentLevelFeatures = [StylableFeature]()      // features of the current level
    private var currentLevelOverlays = [MKOverlay]()            // overlays of the current level
    private var currentLevelAnnotations = [MKAnnotation]()      // annotations of the current level
    
    let pointAnnotationViewIdentifier = "PointAnnotationView"
    let labelAnnotationViewIdentifier = "LabelAnnotationView"
        
    var floorOptions: [Int] = [1,2,3]
    var currentDataSource: [String] = []
    var filterOptions: [String] = ["office", "lab", "library",
                                   "classroom", "conference",
                                   "auditorium", "restroom",
                                   "elevator", "stairs"]

    var searchFrame: CGRect!                                    // original position of search bar (before offsetting)
    var errorFrame: CGRect!                                     // original position of error message (before offsetting)
    
    private let locationManager = CLLocationManager()           // TODO: figure out if we want to scrap blue dot
    
    //on qr button click, show qr scanner
    @IBSegueAction func scanView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder,
                                   rootView: CodeScannerView(codeTypes: [.qr],  //only scan qr codes
                                                             showViewfinder: true,
                                                             simulatedData: "Simulated QR Code Read") { response in
            switch response {
            case .success(let result):
                //get text read from qr code (room number)
                let roomread = result.string
                print("Found code: \(roomread)")
                //fill out search bar with the scanned code
                self.searchBar.text = roomread
                self.filterRooms(searchTerm: roomread)
                
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            //above chunk handles if successful or unsuccessful scan and prints it out,
            // can add more within there for roomfinder specific applications
            
            //dismiss the scanning screen when done
            self.dismiss(animated: true, completion: nil)
        })}
    
    
    @IBSegueAction func directionsButtonTapped(_ coder: NSCoder) -> PopUpViewController? {
        return PopUpViewController(coder: coder)
    }
    
    /// Gets called everytime this view is loaded (e.g. when the app is opened).
    override func viewDidLoad() {
        super.viewDidLoad()
        let nodes = NodeManager().parse()
        EdgeManager().parse(nodes: nodes)
        
        var path: [Simple2DNode] = []
        path = EdgeManager().pathFind(to: nodes.1[3], from: nodes.1[0])
        print(path)
        for node in path{
            let roomIndex = nodes.1.firstIndex(of: node)!
            print(node.position)
            print(nodes.0[roomIndex])
        }
        
        // request location authorization from the user
        locationManager.requestWhenInUseAuthorization()

        // set the mapView delegate to self so that we can use mapView delegate methods (below)
        self.mapView.delegate = self
        
        // tell mapView that PointAnnotationView & LabelAnnotationView will be used to display points and annotation on map
        self.mapView.register(PointAnnotationView.self, forAnnotationViewWithReuseIdentifier: pointAnnotationViewIdentifier)
        self.mapView.register(LabelAnnotationView.self, forAnnotationViewWithReuseIdentifier: labelAnnotationViewIdentifier)

        // decode the IMDF archive
        let imdfDirectory = Bundle.main.resourceURL!.appendingPathComponent("IMDFData")
        do {
            let imdfDecoder = IMDFDecoder()
            venue = try imdfDecoder.decode(imdfDirectory)
        } catch let error {
            print(error)
        }
        
        // You might have multiple levels per ordinal. A selected level picker item displays all levels with the same ordinal.
        if let levelsByOrdinal = self.venue?.levelsByOrdinal {
            let levels = levelsByOrdinal.mapValues { (levels: [Level]) -> [Level] in
                // Choose indoor level over outdoor level
                if let level = levels.first(where: { $0.properties.outdoor == false }) {
                    return [level]
                } else {
                    return [levels.first!]
                }
            }.flatMap({ $0.value })
            
            // Sort levels by their ordinal numbers
            self.levels = levels.sorted(by: { $0.properties.ordinal > $1.properties.ordinal })
        }
        
        // Set the map view's region to enclose the venue
        if let venue = venue, let venueOverlay = venue.geometry[0] as? MKOverlay {
            self.mapView.setVisibleMapRect(venueOverlay.boundingMapRect, edgePadding:
                UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        }

        // Display a default level at start, for example a level with ordinal 0
        showFeaturesForOrdinal(0)
        
        // Setup the level picker with the shortName of each level
        setupLevelPicker()
        
        // set the properties of the search bar
        searchBar.delegate = self
        searchBar.showsBookmarkButton = true
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Where do you want to go?"
        searchBar.setImage(UIImage(systemName: "qrcode.viewfinder"), for: .bookmark, state: .normal)
        
        // record the positions of the search bar and error message, for reuse later
        searchFrame = searchBar.frame
        errorFrame = errorMessage.frame
        

        // when the keyboard is opened, call the keyBoardWillShow function
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        // when the keyboard is closed, call the keyBoardWillHide function
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyBoardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        // configure the get directions button; make it invisible to start
        self.getDirectionsButton.layer.cornerRadius = 20
        getDirectionsButton.isEnabled = false
        getDirectionsButton.isHidden = true
        
        // configure the keyboard to be dismissed when tapping off of it
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIInputViewController.dismissKeyboard)
        )
        self.view.addGestureRecognizer(tap)
    }
    
    /// Displays the features for the current ordinal.
    /// - Parameter ordinal: An Int representing the current level.
    private func showFeaturesForOrdinal(_ ordinal: Int) {
        // guard against nil venue
        guard self.venue != nil else {
            return
        }

        // clear the previous level's geometry from the map
        self.mapView.removeOverlays(self.currentLevelOverlays)
        self.mapView.removeAnnotations(self.currentLevelAnnotations)
        self.currentLevelFeatures.removeAll()
        self.currentLevelAnnotations.removeAll()
        self.currentLevelOverlays.removeAll()

        // coalesce the unit and opening geometries, as well as the occupant and amenity annotation
        if let levels = self.venue?.levelsByOrdinal[ordinal] {
            for level in levels {
                self.currentLevelFeatures.append(level)
                self.currentLevelFeatures += level.units
                self.currentLevelFeatures += level.openings
                
                let occupants = level.units.flatMap({ $0.occupants })
                let amenities = level.units.flatMap({ $0.amenities })
                
                self.currentLevelAnnotations += occupants
                self.currentLevelAnnotations += amenities
            }
        }
        
        // overlay the geometries from above
        let currentLevelGeometry = self.currentLevelFeatures.flatMap({ $0.geometry })
        self.currentLevelOverlays = currentLevelGeometry.compactMap({ $0 as? MKOverlay })

        // add geometries and annotations to the map
        self.mapView.addOverlays(self.currentLevelOverlays)
        self.mapView.addAnnotations(self.currentLevelAnnotations)
    }
    
    /// Sets up the level-picker in the map view.
    private func setupLevelPicker() {
        // use the levels' short names to display on the level-picker
        self.levelPicker.levelNames = self.levels.map {
            if let shortName = $0.properties.shortName.bestLocalizedValue {
                return shortName
            } else {
                return "\($0.properties.ordinal)"
            }
        }
        
        // begin by displaying the level-specific information for ordinal 0
        if let baseLevel = levels.first(where: { $0.properties.ordinal == 0 }) {
            levelPicker.selectedIndex = self.levels.firstIndex(of: baseLevel)!
        }
    }
    
    /// Gets called when the user changes levels with the level-picker. Sets in motion the changes to the map that take place when this happens.
    func selectedLevelDidChange(selectedIndex: Int) {
        // ensure selectedIndex is in appropriate range
        precondition(selectedIndex >= 0 && selectedIndex < self.levels.count)
        
        // select the appropriate level and update the features to reflect it
        let selectedLevel = self.levels[selectedIndex]
        showFeaturesForOrdinal(selectedLevel.properties.ordinal)
    }
    
    func filterRooms(searchTerm: String) {
        if(searchTerm != "") {
            if(searchTerm.first!.wholeNumberValue == nil){
                if(filterOptions.contains(searchTerm.lowercased())){
                    let allAnnotations = self.mapView.annotations
                    self.mapView.removeAnnotations(allAnnotations)
                    for occupant in self.currentLevelAnnotations{
                        if(occupant.subtitle!! == searchTerm){
                            self.mapView.addAnnotation(occupant)
                        }
                    }
                    errorMessage.isHidden = true
                }
                else{
                    //show pop up that nothing was found
                    errorMessage.isHidden = false
                }
            }
            else{
                if (floorOptions.contains(searchTerm.first!.wholeNumberValue!) && (levelPicker.selectedIndex != floorOptions.count - searchTerm.first!.wholeNumberValue!)) {
                    //showFeaturesForOrdinal(searchText.first!.wholeNumberValue! - 2)
                    selectedLevelDidChange(selectedIndex: floorOptions.count - searchTerm.first!.wholeNumberValue!)
                    levelPicker.selectedIndex = floorOptions.count - searchTerm.first!.wholeNumberValue!
                }
                
                for occupant in self.currentLevelAnnotations{
                    if(occupant.title!! == searchTerm){
                        self.mapView.selectAnnotation(occupant, animated: true)
                        getDirectionsButton.isEnabled = true
                        getDirectionsButton.isHidden = false
                        errorMessage.isHidden = true
                        break
                    }
                    else{
                        //show that no room was found
                        errorMessage.isHidden = false
                    }
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        if(searchBar.searchTextField.text == "") {
            getDirectionsButton.isEnabled = false
            getDirectionsButton.isHidden = true
            errorMessage.isHidden = true
            
            //deselect all annotations when cancel button is clicked
            let selectedAnnotations = self.mapView.selectedAnnotations
            for annotation in selectedAnnotations{
                self.mapView.deselectAnnotation(annotation, animated: true)
            }
            
            //add back all dots
            self.mapView.addAnnotations(self.currentLevelAnnotations)
        }
        searchBar.resignFirstResponder()
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        if let keyBoardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            searchBar.frame = searchBar.frame.offsetBy(dx: 0, dy: -2 * keyBoardSize.height / 3)
            errorMessage.frame = errorMessage.frame.offsetBy(dx: 0, dy: -2 * keyBoardSize.height / 3)
        }
    }

    @objc func keyBoardWillHide(notification: NSNotification) {
        searchBar.frame = searchFrame
        errorMessage.frame = errorFrame
    }
}

extension IndoorMapViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text{
            if (searchText == "") {
                //hide get directions button
                getDirectionsButton.isEnabled = false
                getDirectionsButton.isHidden = true

                //deselect all annotations when cancel button is clicked
                let selectedAnnotations = self.mapView.selectedAnnotations
                for annotation in selectedAnnotations{
                    self.mapView.deselectAnnotation(annotation, animated: true)
                }

                //add back all dots
                self.mapView.addAnnotations(self.currentLevelAnnotations)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            filterRooms(searchTerm: searchText)
        }
        dismissKeyboard()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        performSegue(withIdentifier: "scanViewSegue", sender: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //deselect all annotations when cancel button is clicked
        let selectedAnnotations = self.mapView.selectedAnnotations
        for annotation in selectedAnnotations{
            self.mapView.deselectAnnotation(annotation, animated: true)
        }
        
        if let searchText = searchBar.text, !searchText.isEmpty {
            
        }
    }
}


// MKMapView delegate methods
extension IndoorMapViewController: MKMapViewDelegate {
    /// Paraphrasing Apple's Documentation: Provides an appropriate renderer object for our overlays. This renderer object is responsible for drawing the contents of the overlay when the map view requests.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // extract geometry and features from the overlay
        guard let shape = overlay as? (MKShape & MKGeoJSONObject),
            let feature = currentLevelFeatures.first( where: { $0.geometry.contains( where: { $0 == shape }) }) else {
            return MKOverlayRenderer(overlay: overlay)
        }

        // determine the appropriate renderer for the overlay
        let renderer: MKOverlayPathRenderer
        switch overlay {
        case is MKMultiPolygon:
            renderer = MKMultiPolygonRenderer(overlay: overlay)
        case is MKPolygon:
            renderer = MKPolygonRenderer(overlay: overlay)
        case is MKMultiPolyline:
            renderer = MKMultiPolylineRenderer(overlay: overlay)
        case is MKPolyline:
            renderer = MKPolylineRenderer(overlay: overlay)
        default:
            return MKOverlayRenderer(overlay: overlay)
        }

        // configure the renderer's display properties in feature-specific ways.
        feature.configure(overlayRenderer: renderer)
        return renderer
    }

    /// From Apple's Documentation: returns the view associated with the specified annotation object.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // return if the annotation in question is the user's mark
        if annotation is MKUserLocation {
            return nil
        }

        // return an annotation view depending on what annotation is
        if let stylableFeature = annotation as? StylableFeature {
            if stylableFeature is Occupant {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: labelAnnotationViewIdentifier, for: annotation)
                stylableFeature.configure(annotationView: annotationView)
                return annotationView
            } else {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointAnnotationViewIdentifier, for: annotation)
                stylableFeature.configure(annotationView: annotationView)
                return annotationView
            }
        }

        return nil
    }
}
