//
//  ViewController.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/17/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let params: [String: String] = [
            "location": "San+Francisco",
            "term": "seafood"
        ]
        
        let yelpClient = YelpClient.sharedInstance
        yelpClient.get("http://api.yelp.com/v2/search", parameters: params, success: { (data, response) -> Void in
            guard let responseDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                print("Response cannot be parsed as JSONObject.")
                return
            }
            print(responseDictionary)
        }) { (error) -> Void in
            print("there was an error: \(error)")
        }
        
    }
    
}

