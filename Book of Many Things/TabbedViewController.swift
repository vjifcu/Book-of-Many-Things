//
//  TabbedViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-11.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit
import SWXMLHash

class TabbedViewController: UITabBarController{

    var currentTab = 0
    var tabNames = [String]()
    var classes = [UIViewController]()
    var spells = [Spell]()
    static var response : String? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData(response: TabbedViewController.response)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(response: String?){
        do{
        if response == nil{
            if let file = Bundle.main.url(forResource: "data", withExtension: "json")
            {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let spellData = json?["spells"] as! [[String: Any]]
                
                tabNames = [String]()
                spells = [Spell]()
                for key in spellData{
                    spells.append(Spell(dictionary: key))
                    tabNames.append(contentsOf: key["classes"] as! [String])
                }
                
                tabNames = Array(Set(self.tabNames))
                
                tabNames.sort {
                    return $0 < $1
                }
                
                self.classes = [UIViewController]()
                for _ in tabNames{
                    let storyboard = UIStoryboard(name: "Class", bundle: nil)
                    classes.append(storyboard.instantiateViewController(withIdentifier: "test"))
                }
                
                self.viewControllers = classes
                
                currentTab = 0
                for children in self.viewControllers!{
                    children.tabBarItem.title = tabNames[currentTab]
                    let tableViewController = children.childViewControllers.first as! ClassSpellbook
                    tableViewController.tab = currentTab
                    tableViewController.tabName = tabNames[currentTab]
                    tableViewController.spells = spells.filter{$0._class.contains(tableViewController.tabName)}
                    currentTab += 1
                }
                
            }
        } else {
            let spellData = SWXMLHash.parse(response!)
            
            tabNames = [String]()
            spells = [Spell]()
            for (tabNum, value) in spellData["compendium"]["spell"].all.enumerated(){
                self.tabNames.append(contentsOf: ((value["classes"].element!.text).components(separatedBy: ", ")))
                self.spells.append(Spell(data:value))
            }
            
            self.tabNames = Array(Set(self.tabNames))
            
            self.tabNames.sort {
                return $0 < $1
            }
            
            self.classes = [UIViewController]()
            for _ in self.tabNames{
                let storyboard = UIStoryboard(name: "Class", bundle: nil)
                self.classes.append(storyboard.instantiateViewController(withIdentifier: "test"))
            }
            self.viewControllers = self.classes
            
            self.currentTab = 0
            for children in self.viewControllers!{
                children.tabBarItem.title = self.tabNames[self.currentTab]
                let tableViewController = children.childViewControllers.first as! ClassSpellbook
                tableViewController.tab = self.currentTab
                tableViewController.tabName = self.tabNames[self.currentTab]
                tableViewController.spells = self.spells.filter{$0._class.contains(tableViewController.tabName)}
                self.currentTab += 1
            }

        }
        }catch{
            fatalError(error.localizedDescription)
        }
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
