//
//  SearchViewController.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/22/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, FiltersViewControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, BusinessViewControllerDelegate, CLLocationManagerDelegate {
    
    static let TAG = NSStringFromClass(SearchViewController.self)

    @IBOutlet var containerView: UIView!
    @IBOutlet var rightBarButtonItem: UIBarButtonItem!
    
    var businessViewController: BusinessViewController!
    var mapViewController: MapViewController!
    var toShowMap = true
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation? {
        didSet {
            reloadBusinesses()
        }
    }
    
    var searchText: String = "" {
        didSet {
            print("search text: \(self.searchText)")
            if self.searchText == oldValue {
                return
            }
            
            self.businessViewController.searchText = self.searchText
            reloadBusinesses()
        }
    }
    
    var filters: [Filter] = [] {
        didSet {
            reloadBusinesses()
        }
    }
    
    var businesses: [Business] = [] {
        didSet {
            print("\(SearchViewController.TAG) - businesses didSet: \(businesses.count)")
            
            self.businessViewController.businesses = self.businesses
            self.mapViewController.businesses = self.businesses
        }
    }
    
    var searchController: UISearchController!
    var rightBarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        self.businessViewController = mainStoryBoard.instantiateViewController(withIdentifier: "BusinessViewController") as! BusinessViewController
        self.businessViewController.delegate = self
        self.mapViewController = mainStoryBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        
        self.businessViewController.view.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width, height: self.containerView.frame.size.height);
        self.containerView.addSubview(businessViewController.view)
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.searchBar.showsCancelButton = false
        definesPresentationContext = true
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = self.searchController.searchBar
        
        rightBarButton = UIButton(type: .custom)
        rightBarButton.frame = CGRect(x: 0, y: 0, width: 36, height: 30)
        rightBarButton.setTitle(self.toShowMap ? "Map" : "List", for: .normal)
        rightBarButton.setTitleColor(.gray, for: .highlighted)
        rightBarButton.tintColor = .white
        rightBarButton.addTarget(self, action: #selector(mapButtonClicked), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
        
        setUpLocationManager()
    }
    
    // MARK: - Set up location manager
    func setUpLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            let alertController = UIAlertController(title: "Are you a ninja?", message: "Your location can't be found. Yelp works best if you allow location permissions. Go to Settings?", preferredStyle: .alert)
            let actionSheet = UIAlertAction(title: "Ok", style: .default, handler:{ (action) -> Void in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            })
            alertController.addAction(actionSheet)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func mapButtonClicked() {
        if toShowMap {
            UIView.transition(from: self.businessViewController.view, to: self.mapViewController.view, duration: 0.8, options: .transitionFlipFromRight, completion: nil)
            self.toShowMap = false
        } else {
            UIView.transition(from: self.mapViewController.view, to: self.businessViewController.view, duration: 0.8, options: .transitionFlipFromLeft, completion: nil)
            self.toShowMap = true
        }
        
        rightBarButton.setTitle(self.toShowMap ? "Map" : "List", for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    // MARK: - FiltersViewControllerDelegate
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [Filter]) {
        
        for filter in filters {
            print(filter.name)
            print(filter.selectedOptions.count)
        }
        
        self.filters = filters
    }

    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        print("search button clicked")
        self.searchText = searchBar.text ?? ""
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("cancel button clicked")

    }

    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        self.searchText = searchController.searchBar.text!
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchBar.showsCancelButton = false
    }
    
    func businessViewController(businessViewController: BusinessViewController, loadMoreData: Bool) {
        loadMoreBusinesses()
    }
    
    func reloadBusinesses() {
        Business.searchWithTerm(term: self.searchText, filters: self.filters, offset: 0, completion: { (businesses: [Business]?, error: Error?) -> Void in
            if businesses != nil {
                self.businesses.removeAll()
                self.businesses.append(contentsOf: businesses!)
            }
        })
    }
    
    func loadMoreBusinesses() {
        Business.searchWithTerm(term: self.searchText, filters: self.filters, offset: self.businesses.count, completion: { (businesses: [Business]?, error: Error?) -> Void in
            if businesses != nil {
                self.businesses.append(contentsOf: businesses!)
            }
        })
    }
    
    // MARK - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("\(SearchViewController.TAG) - location updated: \(manager.location)")
        
        guard let currentLocation = manager.location else {
            return
        }
        
        if self.currentLocation == nil || (self.currentLocation?.distance(from: currentLocation))! > CLLocationDistance(20.0) {
            self.currentLocation = currentLocation
            let defaults = UserDefaults.standard
            defaults.set(currentLocation.coordinate.latitude, forKey: YLocation.latitudeKey)
            defaults.set(currentLocation.coordinate.longitude, forKey: YLocation.longitudeKey)
            defaults.synchronize()
        }

        manager.stopUpdatingLocation()
    }
    
}
