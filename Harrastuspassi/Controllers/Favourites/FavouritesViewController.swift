//
//  FavouritesViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 17.10.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class FavouritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var hobbyData = [HobbyEventData]();
    var viewInForeground = true;
    
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var placeholderTextLabel: UILabel!
    
    let refreshControl = UIRefreshControl();
    
    var favorites = UserDefaults.standard.array(forKey: DefaultKeys.Favourites.list) as? [Int];

    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesTableView.refreshControl = refreshControl;
        favoritesTableView.delegate = self;
        favoritesTableView.dataSource = self;
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged);
        refreshControl.tintColor = .white;
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        viewInForeground = true;
        hobbyData = [];
        favorites = UserDefaults.standard.array(forKey: DefaultKeys.Favourites.list) as? [Int];
        if !(favorites?.count == 0) {
            print(favorites?.count);
            self.fetchUrl(urlString: Config.API_URL + "hobbyevents");
            placeholderTextLabel.isHidden = true;
        } else {
            print(favorites?.count);
            hobbyData = [];
            favoritesTableView.reloadData();
            placeholderTextLabel.isHidden = false;
        }
        if favorites == nil {
            placeholderTextLabel.isHidden = false;
        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        viewInForeground = false;
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - TableView Setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hobbyData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HobbyTableViewCell", for: indexPath) as! HobbyTableViewCell
        cell.setHobbyEvents(hobbyEvent: hobbyData[indexPath.row]);
        cell.hobbyImage?.hero.id = "image" + String(indexPath.row);
        cell.title.hero.id = "title" + String(indexPath.row);
        cell.location.hero.id = "location" + String(indexPath.row);
        cell.date.hero.id = "weekday" + String(indexPath.row);
        cell.contentView.hero.isEnabled = true;
        cell.contentView.hero.id = String(indexPath.row);
        cell.selectionStyle = .none
        
        
        return cell
        
    }
    
    func fetchUrl(urlString: String) {
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        var url: URL?;
        url = applyQueryParamsToUrl(urlString);
        print(url)
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
    
        task.resume();
    }
    
    func fetchNext(urlString: String) {
        let config = URLSessionConfiguration.default;
        let session = URLSession(configuration: config);
        let url = URL(string: urlString);
        print(url)
        let task = session.dataTask(with: url!, completionHandler: self.doneFetching);
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        if let fetchedData = data {
            guard let response = try? JSONDecoder().decode(HobbyEventResponse.self, from: fetchedData)
                else {
                    DispatchQueue.main.async(execute: {() in
                        print("error")
                    })
                    return
            }
            guard let eventData = response.results else {return};
            DispatchQueue.main.async(execute: {() in
                if(eventData.count == 0) {
                    self.hobbyData += Array(Set(eventData));
                    self.favoritesTableView.reloadData()
                } else {
                    self.hobbyData += self.filteredFavoriteHobbiesFrom(eventData.uniques);
                    self.favoritesTableView.reloadData()
                }
                print(self.hobbyData);
                self.refreshControl.endRefreshing();
            })
            if let next = response.next {
                if viewInForeground { fetchNext(urlString: next) }
            }
        }
    }
    
    func applyQueryParamsToUrl(_ url: String) -> URL? {
        var urlComponents = URLComponents(string: url);
        let defaults = UserDefaults.standard;
        let latitude = defaults.float(forKey: DefaultKeys.Location.lat),
            longitude = defaults.float(forKey: DefaultKeys.Location.lon);
        urlComponents?.queryItems = []
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "hobby_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "location_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "include", value: "organizer_detail"))
        urlComponents?.queryItems?.append(URLQueryItem(name: "ordering", value: "nearest"));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_latitude", value: String(latitude)));
        urlComponents?.queryItems?.append(URLQueryItem(name: "near_longitude", value: String(longitude)));
        
//        if let storedFavorites = favorites {
//            for id in storedFavorites {
//                urlComponents?.queryItems?.append(URLQueryItem(name: "hobby", value: String(id)));
//            }
//        }
        return urlComponents?.url
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.hobbyData = [];
        self.fetchUrl(urlString: Config.API_URL + "hobbyevents")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.identifier)
        if segue.identifier == Segues.details {
            guard let detailViewController = segue.destination as? HobbyDetailViewController,
                let index = favoritesTableView.indexPathForSelectedRow?.row, let path = favoritesTableView.indexPathForSelectedRow
                else {
                    return
            }
            
            detailViewController.hobbyEvent = hobbyData[index]
            detailViewController.heroID = String(index);
            detailViewController.imageHeroID = "image" + String(index);
            detailViewController.titleHeroID = "title" + String(index);
            detailViewController.locationHeroID = "location" + String(index);
            detailViewController.dayOfWeekLabelHeroID = "weekday" + String(index);
            //detailViewController.titleHeroID = "title" + String(index);
            detailViewController.image = (favoritesTableView.cellForRow(at: path) as! HobbyTableViewCell).hobbyImage.image;
            
            self.hero.modalAnimationType = .selectBy(presenting:.none, dismissing:.none);
            detailViewController.hero.modalAnimationType = .selectBy(presenting: .none, dismissing: .none);
            
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func filteredFavoriteHobbiesFrom(_ hobbyEvents: [HobbyEventData]) -> [HobbyEventData] {
        return hobbyEvents.filter{ hobbyEvent in
            if let contains = (favorites?.contains { favorite in
                favorite == hobbyEvent.hobby!.id
                }) {
                return contains;
            }
            return false;
        }
    }
}
