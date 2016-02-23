//
//  tabBarController2.swift
//  Social
//
//  Created by Shuhan Ng on 2/19/16.
//  Copyright © 2016 Shuhan Ng. All rights reserved.
//

import UIKit


class TabBarController2: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items![0].image = UIImage.fontAwesomeIconWithName(.Search, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        self.tabBar.items![1].image = UIImage.fontAwesomeIconWithName(.UserPlus, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30))
        let count = Connection.sharedInstance.getFriendRequestCount()
        if count > 0 {
            self.tabBar.items![1].badgeValue = String(count)
        }
    }

}