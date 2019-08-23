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
    var weekdays = Weekdays().list;
    
    @IBOutlet weak var selectedCategoriesContainer: UIView!
    
    @IBOutlet weak var weekdayCollectionView: WeekDayCollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        weekdayCollectionView.delegate = self
        weekdayCollectionView.dataSource = self
        // Do any additional setup after loading the view.
        if let selectedCategories = UserDefaults.standard.array(forKey: DefaultKeys.Filters.categories) as? [Int] {
            self.selectedCategories = selectedCategories
        }
        fetchUrl(url: Config.API_URL + "hobbycategories/")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        categoryCollectionView.reloadData();
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
                
                self.categoryCollectionView.reloadData()
                self.setCollectionViewHeight()
                
            })
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == categoryCollectionView {
            return 1;
        } else {
            return 2;
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(selectedCategories.count);
        if collectionView == self.categoryCollectionView {
            return selectedCategories.count;
        } else {
            if section == 0 {
                return weekdays.count - 1;
            } else {
                return 1;
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlagCell", for: indexPath) as! CategoryFlagView
            
            print("Setting cell for:")
            if let data = categories {
                cell.titleLabel.text = data[selectedCategories[indexPath.item]]?.name
                cell.titleLabel.sizeToFit()
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekdayCell", for: indexPath) as! WeekdayCollectionViewCell
            
            print("Setting cell for:")
            cell.titleLabel.adjustsFontSizeToFitWidth = true;
            if indexPath.section == 0 {
                cell.titleLabel.text = weekdays[indexPath.item].name
            } else {
                cell.titleLabel.text = weekdays[6].name
            }
            cell.contentView.layer.cornerRadius = 2.0
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true
            
            cell.layer.shadowColor = UIColor.black.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            cell.layer.shadowRadius = 2.0
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 1 {
            print("Inset")
            print((self.view.frame.width/2) - (125/2))
            return UIEdgeInsets(top: 8, left: (self.view.frame.width/2) - (125/2), bottom: 0, right: 0);
        }
        return UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.categoryCollectionView {
            let otherContstraintsWidthSum: CGFloat = 35.0;
            
            var calculatedWidth: CGFloat = 100;
            
            if let data = categories, let title = data[selectedCategories[indexPath.item]]?.name {
                calculatedWidth = NSString(string: title).size(withAttributes: [
                    .font : UIFont(name: "Roboto-Bold", size: 15)!
                    ]).width + otherContstraintsWidthSum
            }
            
            return CGSize(width: calculatedWidth, height: 32)
        } else {
            return CGSize(width: 110, height: 50)
        }
        
    }
    
    func setCollectionViewHeight() {
        let height = self.categoryCollectionView.collectionViewLayout.collectionViewContentSize.height
        collectionViewHeightConstraint.constant = height
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.categoryCollectionView {
            collectionView.performBatchUpdates({
                selectedCategories.remove(at: indexPath.item)
                collectionView.deleteItems(at: [indexPath])
                setCollectionViewHeight();
                selectedCategoriesContainer.setNeedsLayout();
                selectedCategoriesContainer.layoutIfNeeded();
            }, completion: nil)
        } else {
            print("Weekday selected")
        }
        
        
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

