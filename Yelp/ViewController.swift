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
        
        Business.searchWithTerm(term: "food", location: "San+Francisco", sort: .bestMatched, completion: { (businesses, NSError) -> Void in
            print("zhao: \(businesses.count)")
        })
    }
    
}

