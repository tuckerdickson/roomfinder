//
//  PopUpViewController.swift
//  roomfinder
//
//  Created by Cathryn Lyons on 3/30/23.
//  Copyright © 2023 Apple. All rights reserved.
//
import UIKit
import CodeScanner
import SwiftUI

class PopUpViewController: UIViewController {
    
    var searchController: UISearchController!
    
    @IBOutlet weak var searchContainerView: UIView!

    @IBOutlet var contentView: UIView!
    
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
                self.searchController.searchBar.text = roomread
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            //above chunk handles if successful or unsuccessful scan and prints it out,
            // can add more within there for roomfinder specific applications
            
            //dismiss the scanning screen when done
            self.dismiss(animated: true, completion: nil)
        })}
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentView.layer.cornerRadius = 15
        
        //configuration for search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
        //adding the physical search bar to view
        searchContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.delegate = self
        

        
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
                //insert action here
            }
        }
    }
}

extension PopUpViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        
        if let searchText = searchBar.text {
            //insert action here
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false

        if let searchText = searchBar.text, !searchText.isEmpty {
            
        }
    }
}
