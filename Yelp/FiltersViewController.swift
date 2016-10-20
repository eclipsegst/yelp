//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Zhaolong Zhong on 10/19/16.
//  Copyright © 2016 Zhaolong Zhong. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: AnyObject])
}
class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet var tableView: UITableView!
    
    let switchCell = "SwitchCell"
    var categories: [[String: String]]?
    var switchStates = [Int: Bool]()
    weak var delegate: FiltersViewControllerDelegate?
    
    let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "Yelp"
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let getCategoriesOperation = BlockOperation {
            let data = YelpHelper.readFileFrom("Categories", ofType: "json")
            
            guard let categoriesDict = try! JSONSerialization.jsonObject(with: data!, options: []) as? [[String: String]] else {
                print("Error in getting categories.")
                return
            }
            
            OperationQueue.main.addOperation {
                self.categories = categoriesDict
                self.invalidateViews()
            }
        }
        
        self.operationQueue.addOperation(getCategoriesOperation)
        
        // Set up table view
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: self.switchCell, bundle: nil), forCellReuseIdentifier: self.switchCell)

    }
    
    func invalidateViews() {
        if self.isViewLoaded {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearchButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
        
        var filters = [String: AnyObject]()
        
        var selectedCategories = [String]()
        for (row, isOn) in switchStates {
            if isOn {
                selectedCategories.append(self.categories![row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        
        self.delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.switchCell) as! SwitchCell
        
        cell.delegate = self
        cell.switchLabel.text = self.categories?[indexPath.row]["name"]
        cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
        
        return cell
    }
    
    // MARK: - SwitchCellDelegate
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = self.tableView.indexPath(for: switchCell)!
        print("\(indexPath.row) : \(value)" )
        
        self.switchStates[indexPath.row] = value
    }
}
