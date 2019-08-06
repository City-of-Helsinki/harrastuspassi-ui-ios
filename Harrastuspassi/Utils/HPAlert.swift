//
//  HPAlert.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 01/08/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import Foundation
import UIKit

class HPAlert {
    
    class func presentAlertWithTitle(_ title:String, message:String, presenter:UIViewController, completion: ((UIAlertAction) -> Void)?) -> Void {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: completion)
        alertController.addAction(alertAction)
        presenter.present(alertController, animated: true, completion: nil)
    }
}
