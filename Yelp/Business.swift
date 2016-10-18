//
//  Business.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/17/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import OAuthSwift

class Business: NSObject {
    var name: String?
    var address: String?
    var imageURL: NSURL?
    var categories: String?
    var distance: String?
    var ratingImageURL: NSURL?
    var reviewCount: NSNumber?
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
        } else {
            imageURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }
        }
        self.address = address
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joined(separator: ", ")
        } else {
            categories = nil
        }
        
        let distanceMeters = dictionary["distance"] as? NSNumber
        if distanceMeters != nil {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    static func businesses(array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        
        return businesses
    }
    
    static func searchWithTerm(term: String?, location: String?, sort: YelpSortMode?, completion: @escaping ([Business], NSError?) -> Void) {
        let yelpClient = YelpClient.sharedInstance

        var params: [String: AnyObject] = [:]
        if term != nil && term!.characters.count > 0 {
            params["term"] = term! as AnyObject?
        } else {
            params["term"] = "food" as AnyObject
        }
        
        if location != nil && location!.characters.count > 0 {
            params["location"] = location as AnyObject
        } else {
            params["location"] = "San+Francisco" as AnyObject
        }
        
        yelpClient.get("http://api.yelp.com/v2/search", parameters: params, success: { (data, response) -> Void in
            guard let response = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                print("Response cannot be parsed as JSONObject.")
                return
            }
            
            let dictionaries = response["businesses"] as? [NSDictionary]
            if dictionaries != nil {
                completion(Business.businesses(array: dictionaries!), nil)
            }
        }) { (error) -> Void in
            print("there was an error: \(error)")
        }
    }

}
