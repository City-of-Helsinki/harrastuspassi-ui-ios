//
//  PromotionsViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 5.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class PromotionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var promotions: [PromotionData] = [];
    var searchValue = "";

    @IBOutlet weak var tableView: PromotionsTableView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeHolderLabel.isHidden = true;
        if promotions.count == 0 {
            placeHolderLabel.isHidden = false;
        }
        // Do any additional setup after loading the view.
        searchBar.delegate = self;
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        reloadData();
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
    
    func reloadData() {
        fetchUrl(urlString: Config.API_URL + "promotions/");
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return promotions.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "promocell", for: indexPath) as! PromotionTableViewCell;
        let promotion = promotions[indexPath.row];
        cell.setPromotion(promotion);
        if !promotion.isUsable() || promotion.isUsed() {
            cell.setUsedAppearance();
        } else {
            cell.setUnUsedAppearence()
        }
        return cell;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PromotionModalViewController;
        vc.completionHandler = { self.reloadData() };
        if let index = self.tableView.indexPathForSelectedRow?.row {
            vc.promotion = promotions[index];
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
        
            do {
                let promotionData = try JSONDecoder().decode([PromotionData].self, from: fetchedData)
            } catch {
                print(error)
            }
            
            guard let promotionData = try? JSONDecoder().decode([PromotionData].self, from: fetchedData)
                else {
                    DispatchQueue.main.async(execute: {() in
                        self.placeHolderLabel.isHidden = false
                        self.placeHolderLabel.text = NSLocalizedString("Something went wrong", comment:"");
                    })
                    return
            }
            DispatchQueue.main.async(execute: {() in
                if(promotionData.count == 0) {
                    self.promotions = promotionData;
                    self.tableView.reloadData();
                } else {
                    self.placeHolderLabel.isHidden = true
                    self.promotions = promotionData.sorted {$0.isUsable() && !$1.isUsable()};
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "location_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "organizer_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "search", value: searchValue))
        
        let defaults = UserDefaults.standard;
        let latitude = defaults.float(forKey: DefaultKeys.Location.lat),
            longitude = defaults.float(forKey: DefaultKeys.Location.lon);
        
        urlComponents?.queryItems?.append(URLQueryItem(name: "ordering", value: "nearest"));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_latitude", value: String(latitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_longitude", value: String(longitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "max_distance", value: String("50")));
        return urlComponents?.url
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchValue = searchText;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();

        reloadData();
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadData();
        searchBar.resignFirstResponder();
    }
}
