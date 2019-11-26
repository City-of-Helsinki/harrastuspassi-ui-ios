//
//  PromotionsViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 5.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class PromotionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var promotions: [PromotionData] = [];
    

    @IBOutlet weak var tableView: PromotionsTableView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeHolderLabel.isHidden = true;
        if promotions.count == 0 {
            placeHolderLabel.isHidden = false;
        }
        // Do any additional setup after loading the view.
        
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor(named: "mainColor")
            self.navigationController!.navigationBar.standardAppearance = navBarAppearance
            self.navigationController!.navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            // Fallback on earlier versions
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promotions.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "promocell", for: indexPath) as! PromotionTableViewCell;
        let promotion = promotions[indexPath.row];
        cell.setPromotion(promotion);
        if promotion.isUsed() {
            cell.layer.opacity = 0.5
        }
        return cell;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PromotionModalViewController;
        if let index = self.tableView.indexPathForSelectedRow?.row {
            vc.promotion = promotions[index];
        }
    }
    
}
