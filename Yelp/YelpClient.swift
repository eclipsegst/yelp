//
//  YelpClient.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/17/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import OAuthSwift

class YelpClient: OAuthSwiftClient {
    // Yelp Search API: https://www.yelp.com/developers/documentation/v2/search_api
    
    static let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
    static let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
    static let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
    static let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"
    static let searchBaseURL = "http://api.yelp.com/v2/search"
    
    static let sharedInstance: YelpClient = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, oauthToken: yelpToken, oauthTokenSecret: yelpTokenSecret, version: .oauth1)
    
    func searchWithTerm(_ term: String, location: String?, sort: YelpSortMode?, completion: @escaping ([Business]?, Error?) -> Void) {
        
        return searchWithTerm(term, sort: sort, categories: nil, deals: nil, completion: completion)
    }
    
    func searchWithTerm(_ term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: @escaping ([Business]?, Error?) -> Void) {
        
        // Default the location to San Francisco
        var parameters: [String : AnyObject] = ["term": term as AnyObject, "ll": "37.785771,-122.406165" as AnyObject]
        
        if sort != nil {
            parameters["sort"] = sort!.rawValue as AnyObject?
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject?
        }
        
        if deals != nil {
            parameters["deals_filter"] = deals! as AnyObject?
        }
        
        print(parameters)
        
        self.get(YelpClient.searchBaseURL, parameters: parameters, success: { (data, response) -> Void in
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
