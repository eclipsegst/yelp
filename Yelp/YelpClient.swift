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
    
    static let sharedInstance: YelpClient = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, oauthToken: yelpToken, oauthTokenSecret: yelpTokenSecret, version: .oauth1)

}
