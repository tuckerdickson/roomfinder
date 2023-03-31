//
//  PopUpViewController.swift
//  roomfinder
//
//  Created by Cathryn Lyons on 3/30/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    var searchController: UISearchController!
    
    @IBOutlet weak var sourceContainerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    //called when cancel button is clicked
    @IBAction func cancelButtonTapped(_ sender: Any) {
        hide()
    }
    
    //inits
    init(){
        super.init(nibName: "PopUpViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentView.layer.cornerRadius = 15
        
        //configuration for search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
//        searchController.obscuresBackgroundDuringPresentation = false
        //adding the physical search bar to view
        sourceContainerView.addSubview(searchController.searchBar)
        searchController.searchBar.delegate = self
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: 286, height: 55)
        searchController.width
        

        
    }
    
    //make pop appear whenever it is asked for
    func appear(sender: UIViewController){
        sender.present(self, animated: false){
        }
    }
    
    //hide pop up
    func hide(){
        self.dismiss(animated: false)
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
