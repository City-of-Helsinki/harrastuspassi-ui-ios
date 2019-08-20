//
//  FilterViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 08/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ModalDelegate {
    
    
    
    var categories: Dictionary<Int, CategoryData>?;
    var selectedCategories: [Int] = [];
    var modalDelegate: ModalDelegate?
    
    @IBOutlet weak var selectedCategoriesContainer: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        if let selectedCategories = UserDefaults.standard.array(forKey: DefaultKeys.Filters.categories) as? [Int] {
            self.selectedCategories = selectedCategories
        }
        fetchUrl(url: Config.API_URL + "hobbycategories/")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        collectionView.reloadData();
        setCollectionViewHeight();
        selectedCategoriesContainer.setNeedsLayout();
        selectedCategoriesContainer.layoutIfNeeded();
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Add pressed.")
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
            DispatchQueue.main.async(execute: {() in
                self.categories = categoryData.toDictionary { element in
                    if let id = element.id {
                        return id;
                    }
                    return 0;
                }
                
                self.collectionView.reloadData()
                self.setCollectionViewHeight()
                
            })
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(selectedCategories.count);
        return selectedCategories.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlagCell", for: indexPath) as! CategoryFlagView
        
        print("Setting cell for:")
        if let data = categories {
            cell.titleLabel.text = data[selectedCategories[indexPath.item]]?.name
            cell.titleLabel.sizeToFit()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let otherContstraintsWidthSum: CGFloat = 35.0;
        
        var calculatedWidth: CGFloat = 100;
        
        if let data = categories, let title = data[selectedCategories[indexPath.item]]?.name {
            calculatedWidth = NSString(string: title).size(withAttributes: [
                .font : UIFont(name: "Roboto-Bold", size: 15)!
                ]).width + otherContstraintsWidthSum
        }
        
        return CGSize(width: calculatedWidth, height: 32)
    }
    
    func setCollectionViewHeight() {
        let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint.constant = height
        self.view.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.performBatchUpdates({
            selectedCategories.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
            setCollectionViewHeight();
            selectedCategoriesContainer.setNeedsLayout();
            selectedCategoriesContainer.layoutIfNeeded();
        }, completion: nil)
        
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        if let delegate = self.modalDelegate {
            delegate.didCloseModal(data: selectedCategories);
        }
        self.dismiss(animated: true, completion: nil);
    }
    
    func didCloseModal(data: [Int]?) {
        if let d = data {
            self.selectedCategories = d
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let categoryvc = (segue.destination as! UINavigationController).topViewController as! CategoryListViewController;
        categoryvc.modalDelegate = self
        categoryvc.receivedItems = selectedCategories;
    }
}

