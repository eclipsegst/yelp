//
//  MapViewController.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/22/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    static let TAG = NSStringFromClass(MapViewController.self)
    
    @IBOutlet var mapView: MKMapView!
    
    let metersPerMile: Double = 1609.344
    
    var businesses: [Business] = [] {
        didSet {
            print("businesses didSet in map: \(self.businesses.count)")
            invalidateViews()
        }
    }
    var annotations: [MKAnnotation] = []
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest


        let span = MKCoordinateSpanMake(0.2, 0.2)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: YLocation.getDefaultLocation().coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        invalidateViews()
    }
    
    func invalidateViews() {
        self.annotations.removeAll()
        for i in 0..<self.businesses.count {
            let business = self.businesses[i]
            let newAnnotation = YAnnotation(business: business, index: i + 1)
            self.annotations.append(newAnnotation)
        }
        
        if (self.viewIfLoaded != nil) {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let yAnnotation = annotation as? YAnnotation else {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier:\(yAnnotation.coordinate)"
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? YAnnotationView {
            return annotationView
        }
        
        let annotationView = YAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        annotationView.index = yAnnotation.index
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
    }

    // MARK - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            self.mapView.showsUserLocation = true
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.currentLocation == nil {
            self.currentLocation = manager.location
        }
        
        manager.stopUpdatingLocation()
    }

}
