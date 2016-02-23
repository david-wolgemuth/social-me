//
//  TabBarController.swift
//  Social
//
//  Created by Shuhan Ng on 2/7/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.tabBar.items![0].image = UIImage.fontAwesomeIconWithName(.Users, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        self.tabBar.items![1].image = UIImage.fontAwesomeIconWithName(.Commenting, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        self.tabBar.items![2].image = UIImage.fontAwesomeIconWithName(.Cog, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
    }
}