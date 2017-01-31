//
//  Constants.swift
//  GooglePlacesAPI-DEMO
//
//  Created by Nasrullah Khan on 31/01/2017.
//  Copyright © 2017 Nasrullah Khan. All rights reserved.
//

import Foundation
import MapKit

class GooglePlacesServices {
    
    static let placesKey = "AIzaSyDi8gT_MQFe-9W3Jm6LUZTktd3fiyrYeP0"
    
    /**
     The function is used to get the json from google maps web services apis.
     - parameter address: the address to search from google apis.
     - parameter completion: callback.
     */
    static func getPlacesFromGoogleAPI(_ address: String, completion: @escaping (_ places: [MKMapItem]?) -> Void){
        
        let reference = "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=\(address)&key=\(self.placesKey)"
        
        let url = URL(string: reference)
        
        if url == nil {
            completion(nil)
            return
        }
        
        // 1 : HTTP Rquest
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            // 2 : Response
            if data != nil {
                
                // 3 : parse json data
                parseQueryPlacesFromData(data!, completion: { (places) -> Void in
                    if places.count > 0 {
                        
                        // 4 : finally callback places
                        completion(places)
                    }else{
                        completion(nil)
                    }
                })
            }else{
                completion(nil)
            }
        })
        task.resume()
    }
    
    /**
     The function is used to parse the json data.
     - parameter data: the data to parse.
     - parameter completion: callback.
     */
    static func parseQueryPlacesFromData(_ data : Data, completion: @escaping (_ places: [MKMapItem])->Void) {
        
        var mapItems = [MKMapItem]()
        
        do{
            // 1 : Convert json data to NSDictionary
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            let results = json["predictions"] as? Array<NSDictionary>
            
            if results!.count < 1 { completion(mapItems) }
            
            // 2 : Iterate the results
            for result in results! {
                
                var description = result["description"] as? String
                
                if description == nil { description = "" }
                
                if let placeID = result["place_id"] as? String {
                    
                    // 3 : Get detail using Places ID
                    self.getDetailPlaceFromPlaceID(placeID, completion: { (place) -> Void in
                        
                        if place != nil {
                            mapItems.append(place!)
                        }
                        
                        // 4 : callback
                        completion(mapItems)
                    })
                }
            }
            
        }catch{
            
        }
    }
    
    /**
     The function is used to get the detail using places and parse that json details.
     - parameter placeID: the place id, which will be used to get the detail.
     - parameter completion: callback.
     */
    static func getDetailPlaceFromPlaceID(_ placeID: String, completion: @escaping (_ place: MKMapItem?) -> Void){
        
        let reference = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&key=\(self.placesKey)"
        
        let url = URL(string: reference)
        
        if url == nil {
            completion(nil)
            return
        }
        
        // 1 : HTTP Rquest
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            // 2 : Response
            if data != nil {
                
                do{
                    // 3 : Convert json data to NSDictionary
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    // 4 : parse json data
                    if let result = json["result"] as? [String: AnyObject] {
                        
                        var coordinate : CLLocationCoordinate2D!
                        
                        if let geometry = result["geometry"] as? NSDictionary {
                            if let location = geometry["location"] as? NSDictionary {
                                let lat = location["lat"] as? CLLocationDegrees
                                let long = location["lng"] as? CLLocationDegrees
                                coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                                
                                let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                                let mapItem = MKMapItem(placemark: placemark)
                                
                                if let name = result["name"] as? String{
                                    
                                    if let formattedAddress = result["formatted_address"] as? String{
                                        mapItem.name = "\(name), \(formattedAddress)"
                                    }
                                }
                                
                                // 5 : callback the parsed data
                                completion(mapItem)
                                return
                            }
                        }
                    }
                }catch{
                    
                }
            }
            
            completion(nil)
            
        })
        
        // 5
        task.resume()
        
    }
    
}
