//
//  FrontPageViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 20.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import RevealingSplashView


class FrontPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var promotionData: [Int] = [];
    var hobbyData: [HobbyData] = [];

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        promotionCollectionView.delegate = self;
        promotionCollectionView.dataSource = self;
        hobbyCollectionView.delegate = self;
        hobbyCollectionView.dataSource = self;
        
        promotionBannerContainer.layer.cornerRadius = 15;
        promotionBannerContainer.layer.masksToBounds = true;
        hobbyBannerContainer.layer.cornerRadius = 15;
        hobbyBannerContainer.layer.masksToBounds = true;
        
        if promotionData.count == 0 {
            promotionBannerContainer.isHidden = true;
            promotionSectionTitleView.isHidden = true;
            
        }
        if promotionData.count <= 1 {
            promotionCollectionView.isHidden = true;
        }
        if hobbyData.count == 0 {
            hobbyBannerContainer.isHidden = true;
            hobbySectionTitleLabel.isHidden = true;
        }
        if hobbyData.count <= 1 {
            hobbyCollectionView.isHidden = true;
        }
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_kelt_lil")!,iconInitialSize: CGSize(width: 250, height: 250), backgroundColor: UIColor(red:0.19, green:0.08, blue:0.43, alpha:1.0))
        
        
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        
        revealingSplashView.startAnimation(){
            print("Completed")
        }
        
        setupNavBar()
        
        fetchUrl(urlString: Config.API_URL + "hobbies/");
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        }

        // the back icon color
        UINavigationBar.appearance().tintColor = .white
    }
    
    // MARK: - CollectionView setup
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == promotionCollectionView {
            return promotionData.count - 1;
        } else {
            return hobbyData.count - 1;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.promotionCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PromotionCollectionCell", for: indexPath) as! PromotionCollectionViewCell;
            cell.setPromotion(PromotionData());
            cell.layer.cornerRadius = 15;
            cell.layer.masksToBounds = true;
            return cell;
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbyCollectionCell", for: indexPath) as! HobbyCollectionViewCell;
            cell.setHobby(hobbyData[indexPath.row + 1]);
            cell.layer.cornerRadius = 15;
            cell.layer.masksToBounds = true;
            return cell;
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
            guard let hobbyData = try? JSONDecoder().decode([HobbyData].self, from: fetchedData)
                else {
                    return
            }
            DispatchQueue.main.async(execute: {() in
                if(hobbyData.count == 0) {
                    self.hobbyData = hobbyData;
                    self.hobbyCollectionView.reloadData()
                } else {
                    self.hobbyData = Array(hobbyData.prefix(7));
                    self.hobbyCollectionView.reloadData()
                    
                    self.hobbyBannerContainer.isHidden = false;
                    self.hobbySectionTitleLabel.isHidden = false;
                    self.setHobbyBanner(hobbyData[0]);
                    
                    if hobbyData.count > 1 {
                        self.hobbyCollectionView.isHidden = false;
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
        
        let defaults = UserDefaults.standard;
        let latitude = defaults.float(forKey: DefaultKeys.Location.lat),
            longitude = defaults.float(forKey: DefaultKeys.Location.lon);
        urlComponents?.queryItems?.append(URLQueryItem(name: "ordering", value: "nearest"));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_latitude", value: String(latitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_longitude", value: String(longitude)));
        return urlComponents?.url
    }
    
    func setHobbyBanner(_ hobby: HobbyData) {
        if let image = hobby.image {
            hobbyBannerImageView.kf.setImage(with: URL(string: image));
        }
        hobbyBannerTitleLabel.text = hobby.name;
        hobbyBannerDescriptionLabel.text = hobby.description;
    }
}
