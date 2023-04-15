//
//  PopUpViewController.swift
//  roomfinder
//
//  Created on 3/30/23.
//
import UIKit
import CodeScanner
import SwiftUI

class PopUpViewController: UIViewController{
    
    // storyboard elements
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchContainerView: UIView!

    var searchController: UISearchController!
    var indoorMapViewController: IndoorMapViewController!
    
    @IBSegueAction func scanView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder,
                                   rootView: CodeScannerView(codeTypes: [.qr],  //only scan qr codes
                                            showViewfinder: true,
                                            simulatedData: "Simulated QR Code Read") { response in
            switch response {
            case .success(let result):
                //get text read from qr code (room number)
                let roomread = result.string
                
                //fill out search bar with the scanned code
                self.searchController.searchBar.text = roomread
                
                // annotate the scanned room on the map
                self.indoorMapViewController.filterRooms(searchTerm: roomread)
                
                // return to the map
                self.hide()
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            //above chunk handles if successful or unsuccessful scan and prints it out,
            // can add more within there for roomfinder specific applications
            
            //dismiss the scanning screen when done
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configuration for search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self

        //adding the physical search bar to view
        searchContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.delegate = self
        
        // styling the view
        self.contentView.layer.cornerRadius = 15
        
        // get a reference to the IndoorMapViewController
        let parentResponder: UIResponder? = self.next
        indoorMapViewController = parentResponder as? IndoorMapViewController
    }
    
    //make pop appear whenever it is asked for
    func appear(sender: UIViewController){
        sender.present(self, animated: true){
        }
    }
    
    //hide pop up
    func hide(){
        self.dismiss(animated: true)
        self.removeFromParent()
    }
}

extension PopUpViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text{
            if(searchText != ""){

            }
        }
    }
}

extension PopUpViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // get the text from the search bar
        if let searchText = searchBar.text {
            // add a bubble to the map
            indoorMapViewController.filterRooms(searchTerm: searchText)
        }
        
        // hide the pop up
        searchController.isActive = false
        hide()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false

        if let searchText = searchBar.text, !searchText.isEmpty {
            
        }
    }
}
