//
//  TabbedViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-11.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class TabbedViewController: UITabBarController{

    var currentTab = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for children in self.viewControllers!{
            let tableViewController = children.childViewControllers.first as! ClassSpellbook
            tableViewController.tab = currentTab
            currentTab += 1
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
