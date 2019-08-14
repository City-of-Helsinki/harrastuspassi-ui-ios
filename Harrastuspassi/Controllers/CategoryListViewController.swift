//
//  CategoryListViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 09/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class CategoryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var containerTableView: UITableView!
    var categoryData: [CategoryData]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerTableView.dataSource = self;
        containerTableView.delegate = self;
        fetchUrl(url: Config.API_URL + "hobbycategories/?include=child_categories&parent=null")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchUrl(url: String) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url : URL? = URL(string: url)
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
        
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let categoryData = try? JSONDecoder().decode([CategoryData].self, from: fetchedData)
                else {
                    return
            }
            print(categoryData);
            DispatchQueue.main.async(execute: {() in
                self.categoryData = categoryData
                
                self.containerTableView.reloadData()
            })
        }
    }
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let subvc = segue.destination as? SubCategoryListController,
            let index = containerTableView.indexPathForSelectedRow?.row
            else {
                return
        }
        if let data = categoryData {
            subvc.data = data[index].childCategories
            subvc.navigationItem.title = data[index].name
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
