//
//  FrontPageViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 20.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import RevealingSplashView
import Firebase
import Alamofire


class FrontPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    
    
    var promotions: [PromotionData] = [];
    var hobbyEvents: [HobbyEventData] = [];
    var categories: [CategoryData] = [];
    var searchOptions: [CategoryData] = [];
    var recommendedHobbies: [HobbyEventData] = [];
    var recommendedPromotions: [PromotionData] = [];
    var searchValue = "";

    @IBOutlet weak var promotionCollectionView: UICollectionView!
    @IBOutlet weak var promotionBannerContainer: UIView!
    @IBOutlet weak var hobbyCollectionView: UICollectionView!
    @IBOutlet weak var hobbyBannerContainer: UIView!
    @IBOutlet weak var promotionSectionTitleView: UIView!
    @IBOutlet weak var hobbySectionTitleLabel: UILabel!
    
    @IBOutlet weak var hobbyBannerImageView: UIImageView!
    @IBOutlet weak var hobbyBannerTitleLabel: UILabel!
    @IBOutlet weak var hobbyBannerDescriptionLabel: UILabel!
    @IBOutlet weak var hobbyBannerDateLabel: UILabel!
    
    @IBOutlet weak var promotionBannerImageView: UIImageView!
    @IBOutlet weak var promotionBannerTitleLabel: UILabel!
    @IBOutlet weak var promotionBannerDescriptionLabel: UILabel!
    @IBOutlet weak var promotionBannerDateLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchResultsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var recommendedPromotionsCollectionView: UICollectionView!
    @IBOutlet weak var recommendedHobbiesCollectionView: UICollectionView!
    @IBOutlet weak var recommendedPromotionsTitleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        addNavBarImage()
        promotionCollectionView.delegate = self;
        promotionCollectionView.dataSource = self;
        hobbyCollectionView.delegate = self;
        hobbyCollectionView.dataSource = self;
        recommendedHobbiesCollectionView.dataSource = self;
        recommendedPromotionsCollectionView.dataSource = self;
        recommendedHobbiesCollectionView.delegate = self;
        recommendedPromotionsCollectionView.delegate = self;
        
        
        promotionBannerContainer.layer.cornerRadius = 15;
        promotionBannerContainer.layer.masksToBounds = true;
        hobbyBannerContainer.layer.cornerRadius = 15;
        hobbyBannerContainer.layer.masksToBounds = true;
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationPermissionUpdated), name:.locationPermissionsUpdated, object: nil);
        if #available(iOS 13.0, *) {
            self.hero.isEnabled = true;
        } else {
            self.hero.isEnabled = false;
        }
        
        if promotions.count == 0 {
            promotionBannerContainer.isHidden = true;
            promotionSectionTitleView.isHidden = true;
            recommendedPromotionsCollectionView.isHidden = true;
            
        }
        if promotions.count <= 1 {
            promotionCollectionView.isHidden = true;
        }
        if hobbyEvents.count == 0 {
            hobbyBannerContainer.isHidden = true;
            hobbySectionTitleLabel.isHidden = true;
            recommendedHobbiesCollectionView.isHidden = true;
        }
        if hobbyEvents.count <= 1 {
            hobbyCollectionView.isHidden = true;
        }
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_kelt_lil")!,iconInitialSize: CGSize(width: 250, height: 250), backgroundColor: Colors.bgMain)
        
        self.searchResultsTableView.dataSource = self;
        self.searchResultsTableView.delegate = self;
        
        self.searchBar.delegate = self;
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        
        revealingSplashView.startAnimation(){
            print("Completed")
        }
        
        let categoryUrl = Config.API_URL + "hobbycategories/";
        AF.request(categoryUrl, method: .get).response { response in
            debugPrint(response);
            if let fetchedData = response.data {
                guard let categoryData = try? JSONDecoder().decode([CategoryData].self, from: fetchedData)
                    else {
                        return
                }
                DispatchQueue.main.async(execute: {() in
                    self.categories = categoryData;
                    print(self.categories)
                    self.searchResultsHeightConstraint.constant = self.searchResultsTableView.contentSize.height;
                })
            }
        }
        let gr = UITapGestureRecognizer(target: self, action:#selector(self.dismissKeyboard(_:)));
        gr.delegate = self;
        view.addGestureRecognizer(gr);
        
        setupNavBar()
        
        fetchUrl(urlString: Config.API_URL + "hobbyevents/");
        fetchPromotionsUrl(urlString: Config.API_URL + "promotions/")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        searchBar.endEditing(true);
        searchBar.text = "";
        searchBar.resignFirstResponder();
        searchOptions = [];
        searchResultsTableView.reloadData();
        searchResultsHeightConstraint.constant = searchResultsTableView.contentSize.height;
        fetchUrl(urlString: Config.API_URL + "hobbyevents/");
        fetchPromotionsUrl(urlString: Config.API_URL + "promotions/")
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer? = nil) {
        self.searchBar.endEditing(true);
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc
    func locationPermissionUpdated() {
        fetchUrl(urlString: Config.API_URL + "hobbyevents/");
        fetchPromotionsUrl(urlString: Config.API_URL + "promotions/")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view!.isDescendant(of: searchResultsTableView) || touch.view!.isDescendant(of: promotionCollectionView) || touch.view!.isDescendant(of: hobbyCollectionView) || touch.view!.isDescendant(of: recommendedHobbiesCollectionView) || touch.view!.isDescendant(of: recommendedPromotionsCollectionView)) {

            // Don't let selections of auto-complete entries fire the
            // gesture recognizer
            return false;
        }

        return true;
    }
    
//    func addNavBarImage() {
//        let navController = navigationController!
//        let image = UIImage(named: "frontpage_logo")
//        let imageView = UIImageView(image: image)
//        let bannerWidth = navController.navigationBar.frame.size.width
//        let bannerHeight = navController.navigationBar.frame.size.height
//        let bannerX = bannerWidth / 2 - (image?.size.width)! / 2
//        let bannerY = bannerHeight / 2 - (image?.size.height)! / 2
//        imageView.frame = CGRect(x: 16, y: 16, width: bannerWidth, height: bannerHeight)
//        imageView.contentMode = .scaleAspectFit
//        navigationItem.titleView = imageView
//    }
    
    func setupNavBar() {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()

            // title color
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

            // large title color
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

            // background color
            appearance.backgroundColor = UIColor(named: "mainColor")

            // bar button styling
            let barButtonItemApperance = UIBarButtonItemAppearance()
            barButtonItemApperance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]

            appearance.backButtonAppearance = barButtonItemApperance

            // set the navigation bar appearance to the color we have set above
            self.navigationController?.navigationBar.standardAppearance = appearance

            // when the navigation bar has a neighbouring scroll view item (eg: scroll view, table view etc)
            // the "scrollEdgeAppearance" will be used
            // by default, scrollEdgeAppearance will have a transparent background
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            UINavigationBar.appearance().tintColor = .white
        }

        // the back icon color
        
    }
    
    // MARK: - CollectionView setup
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == promotionCollectionView {
            return promotions.count - 1;
        } else if collectionView == hobbyCollectionView {
            return hobbyEvents.count - 1;
        } else if collectionView == recommendedHobbiesCollectionView {
            return recommendedHobbies.count;
        } else {
            return recommendedPromotions.count;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.promotionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromotionCollectionCell", for: indexPath) as! PromotionCollectionViewCell;
            cell.setPromotion(promotions[indexPath.row + 1]);
            cell.layer.cornerRadius = 15;
            cell.layer.masksToBounds = true;
            return cell;
        } else if collectionView == self.hobbyCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyCollectionCell", for: indexPath) as! HobbyCollectionViewCell;
            cell.setHobby(hobbyEvents[indexPath.row + 1]);
            cell.layer.cornerRadius = 15;
            cell.layer.masksToBounds = true;
            cell.hero.id = String(indexPath.row);
            cell.imageView.hero.id = "image" + String(indexPath.row);
            return cell;
        } else if collectionView == self.recommendedHobbiesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyCollectionCell", for: indexPath) as! HobbyCollectionViewCell;
            cell.setHobby(recommendedHobbies[indexPath.row]);
            cell.layer.cornerRadius = 15;
            cell.layer.masksToBounds = true;
            cell.hero.id = "recommended" + String(indexPath.row);
            cell.imageView.hero.id = "image" + String(indexPath.row);
            return cell;
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromotionCollectionCell", for: indexPath) as! PromotionCollectionViewCell;
            cell.setPromotion(recommendedPromotions[indexPath.row]);
            cell.layer.cornerRadius = 15;
            cell.layer.masksToBounds = true;
            return cell;
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.hobbyCollectionView {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsVC") as! HobbyDetailViewController
            newViewController.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            self.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            newViewController.hobbyEvent = hobbyEvents[(indexPath.row+1)];
            newViewController.heroID = String(indexPath.row);
            newViewController.imageHeroID = "image" + String(indexPath.row);
            present(newViewController, animated: true);
            if let hobby = hobbyEvents[(indexPath.row+1)].hobby {
                
                var params = [
                    "hobbyId": hobby.id ?? 0,
                    "hobbyName": hobby.name!,
                    "organizerName": hobby.organizer?.name ?? "",
                    "free": true,
                    "postalCode": hobby.location?.zipCode ?? "",
                    "municipality": hobby.location?.city ?? ""
                    ] as [String : Any];
                
                debugPrint("ANALYTICS EVENT");
                Analytics.logEvent("viewHobby", parameters: params)
            };
        } else if collectionView == self.promotionCollectionView {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "PromotionModal") as! PromotionModalViewController
            newViewController.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            self.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            newViewController.promotion = promotions[(indexPath.row + 1)];
            present(newViewController, animated: true);
        } else if collectionView == self.recommendedHobbiesCollectionView {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsVC") as! HobbyDetailViewController
            newViewController.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            self.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            newViewController.hobbyEvent = recommendedHobbies[(indexPath.row)];
            newViewController.heroID = String(indexPath.row);
            newViewController.imageHeroID = "image" + String(indexPath.row);
            present(newViewController, animated: true);
            if let hobby = hobbyEvents[(indexPath.row)].hobby {
                
                let params = [
                    "hobbyId": hobby.id ?? 0,
                    "hobbyName": hobby.name!,
                    "organizerName": hobby.organizer?.name ?? "",
                    "free": true,
                    "postalCode": hobby.location?.zipCode ?? "",
                    "municipality": hobby.location?.city ?? ""
                    ] as [String : Any];
                
                debugPrint("ANALYTICS EVENT");
                Analytics.logEvent("viewHobby", parameters: params)
            };
        } else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewController = storyBoard.instantiateViewController(withIdentifier: "PromotionModal") as! PromotionModalViewController
            newViewController.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            self.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
            newViewController.promotion = recommendedPromotions[(indexPath.row)];
            present(newViewController, animated: true);
        }
    }
    
    func fetchUrl(urlString: String) {
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        var url: URL?;
        url = applyQueryParamsToUrl(urlString);
        print(url);
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
    
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let response = try? JSONDecoder().decode(HobbyEventResponse.self, from: fetchedData)
                else {
                    return
            }
            print(response.results);
            guard let hobbyData = response.results else {return};
            DispatchQueue.main.async(execute: {() in
                if(hobbyData.count == 0) {
                    self.hobbyEvents = hobbyData;
                    self.hobbyCollectionView.reloadData()
                } else {
                    self.hobbyEvents = Array(hobbyData.prefix(7)).uniques.shuffled();
                    self.recommendedHobbies = Array(hobbyData.prefix(7)).uniques;
                    self.hobbyCollectionView.reloadData()
                    self.recommendedHobbiesCollectionView.reloadData()
                    if self.recommendedHobbies.count > 0 {
                        self.recommendedHobbiesCollectionView.isHidden = false;
                    }
                    self.hobbyBannerContainer.isHidden = false;
                    self.hobbySectionTitleLabel.isHidden = false;
                    self.setHobbyBanner(self.hobbyEvents[0]);
                    
                    if hobbyData.count > 1 {
                        self.hobbyCollectionView.isHidden = false;
                    }
                }
            })
        }
    }
    
    func fetchPromotionsUrl(urlString: String) {
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        var url: URL?;
        url = applyQueryParamsToUrl(urlString);
        let task = session.dataTask(with: url!, completionHandler: self.doneFetchingPromotions);
        task.resume();
    }
    
    func doneFetchingPromotions(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard var promotions = try? JSONDecoder().decode([PromotionData].self, from: fetchedData)
                else {
                    return
            }
            DispatchQueue.main.async(execute: {() in
                promotions = promotions.filter { item in
                    return !item.isUsed();
                }
                if(promotions.count == 0) {
                    self.promotions = promotions;
                self.promotionCollectionView.reloadData();
                    self.recommendedPromotionsTitleLabel.isHidden = true;
                    
                } else {
                    
                    self.promotions = promotions.shuffled();
                    self.recommendedPromotions = promotions;
                    self.promotionCollectionView.reloadData();
                    self.promotionBannerContainer.isHidden = false;
                    self.promotionSectionTitleView.isHidden = false;
                    self.recommendedPromotionsTitleLabel.isHidden = false;
                    self.setPromotionBanner(self.promotions[0]);
                    if promotions.count > 1 {
                        self.promotionCollectionView.isHidden = false;
                    }
                    self.recommendedPromotionsCollectionView.reloadData()
                    if self.recommendedPromotions.count > 0 {
                        self.recommendedPromotionsCollectionView.isHidden = false;
                    }
                }
            })
        }
    }
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "location_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "organizer_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "exclude_past_events", value: "true"))
    
        let defaults = UserDefaults.standard;
        let latitude = defaults.float(forKey: DefaultKeys.Location.lat),
            longitude = defaults.float(forKey: DefaultKeys.Location.lon);
        urlComponents?.queryItems?.append(URLQueryItem(name: "ordering", value: "nearest"));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_latitude", value: String(latitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_longitude", value: String(longitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "max_distance", value: String("50")));
        return urlComponents?.url
    }
    
    func setHobbyBanner(_ hobbyEvent: HobbyEventData) {
        if let image = hobbyEvent.hobby?.image {
            hobbyBannerImageView.kf.setImage(with: URL(string: image));
        }
        hobbyBannerTitleLabel.text = hobbyEvent.hobby?.name;
        hobbyBannerDescriptionLabel.text = hobbyEvent.hobby?.description;
        let gestureRec = UITapGestureRecognizer(target: self, action:  #selector (self.presentDetails));
        hobbyBannerContainer.addGestureRecognizer(gestureRec)
        hobbyBannerContainer.hero.id = "Hobby" + String(-1);
        hobbyBannerImageView.hero.id = "hobbyimage" + String(-1);
    }
    
    func setPromotionBanner(_ promotion: PromotionData) {
        if let image = promotion.image {
            promotionBannerImageView.kf.setImage(with: URL(string: image));
        }
        promotionBannerTitleLabel.text = promotion.name;
        promotionBannerDescriptionLabel.text = promotion.description;
        promotionBannerDateLabel.text = String(format: NSLocalizedString("ValidUntil", comment: ""), Utils.formatDateFromString(promotion.endDate));
        let gestureRec = UITapGestureRecognizer(target: self, action:  #selector (self.presentPromotionDetails));
        promotionBannerContainer.addGestureRecognizer(gestureRec);
    }
    
    @objc func presentDetails(sender:UITapGestureRecognizer) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsVC") as! HobbyDetailViewController
        newViewController.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
        self.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
        newViewController.hobbyEvent = hobbyEvents[0];
        newViewController.heroID = "Hobby" + String(-1);
        newViewController.imageHeroID = "hobbyimage" + String(-1);
        present(newViewController, animated: true);
        if let hobby = hobbyEvents[0].hobby {
            
            var params = [
                "hobbyId": hobby.id ?? 0,
                "hobbyName": hobby.name!,
                "organizerName": hobby.organizer?.name ?? "",
                "free": true,
                "postalCode": hobby.location?.zipCode ?? "",
                "municipality": hobby.location?.city ?? ""
                ] as [String : Any];
            
            debugPrint("ANALYTICS EVENT");
            Analytics.logEvent("viewHobby", parameters: params)
        };
    }
    
    
    
    @objc func presentPromotionDetails(sender:UITapGestureRecognizer) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "PromotionModal") as! PromotionModalViewController
        newViewController.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
        self.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
        newViewController.promotion = promotions[0];
        print(promotions)
        present(newViewController, animated: true);
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchOptions.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let name = searchOptions[indexPath.row].name {
            searchBar.text = name;
            searchValue = name;
            let navVc = self.tabBarController?.viewControllers![1] as! UINavigationController;
            let vc = navVc.topViewController as! HomeViewController;
            vc.searchValue = searchValue;
            self.tabBarController?.selectedIndex = 1;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultsTableView.dequeueReusableCell(withIdentifier: "ResultCell") as! SearchResultsTableViewCell;
        cell.nameLabel.text = searchOptions[indexPath.row].name;
        return cell;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchOptions = categories.filter { item in
            
            if let name = item.name?.uppercased(), let searchCount = self.searchBar.text?.count{
                if searchCount > 0 {
                    return name.contains(searchText.uppercased());
                }
                
            }
            
            return false;
        };
        searchResultsTableView.reloadData();
        searchResultsHeightConstraint.constant = searchResultsTableView.contentSize.height;
        searchValue = searchText;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let navVc = self.tabBarController?.viewControllers![1] as! UINavigationController;
        let vc = navVc.topViewController as! HomeViewController;
        vc.searchValue = searchValue;
        self.tabBarController?.selectedIndex = 1;
        
    }
}
