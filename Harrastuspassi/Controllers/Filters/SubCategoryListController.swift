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
    let cellSpacingHeight: CGFloat = 10
    

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
    
        
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
//        if let d = data {
//            print(d)
//            return d.count
//        } else {
//            return 0
//        }
//    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if let d = data {
            return d.count
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! CategoryFilterTableViewCell
        
        print("Setting cell for:")
        if let d = data {
            cell.setCategory(category: d[indexPath.section]);
            cell.selectionStyle = .none;
            if d[indexPath.section].childCategories?.count == 0 {
                cell.accessoryType = .none
            }
            if let delegate = selectionDelegate, let id = d[indexPath.section].id {
                if delegate.selectedItems.contains(id) {
                    print("selected")
                    cell.categorySelected = true
                }
            }
            cell.selectionDelegate = self.selectionDelegate
        }
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let subvc = segue.destination as? SubCategoryListController,
            let index = tableView.indexPathForSelectedRow?.section
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
            let index = tableView.indexPathForSelectedRow?.section
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
