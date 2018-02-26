//
//  TabbedViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-11.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit
import SWXMLHash
import GoogleMobileAds

class TabbedViewController: UITabBarController, GADBannerViewDelegate{

    var currentTab = 0
    static var tabNames = [String]()
    var classes = [UIViewController]()
    static var spells = [Spell]()
    static var response : String? = nil
    fileprivate lazy var defaultTabBarHeight = { self.tabBar.frame.size.height }()
    var adBannerView: GADBannerView?
    static var adBannerHeight = 0
    var initComplete = false;
    var bannerAd = GADBannerView()
    static var showingAd = false;
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let TabArchiveURL = DocumentsDirectory.appendingPathComponent("tabNames")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
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
        initAdMobBanner()
        self.view.bringSubview(toFront: bannerAd)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let newTabBarHeight = defaultTabBarHeight + adBannerView!.frame.size.height
        
        
        if(TabbedViewController.showingAd){
            if(initComplete){
                tabBar.frame.origin.y = view.bounds.height - newTabBarHeight
            }
            initComplete = true;
        }

        self.view.bringSubview(toFront: bannerAd)
        
        self.currentTab = 0
        var temp = [String]()
        var changed = false
        
        for children in self.viewControllers!{
            temp.append(children.tabBarItem.title!)
            if(children.tabBarItem.title != TabbedViewController.tabNames[self.currentTab]){
                changed = true
            }
            self.currentTab += 1
        }
        
        if(changed){
            TabbedViewController.tabNames = temp
            saveTabs()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadData(response: String?, data: String?){
        do{
            if TabbedViewController.spells.count == 0, let spellData = loadSpells(){
                TabbedViewController.tabNames = [String]()
                TabbedViewController.spells = spellData
                for key in spellData{
                    TabbedViewController.tabNames.append(contentsOf: key._class as! [String])
                }
                
                writeData()
                
            } else if response == nil{
                if data == nil{
                    if let file = Bundle.main.url(forResource: "data", withExtension: "json")
                    {
                        let data = try Data(contentsOf: file)
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let spellData = json?["spells"] as! [[String: Any]]
                        
                        TabbedViewController.tabNames = [String]()
                        TabbedViewController.spells = [Spell]()
                        for key in spellData{
                            TabbedViewController.spells.append(Spell(dictionary: key))
                            TabbedViewController.tabNames.append(contentsOf: key["Classes"] as! [String])
                        }
                        
                        writeData()
                    }
                } else {
                    let formattedData = data!.data(using: .utf8)!
                    let json = try JSONSerialization.jsonObject(with: formattedData) as? [String: Any]
                    let spellData = json?["spells"] as! [[String: Any]]
                    
                    TabbedViewController.tabNames = [String]()
                    TabbedViewController.spells = [Spell]()
                    for key in spellData{
                        TabbedViewController.spells.append(Spell(dictionary: key))
                        TabbedViewController.tabNames.append(contentsOf: key["Classes"] as! [String])
                    }
                    
                    writeData()
                }

        } else {
            let spellData = SWXMLHash.parse(response!)
                
            TabbedViewController.tabNames = [String]()
            TabbedViewController.spells = [Spell]()
            for (tabNum, value) in spellData["compendium"]["spell"].all.enumerated(){
                TabbedViewController.tabNames.append(contentsOf: ((value["classes"].element!.text).components(separatedBy: ", ")))
                TabbedViewController.spells.append(Spell(data:value))
            }
            
            writeData()
        }
        }catch{
            fatalError(error.localizedDescription)
        }
    }
    
    func writeData(){
        
        let savedTabNames = loadTabs()
        
        if(savedTabNames == nil){
        
            TabbedViewController.tabNames = Array(Set(TabbedViewController.tabNames))
        
            TabbedViewController.tabNames.sort {
                return $0 < $1
            }
        } else {
            TabbedViewController.tabNames = savedTabNames!
        }
        
        TabbedViewController.spells.sort{
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }
        
        self.classes = [UIViewController]()
        for _ in TabbedViewController.tabNames{
            let storyboard = UIStoryboard(name: "Class", bundle: nil)
            self.classes.append(storyboard.instantiateViewController(withIdentifier: "test"))
        }
        self.viewControllers = self.classes
        
        self.currentTab = 0
        for children in self.viewControllers!{
            children.tabBarItem.title = TabbedViewController.tabNames[self.currentTab]
            let tableViewController = children.childViewControllers.first as! ClassSpellbook
            tableViewController.tabName = TabbedViewController.tabNames[self.currentTab]
            tableViewController.spells = TabbedViewController.spells.filter{$0._class.contains(tableViewController.tabName)}
            self.currentTab += 1
        }
        
        saveSpells()
    }

    func initAdMobBanner(){
        
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        
        adBannerView?.frame = CGRect(x: 0.0,
                                     y: (view.bounds.height - 0),
                                     width: self.view.bounds.size.width,
                                     height: adBannerView!.frame.size.height)

        adBannerView?.delegate = self
        
        TabbedViewController.adBannerHeight = Int(adBannerView!.frame.size.height)
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5)
        
        self.view.addSubview(adBannerView!)
        self.view.bringSubview(toFront: adBannerView!)
        
        adBannerView?.adUnitID = "ca-app-pub-9438249199484491/6989308129"
        adBannerView?.rootViewController = self
        
        adBannerView?.load(GADRequest())
        
        bannerAd = adBannerView!
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        TabbedViewController.showingAd = true;
        let translateTransform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height - 0)
        bannerView.transform = translateTransform
        /*
         UIView.animate(withDuration: 1.5){
         
         //self.tabBar.frame.size.height = self.defaultTabBarHeight + self.adBannerView!.frame.size.height + 50
         }
         */
        
        
        let newTabBarHeight = self.defaultTabBarHeight + self.adBannerView!.frame.size.height
        
        UIView.animate(withDuration: 0.5, delay: 0, animations: {
            var bannerViewFrame = bannerView.frame
            var tabBarFrame = self.tabBar.frame
            
            bannerViewFrame.origin.y = UIScreen.main.bounds.height - CGFloat(TabbedViewController.adBannerHeight)
            tabBarFrame.origin.y = self.view.frame.size.height - newTabBarHeight
            
            self.adBannerView!.frame = bannerViewFrame
            self.tabBar.frame = tabBarFrame
            
        })
        
        for children in self.viewControllers!{
            let tableViewController = children.childViewControllers.first as! ClassSpellbook
            tableViewController.animateConstraints()
            self.currentTab += 1
        }
        
        MySpellbookController.instance?.animateConstraints()
        
        /*
         let newTabBarHeight = defaultTabBarHeight + adBannerView!.frame.size.height
         
         var newFrame = tabBar.frame
         newFrame.size.height = newTabBarHeight
         newFrame.origin.y = view.frame.size.height - newTabBarHeight
         
         tabBar.frame = newFrame
         */
        self.view.bringSubview(toFront: bannerAd)
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("Fail to receive ads")
        print(error)
    }
    
    private func saveTabs(){
        NSKeyedArchiver.archiveRootObject(TabbedViewController.tabNames, toFile: TabbedViewController.TabArchiveURL.path)
    }
    
    private func loadTabs() -> [String]?{
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: TabbedViewController.TabArchiveURL.path) as? [String]
        if (result == nil || result!.count > 0){
            return result
        }
        return nil
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
