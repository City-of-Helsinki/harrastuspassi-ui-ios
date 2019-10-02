//
//  CategoryFilterTableView.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 14/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class CategoryFilterTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var categoryData: [CategoryData]?

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = categoryData {
            return data.count
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryFilterCell", for: indexPath) as! CategoryFilterTableViewCell
        
        print("Setting cell for:")
        if let data = categoryData {
            cell.setCategory(category: data[indexPath.row]);
            cell.selectionStyle = .none;
        }
        return cell
    }
    
}
