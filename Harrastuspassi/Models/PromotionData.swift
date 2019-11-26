//
//  PromotionData.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 5.11.2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation

struct PromotionData : Codable {
    var id = -1;
    var name = "Lorem ipsum dolor sit amet";
    var description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam cursus rhoncus velit, at interdum est finibus nec. Praesent maximus imperdiet porta. Suspendisse sit amet quam quis justo mattis sodales. Aenean sollicitudin, est vel egestas ultrices, justo nisi bibendum lectus, a varius neque enim mattis dui. Proin porttitor rutrum mattis. Suspendisse consectetur sed sem at congue. Duis pulvinar egestas arcu eget aliquam.";
    var startTime = Date();
    var endTime = Date();
    var image: String?
    var hobby: HobbyData?;
    
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
    
    func use() {
        let defaults = UserDefaults.standard;
        if let usedPromotions = defaults.array(forKey: DefaultKeys.Promotions.usedPromotions) {
            var updatedPromotions = usedPromotions;
            updatedPromotions.append(self.id);
            defaults.set(updatedPromotions, forKey: DefaultKeys.Promotions.usedPromotions);
            print(usedPromotions)
        } else {
            defaults.set([self.id], forKey: DefaultKeys.Promotions.usedPromotions);
        }
        print(id)
    }
    
    enum CodingKeys : String, CodingKey {
        case id = "id";
        case name = "name";
        case description = "description";
        case startTime = "start_time";
        case endTime = "end_time";
        case image = "cover_image";
        case hobby = "hobby";
    }
}
