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
    
    var categoryData: [[CategoryData]]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        containerTableView.delegate = self;
        fetchUrl(url: Config.API_URL + "hobbycategories/")
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
            print(categoryData.description);
            DispatchQueue.main.async(execute: {() in
                
                self.categoryData = [[CategoryData(id: 0, name: "Pallolajit", treeId: 0, level: 1, parent: 0), CategoryData(id: 0, name: "Pallolajit", treeId: 0, level: 1, parent: 2)], [CategoryData(id: 0, name: "Pallolajit", treeId: 0, level: 1, parent: 0), CategoryData(id: 0, name: "Pallolajit", treeId: 0, level: 1, parent: 2)]]
                
                self.containerTableView.reloadData()
            })
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let data = categoryData else {
            return 0;
        }
        return data.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = categoryData else {
            return 0;
        }
        return data[section].count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    

}
