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
    
    var promotionData = [1,2,3,4,5,6,7,8]

    @IBOutlet weak var promotionCollectionView: UICollectionView!
    @IBOutlet weak var promotionBannerContainer: UIView!
    @IBOutlet weak var hobbyCollectionView: UICollectionView!
    @IBOutlet weak var hobbyBannerContainer: UIView!
    
    
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
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_kelt_lil")!,iconInitialSize: CGSize(width: 250, height: 250), backgroundColor: UIColor(red:0.19, green:0.08, blue:0.43, alpha:1.0))
        
        
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        
        revealingSplashView.startAnimation(){
            print("Completed")
        }
        
        setupNavBar()
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
        return promotionData.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = promotionCollectionView.dequeueReusableCell(withReuseIdentifier: "PromotionCollectionCell", for: indexPath) as! PromotionCollectionViewCell;
        cell.setPromotion(PromotionData());
        cell.layer.cornerRadius = 15;
        cell.layer.masksToBounds = true;
        return cell;
    }
}
