//
//  PromotionData.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 5.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

struct PromotionData : Codable {
    var id = -1;
    var name = "Lorem ipsum dolor sit amet";
    var description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam cursus rhoncus velit, at interdum est finibus nec. Praesent maximus imperdiet porta. Suspendisse sit amet quam quis justo mattis sodales. Aenean sollicitudin, est vel egestas ultrices, justo nisi bibendum lectus, a varius neque enim mattis dui. Proin porttitor rutrum mattis. Suspendisse consectetur sed sem at congue. Duis pulvinar egestas arcu eget aliquam.";
    var startTime = "";
    var endTime = "";
    var startDate = "";
    var endDate = "";
    var image: String?
    var availableCount = 0;
    var usedCount = 0;
    var location: LocationData?;
    //var organizer = Organizer(name: "Ei järjestäjän tietoja");
    
    func isUsed() -> Bool {
        let defaults = UserDefaults.standard;
        if let usedPromotions = defaults.array(forKey: DefaultKeys.Promotions.usedPromotions) as? [Int] {
            if (usedPromotions.contains { id in
                id == self.id
            }) {
                return true;
            }
        }
        return false;
    }
    
    func isUsable() -> Bool {
        if availableCount > 0 {
            return availableCount - usedCount > 0;
        } else {
            return true;
        }
        
    }
    
    func getUsesLeft() -> Int {
        return availableCount - usedCount;
    }
    
    func use() {
        postUsage();
        let defaults = UserDefaults.standard;
        if let usedPromotions = defaults.array(forKey: DefaultKeys.Promotions.usedPromotions) {
            var updatedPromotions = usedPromotions;
            updatedPromotions.append(self.id);
            defaults.set(updatedPromotions, forKey: DefaultKeys.Promotions.usedPromotions);
            print(usedPromotions)
        } else {
            defaults.set([self.id], forKey: DefaultKeys.Promotions.usedPromotions);
        }
        Analytics.logEvent("usePromotion", parameters: [
            "promotionId": self.id,
            "promotionName": self.name
        ]);
        print(id)
    }
    
    func postUsage() {
        let params = ["promotion": self.id];
        let url = Config.API_URL + "benefits/";
        print(url);
        AF.request(url, method: .post, parameters: params, headers: ["Authorization": Config.API_KEY]).response { response in
            debugPrint(response);
        }
    }
    
    enum CodingKeys : String, CodingKey {
        case id = "id";
        case name = "name";
        case description = "description";
        case startTime = "start_time";
        case endTime = "end_time";
        case endDate = "end_date";
        case startDate = "start_date";
        case image = "cover_image";
        case availableCount = "available_count";
        case usedCount = "used_count";
        case location = "location";
        //case organizer = "organizer";
    }
}
