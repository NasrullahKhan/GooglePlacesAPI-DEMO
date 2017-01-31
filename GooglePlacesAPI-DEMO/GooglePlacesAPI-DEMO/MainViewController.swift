//
//  ViewController.swift
//  GooglePlacesAPI-DEMO
//
//  Created by Nasrullah Khan on 30/01/2017.
//  Copyright © 2017 Nasrullah Khan. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchBarField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchedPlaces = [MKMapItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     The function is used to call the services.
     - parameter address: this will get the text from search field.
     */
    func getSearchPlaces(address: String) {
        
        self.searchedPlaces = [MKMapItem]() // reset
        self.tableView.reloadData()
        
        GooglePlacesServices.getPlacesFromGoogleAPI(address) { (places) in
            
            // Background Thread
            DispatchQueue.global(qos: .default).async {
                
                let deadline = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                
                // Main Thread
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    
                    if places != nil {
                        
                        self.searchedPlaces = places!
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: Searbar Delegates method
extension MainViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.getSearchPlaces(address: searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: TableView Delegates and Datasource method
extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        let place = self.searchedPlaces[(indexPath as NSIndexPath).row]
        
        var displayName = String()
        
        if place.name != nil {
            displayName = "\(place.name!)"
        }
        
        cell.textLabel?.text = displayName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.searchedPlaces[indexPath.row]
        self.showAlert(title: place.name!, details: "placemark: \(place.placemark)")

    }
}


