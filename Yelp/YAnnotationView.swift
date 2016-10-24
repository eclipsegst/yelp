//
//  YAnnotationView.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/22/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import MapKit

class YAnnotationView: MKAnnotationView {
    
    let width = 30.0
    let height = 40.0
    var stackView: UIStackView!
    var imageView: UIImageView!
    var label: UILabel!
    var isOpen: Bool!
    
    var index: Int = 0 {
        didSet {
            self.label.text = String(self.index)
            self.label.font = UIFont.boldSystemFont(ofSize: self.index < 100 ? 14 : 10)
            self.label.sizeToFit()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.canShowCallout = true
        self.isOpen = false
        self.imageView = UIImageView(image: UIImage(named:"annotation_background_red"))
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        
        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.label.numberOfLines = 0
        self.label.textAlignment = .center
        self.label.textColor = .white
        self.label.font = UIFont.boldSystemFont(ofSize: 14)
        
        self.frame = self.imageView.frame
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        self.label.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        self.label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
