//
//  MemeDetailViewController.swift
//  Meme Me 2.0
//
//  Created by Betz, Florian (059) on 19.03.21.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {

    var memedImage: UIImage!
    
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = memedImage {
            detailImageView.image = image
        }
        
        self.tabBarController!.tabBar.isHidden = true
    }
}
