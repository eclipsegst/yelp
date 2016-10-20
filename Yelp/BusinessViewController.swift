//
//  ViewController.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/17/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

class BusinessViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {

    @IBOutlet var tableView: UITableView!
    
    let businessCell = "BusinessCell"
    
    var searchText: String = "" {
        didSet {
            print("search text: \(self.searchText)")
            if self.searchText == oldValue {
                return
            }
            
            Business.searchWithTerm(term: self.searchText, location: "San+Francisco", sort: .bestMatched, completion: { (businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
            })
        }
    }
    var businesses: [Business]? {
        didSet {
            print("business count:\(self.businesses?.count)")
            invalidateViews()
        }
    }
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: self.businessCell, bundle: nil), forCellReuseIdentifier: self.businessCell)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        
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
        
        Business.searchWithTerm(term: "food", location: "San+Francisco", sort: .bestMatched, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
        })
    }
    
    func invalidateViews() {
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.businessCell, for: indexPath) as! BusinessCell
        
        let business = self.businesses![indexPath.row]
        cell.business = business
        cell.nameLabel.text = "\(indexPath.row + 1). \(business.name!)"
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }

    // MARK: - FiltersViewControllerDelegate
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        let categories = filters["categories"] as? [String]
        print(categories?.count)
        
        Business.searchWithTerm(term: "Restaurant", sort: nil, categories: categories, deals: nil, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
        })
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
//        self.searchText = searchController.searchBar.text!
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchBar.showsCancelButton = false
    }
    
}

