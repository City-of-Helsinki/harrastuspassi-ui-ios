//
//  HomeViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 12/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit
import Hero
import RevealingSplashView

class HomeViewController: UIViewController, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource, ModalDelegate {
    
    
    
    @IBOutlet weak var hobbyTableView: UITableView!
    @IBOutlet weak var errorText: UILabel!
    
    var hobbyData: [HobbyEventData]?
    var filters = Filters();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "logo_kelt_lil")!,iconInitialSize: CGSize(width: 250, height: 250), backgroundColor: UIColor(red:0.19, green:0.08, blue:0.43, alpha:1.0))
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(revealingSplashView)
        
        revealingSplashView.startAnimation(){
            print("Completed")
            revealingSplashView.removeFromSuperview();
        }
        
        
        hobbyTableView.delegate = self
        hobbyTableView.dataSource = self
        self.errorText.isHidden = true
        if let filteredCategories = UserDefaults.standard.array(forKey: DefaultKeys.Filters.categories) as? [Int], filteredCategories.count > 0  {
            filters.categories = filteredCategories
        }
        
        if let filteredWeekdays = UserDefaults.standard.array(forKey: DefaultKeys.Filters.weekdays) as? [Int] {
            filters.weekdays = filteredWeekdays
        }
        
        self.fetchUrl(urlString: Config.API_URL + "hobbyevents")
    }
    
    
    
    // Tableview setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = hobbyData {
            return d.count
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyTableViewCell", for: indexPath) as! HobbyTableViewCell
        if let d = hobbyData {
            cell.hobbyImage?.hero.id = "image" + String(indexPath.row);
            cell.title.hero.id = "title" + String(indexPath.row);
            cell.setHobbyEvents(hobbyEvent: d[indexPath.row])
            cell.contentView.hero.isEnabled = true;
            cell.contentView.hero.id = String(indexPath.row);
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func fetchUrl(urlString: String) {
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        var url: URL?;
        url = applyQueryParamsToUrl(urlString);
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
    
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let eventData = try? JSONDecoder().decode([HobbyEventData].self, from: fetchedData)
                else {
                    DispatchQueue.main.async(execute: {() in
                        self.errorText.isHidden = false
                        self.errorText.text = "Jokin meni vikaan"
                        
                    })
                    return
            }
            print(eventData)
            DispatchQueue.main.async(execute: {() in
                if(eventData.count == 0) {
                    self.hobbyData = eventData
                    self.hobbyTableView.reloadData()
                    self.errorText.text = "Ei harrastustapahtumia"
                    self.errorText.isHidden = false
                } else {
                    self.errorText.isHidden = true
                    self.hobbyData = eventData
                    self.hobbyTableView.reloadData()
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.details {
            guard let detailViewController = segue.destination as? HobbyDetailViewController,
                let index = hobbyTableView.indexPathForSelectedRow?.row
                else {
                    return
            }
            if let data = hobbyData {
                detailViewController.hobbyEvent = data[index]
            }
        } else if segue.identifier == Segues.filters {
            guard let filterModal = segue.destination as? FilterViewController else {
                return
            }
            filterModal.modalDelegate = self
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func didCloseModal(data: Filters?) {
        
        if let d = data {
            filters = d;
            UserDefaults.standard.set(d.categories, forKey: DefaultKeys.Filters.categories);
            UserDefaults.standard.set(d.weekdays, forKey: DefaultKeys.Filters.weekdays);
        }
        fetchUrl(urlString: Config.API_URL + "hobbyevents")
    }
    
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"))
        if filters.categories.count > 0 {
            for id in filters.categories {
                urlComponents?.queryItems?.append(URLQueryItem(name: "category", value: String(id)))
            }
        }
        if filters.weekdays.count > 0 {
            for id in filters.weekdays {
                urlComponents?.queryItems?.append(URLQueryItem(name: "start_weekday", value: String(id)))
            }
        }
        return urlComponents?.url
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard.init(name: "Main", bundle:nil)
        let destinationvc = sb.instantiateViewController(withIdentifier: "DetailsVC") as! HobbyDetailViewController
        if let data = hobbyData {
            destinationvc.heroID = String(indexPath.row);
            destinationvc.imageHeroID = "image" + String(indexPath.row);
            destinationvc.titleHeroID = "title" + String(indexPath.row);
            destinationvc.hobbyEvent = data[indexPath.row];
            destinationvc.image = (tableView.cellForRow(at: indexPath) as! HobbyTableViewCell).hobbyImage.image;
        }
        self.hero.modalAnimationType = .selectBy(presenting:.zoom, dismissing:.zoomOut);
        destinationvc.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut);
        self.navigationController?.pushViewController(destinationvc, animated: true);
        
    }
}
