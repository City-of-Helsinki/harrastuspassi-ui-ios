//
//  CategoryFilterSubCategoryListView.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 14/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class SubCategoryListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tableView: CategoryFilterTableView!
    

    var data: [CategoryData]?
    weak var selectionDelegate: SelectionDelegate?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let d = data {
            print(d)
            return d.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! CategoryFilterTableViewCell
        
        print("Setting cell for:")
        if let d = data {
            cell.setCategory(category: d[indexPath.row]);
            cell.selectionStyle = .none;
            if d[indexPath.row].childCategories?.count == 0 {
                cell.accessoryType = .none
            }
            if let delegate = selectionDelegate, let id = d[indexPath.row].id {
                if delegate.selectedItems.contains(id) {
                    print("selected")
                    cell.categorySelected = true
                }
            }
            cell.selectionDelegate = self.selectionDelegate
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let subvc = segue.destination as? SubCategoryListController,
            let index = tableView.indexPathForSelectedRow?.row
            else {
                return
        }
        if let d = data {
            subvc.data = d[index].childCategories
            subvc.selectionDelegate = self.selectionDelegate
            subvc.navigationItem.title = d[index].name
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showSub" {
            let index = tableView.indexPathForSelectedRow?.row
            if let i = index, let d = data, let cg = d[i].childCategories, cg.count == 0 {
                return false
            }
        }
        return true
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        self.selectionDelegate?.saveFiltersAndDismiss();
    }
}
