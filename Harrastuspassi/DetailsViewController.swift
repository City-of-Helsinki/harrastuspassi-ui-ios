//
//  DetailsViewController.swift
//  Harrastuspassi
//
//  Created by Eetu Kallio on 26/06/2019.
//  Copyright © 2019 Haltu. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var data: HobbyEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let d = data {
            imageView.image = UIImage(named: "soccer-placeholder")
            titleLabel.text = d.name
            view.bringSubviewToFront(titleLabel)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPress(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
