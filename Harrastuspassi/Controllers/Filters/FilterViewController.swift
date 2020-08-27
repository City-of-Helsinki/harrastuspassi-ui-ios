//
//  FilterViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 08/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import RangeSeekSlider
import Firebase

class FilterViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ModalDelegate, RangeSeekSliderDelegate {
    
    
    let feedbackGenerator = UISelectionFeedbackGenerator();
    var categories: Dictionary<Int, CategoryData>?;
    var selectedCategories: [Int] = [];
    var selectedWeekdays: [Int] = [];
    var modalDelegate: ModalDelegate?
    var weekdays = Weekdays().list;
    var filters = Filters();
    var defaults = UserDefaults.standard;
    var freeOnly = false;
    
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var maxTimeLabel: UILabel!
    @IBOutlet weak var minTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: TimeFilterSlider!
    @IBOutlet weak var weekDayContainerView: UIView!
    @IBOutlet weak var selectedCategoriesContainer: UIView!
    @IBOutlet weak var weekdayCollectionView: WeekDayCollectionView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var categoryCollectionContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var freeOnlySwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        weekdayCollectionView.delegate = self
        weekdayCollectionView.dataSource = self
        timeSlider.delegate = self;
        freeOnlySwitch.setOn(false, animated: false);
        navBar.layer.zPosition = .greatestFiniteMagnitude
        
        // Do any additional setup after loading the view.
        if let selectedCategories = defaults.array(forKey: DefaultKeys.Filters.categories) as? [Int] {
            self.selectedCategories = selectedCategories
        }
        if let selectedWeekdays = defaults.array(forKey: DefaultKeys.Filters.weekdays) as? [Int] {
            self.selectedWeekdays = selectedWeekdays
            weekdayCollectionView.reloadData();
        }
        if let startTime = defaults.float(forKey: DefaultKeys.Filters.startTime) as Float?, let endTime = defaults.float(forKey: DefaultKeys.Filters.endTime) as Float?, endTime > 0 {
            let minValue = CGFloat(startTime);
            let maxValue = CGFloat(endTime);
            
            timeSlider.selectedMinValue = minValue;
            timeSlider.selectedMaxValue = maxValue;
            
            filters.times.minTime = minValue;
            filters.times.maxTime = maxValue;
        } else {
            let minValue: CGFloat = 0;
            let maxValue: CGFloat = 1439;
            
            timeSlider.selectedMinValue = minValue;
            timeSlider.selectedMaxValue = maxValue;
            
            filters.times.minTime = minValue;
            filters.times.maxTime = maxValue;
        }
        if let priceType = defaults.string(forKey: DefaultKeys.Filters.priceType) {
            if priceType == "free" {
                freeOnlySwitch.setOn(true, animated: false);
                freeOnly = true;
            } else {
                freeOnlySwitch.setOn(false, animated: false);
                freeOnly = false;
            }
        }
        minTimeLabel.text = Utils.formatTimeFrom(float: filters.times.minTime);
        maxTimeLabel.text = Utils.formatTimeFrom(float: filters.times.maxTime);
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
    func setTitle(category: CategoryData) -> String? {
        let lang = Locale.current.languageCode;
        switch lang {
        case "fi":
            return category.nameFI;
        case "sv":
            return category.nameSV;
        default:
            return category.nameEN;
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlagCell", for: indexPath) as! CategoryFlagView
            
            print("Setting cell for:")
            if let data = categories {
                cell.titleLabel.text = self.setTitle(category: data[selectedCategories[indexPath.item]]!);
                cell.titleLabel.sizeToFit()
            }
            cell.layer.cornerRadius = 10;
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekdayCell", for: indexPath) as! WeekdayCollectionViewCell
            
            print("Setting cell for:")
            cell.titleLabel.adjustsFontSizeToFitWidth = true;
            cell.layer.cornerRadius = 20;
            if indexPath.section == 0 {
                cell.titleLabel.text = weekdays[indexPath.item].name
                if selectedWeekdays.count > 0, selectedWeekdays.contains(weekdays[indexPath.item].id) {
                    cell.backgroundColor = Colors.bgMain;
                    cell.titleLabel.textColor = .white;
                } else {
                    cell.backgroundColor = .white;
                    cell.titleLabel.textColor = UIColor.init(named: "darkGrey");
                }
            } else {
                cell.titleLabel.text = weekdays[6].name
                if selectedWeekdays.contains(7) {
                    cell.backgroundColor = Colors.bgMain;
                    cell.titleLabel.textColor = .white;
                } else {
                    cell.backgroundColor = .white;
                    cell.titleLabel.textColor = UIColor.init(named: "darkGrey");
                }
            }
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.weekdayCollectionView && section == 1 {
            let totalCellWidth = 100;
            let totalSpacingWidth = 0;
            
            let leftInset = (collectionView.frame.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset
            print("Inset")
            print((collectionView.frame.width/2) - (100/2))
            return UIEdgeInsets(top: 8, left: leftInset, bottom: 0, right: rightInset);
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
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            var height = self.categoryCollectionView.collectionViewLayout.collectionViewContentSize.height
            print("height")
            print(height)
            if height < 32 {
                height = 32
            }
            self.categoryCollectionContainerHeightConstraint.constant = height + 100
            self.collectionViewHeightConstraint.constant = height;
            var collectiveHeight:CGFloat = 0
            for view in self.containerView.subviews {
                collectiveHeight = collectiveHeight + view.bounds.size.height
            }
            self.containerView.frame.size = CGSize(width: self.containerView.frame.width, height: collectiveHeight + height);
            self.scrollView.contentSize = self.containerView.frame.size;
            print(collectiveHeight) //total height of all subviews
            self.view.layoutIfNeeded();
            print("ContainerHeight:");
            print(self.containerView.frame.height);
            print("Scrollviewhight:");
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.categoryCollectionView {
            collectionView.performBatchUpdates({
                feedbackGenerator.selectionChanged();
                selectedCategories.remove(at: indexPath.item)
                collectionView.deleteItems(at: [indexPath])
                setCollectionViewHeight();
                selectedCategoriesContainer.setNeedsLayout();
                selectedCategoriesContainer.layoutIfNeeded();
            }, completion: nil)
        } else {
            if indexPath.section == 0 {
                print(indexPath.item)
                if selectedWeekdays.contains(indexPath.item + 1) {
                    selectedWeekdays = selectedWeekdays.filter { $0 != indexPath.item + 1 }
                } else {
                    selectedWeekdays.append(indexPath.item + 1);
                }
            } else {
                if selectedWeekdays.contains(7) {
                    selectedWeekdays = selectedWeekdays.filter {$0 != 7}
                } else {
                    selectedWeekdays.append(7)
                }
            }
            feedbackGenerator.selectionChanged();
            weekdayCollectionView.reloadData();
            print(selectedWeekdays)
        }
        
        
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        var filters = Filters();
        filters.categories = selectedCategories;
        filters.weekdays = selectedWeekdays;
        filters.times.maxTime = self.filters.times.maxTime;
        filters.times.minTime = self.filters.times.minTime;
        filters.price_type = self.filters.price_type;
        if let delegate = self.modalDelegate {
            delegate.didCloseModal(data: filters);
        }
        var params = [String:Any]();
        for (index,category) in filters.categories.enumerated() {
            params["filterCategory" + String(index)] = category;
        }
        for (index,weekday) in filters.weekdays.enumerated() {
            params["weekDay" + String(index)] = weekday;
        }
        params["minTime"] = Utils.formatTimeFrom(float: filters.times.minTime);
        params["maxTime"] = Utils.formatTimeFrom(float: filters.times.maxTime);
        Analytics.logEvent("hobbyFilter", parameters: params)
        self.dismiss(animated: true, completion: nil);
    }
    
    func didCloseModal(data: Filters?) {
        if let d = data {
            self.selectedCategories = d.categories;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let categoryvc = (segue.destination as! UINavigationController).topViewController as! CategoryListViewController;
        categoryvc.modalDelegate = self
        categoryvc.receivedItems = selectedCategories;
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
        self.filters.times.minTime = minValue;
        self.filters.times.maxTime = maxValue;
        minTimeLabel.text = Utils.formatTimeFrom(float: minValue);
        maxTimeLabel.text = Utils.formatTimeFrom(float: maxValue);
        
        
        print(filters);
    }
    @IBAction func toggleFreeOnlySwitch(_ sender: Any) {
        if(self.freeOnlySwitch.isOn) {
            self.filters.price_type = "free";
        } else {
            self.filters.price_type = nil;
        }
    }
}

