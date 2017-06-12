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
    var tabNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            if let file = Bundle.main.url(forResource: "data", withExtension: "json")
            {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let spellData = json?["spells"] as! [String: [[String: Any]]]
                
                var counter = 0
                
                for (key, _) in spellData{
                    tabNames.append(key)
                    counter += 1
                }
            }
        } catch{
            print(error.localizedDescription)
        }

        for children in self.viewControllers!{
            let tableViewController = children.childViewControllers.first as! ClassSpellbook
            tableViewController.tab = currentTab
            tableViewController.tabName = tabNames[currentTab]
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
