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
    static var spells = [Spell]()
    static var response : String? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        loadData(response: TabbedViewController.response, data: nil)
        self.tabBar.barTintColor = UIColor(red: 50/255, green: 21/255, blue: 50/255, alpha: 1)
        self.tabBar.tintColor = UIColor.white
        
        self.moreNavigationController.navigationBar.isTranslucent = false
        self.moreNavigationController.navigationBar.barStyle = UIBarStyle.blackOpaque
        self.moreNavigationController.navigationBar.barTintColor = UIColor(red: 50/255, green: 21/255, blue: 50/255, alpha: 1)
        self.moreNavigationController.navigationBar.tintColor = UIColor.white
        self.moreNavigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(response: String?, data: String?){
        do{
            if TabbedViewController.spells.count == 0, let spellData = loadSpells(){
                tabNames = [String]()
                TabbedViewController.spells = spellData
                for key in spellData{
                    tabNames.append(contentsOf: key._class as! [String])
                }
                
                writeData()
                
            } else if response == nil{
                if data == nil{
                    if let file = Bundle.main.url(forResource: "data", withExtension: "json")
                    {
                        let data = try Data(contentsOf: file)
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let spellData = json?["spells"] as! [[String: Any]]
                        
                        tabNames = [String]()
                        TabbedViewController.spells = [Spell]()
                        for key in spellData{
                            TabbedViewController.spells.append(Spell(dictionary: key))
                            tabNames.append(contentsOf: key["Classes"] as! [String])
                        }
                        
                        writeData()
                    }
                } else {
                    let formattedData = data!.data(using: .utf8)!
                    let json = try JSONSerialization.jsonObject(with: formattedData) as? [String: Any]
                    let spellData = json?["spells"] as! [[String: Any]]
                    
                    tabNames = [String]()
                    TabbedViewController.spells = [Spell]()
                    for key in spellData{
                        TabbedViewController.spells.append(Spell(dictionary: key))
                        tabNames.append(contentsOf: key["Classes"] as! [String])
                    }
                    
                    writeData()
                }

        } else {
            let spellData = SWXMLHash.parse(response!)
                
            tabNames = [String]()
            TabbedViewController.spells = [Spell]()
            for (tabNum, value) in spellData["compendium"]["spell"].all.enumerated(){
                self.tabNames.append(contentsOf: ((value["classes"].element!.text).components(separatedBy: ", ")))
                TabbedViewController.spells.append(Spell(data:value))
            }
            
            writeData()
        }
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func writeData(){
        self.tabNames = Array(Set(self.tabNames))
        
        self.tabNames.sort {
            return $0 < $1
        }
        
        TabbedViewController.spells.sort{
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
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
            tableViewController.tabName = self.tabNames[self.currentTab]
            tableViewController.spells = TabbedViewController.spells.filter{$0._class.contains(tableViewController.tabName)}
            self.currentTab += 1
        }
        
        saveSpells()
    }

    private func saveSpells(){
        NSKeyedArchiver.archiveRootObject(TabbedViewController.spells, toFile: Spell.ArchiveURL.path)
        
    }
    
    private func loadSpells() -> [Spell]?{
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: Spell.ArchiveURL.path) as? [Spell]
        if (result == nil || result!.count > 0){
            return result
        }
        return nil
    }
    
}
