//
//  TabbedViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-11.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit
import SWXMLHash
import Alamofire

class TabbedViewController: UITabBarController{

    var currentTab = 0
    var tabNames = [String]()
    var classes = [UIViewController]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do{
            if ClassSpellbook.file == nil{
            if let file = Bundle.main.url(forResource: "data", withExtension: "json")
            {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let spellData = json?["spells"] as! [String: [[String: Any]]]
                
                var counter = 0
                
                for (key, _) in spellData{
                    tabNames.append(key)
                    let storyboard = UIStoryboard(name: "Class", bundle: nil)
                    classes.append(storyboard.instantiateViewController(withIdentifier: "test"))
                    counter += 1
                }
                self.viewControllers = classes
                
                currentTab = 0
                for children in self.viewControllers!{
                    children.tabBarItem.title = tabNames[currentTab]
                    let tableViewController = children.childViewControllers.first as! ClassSpellbook
                    tableViewController.tab = currentTab
                    tableViewController.tabName = tabNames[currentTab]
                    currentTab += 1
                }
                
            }
            } else {
                Alamofire.request(ClassSpellbook.file!).responseString{ response in
                    let spellData = SWXMLHash.parse(response.result.value!)
                    
                    for value in spellData["compendium"]["spell"].all{
                        self.tabNames.append(contentsOf: ((value["classes"].element!.text).components(separatedBy: ", ")))
                    }
                    
                    
                    self.tabNames = Array(Set(self.tabNames))
                    
                    self.tabNames.sort {
                        return $0 < $1
                    }
                    
                    var counter = 0
                    
                    for _ in self.tabNames{
                        let storyboard = UIStoryboard(name: "Class", bundle: nil)
                        self.classes.append(storyboard.instantiateViewController(withIdentifier: "test"))
                        counter += 1
                    }
                    self.viewControllers = self.classes
                    
                    self.currentTab = 0
                    for children in self.viewControllers!{
                        children.tabBarItem.title = self.tabNames[self.currentTab]
                        let tableViewController = children.childViewControllers.first as! ClassSpellbook
                        tableViewController.tab = self.currentTab
                        tableViewController.tabName = self.tabNames[self.currentTab]
                        self.currentTab += 1
                    }
                    
                }
            }
        } catch{
            print(error.localizedDescription)
        }
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
