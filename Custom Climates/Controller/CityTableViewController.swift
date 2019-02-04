//
//  CityTableViewController.swift
//  Custom Climates
//
//  Created by Phillip Badenhorst on 26/1/2019.
//  Copyright © 2019 Phillip Badenhorst. All rights reserved.
//

import UIKit
import CoreData

class CityTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var cityArray: Array<City> = []
    
//    @IBAction func addCity(_ sender: Any) {
//        var textField = UITextField()
//        let alert = UIAlertController(title: "Add New City", message: "", preferredStyle: .alert)
//        let action = UIAlertAction(title: "Add", style: .default) { (action) in
//            let newCity = City(context: self.context)
//            newCity.title = textField.text!
////            newCity.lat = 
////            newCity.lon =
//            self.cityArray.append(newCity)
//            self.saveItems()
//            
//        }
//        alert.addTextField { (alertTextField) in
//            alertTextField.placeholder = "Create new city"
//            textField = alertTextField
//        }
//        alert.addAction(action)
//        present(alert, animated: true, completion: nil)
//    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityArray.count
    }

    func saveItems(city: City) {
        do {
            try self.context.save()
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    @IBAction func addCityButton(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New City", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCity = City()
            newCity.title = textField.text!
            self.saveItems(city: newCity)
        }
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new city"
        }
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CityTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
