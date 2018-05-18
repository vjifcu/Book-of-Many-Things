//
//  FirstViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-04.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit
import SWXMLHash
import Alamofire
import GoogleMobileAds

class ClassSpellbook: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, GADBannerViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indexView: M4KTableIndexView!
    @IBOutlet weak var stackView: UIStackView!
    
    var spellDetail = SpellViewController()
    var tabName = ""
    var spells = [Spell]()
    var spellLevels = [Int]()
    var spellsFiltered = [[Spell]]()
    var sections = [String]()
    var selectedSpell = Spell(name: "Placeholder")
    var selectedSpells = Set<Spell>()
    var compendiumMode = true
    var editMode = false
    var selectedSpellbook = -1
    static var file: URL? = nil
    
    var constraint : NSLayoutConstraint?
    
    var adBannerView: GADBannerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initAdMobBanner()
        
        tableView.dataSource = self
        tableView.delegate = self
        if(!compendiumMode){
            tableView.allowsMultipleSelection = true
        }
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        self.navigationItem.title = tabName
        self.navigationController!.navigationBar.isTranslucent = false
        self.navigationController!.navigationBar.barStyle = UIBarStyle.blackOpaque
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 50/255, green: 21/255, blue: 50/255, alpha: 1)
        self.navigationController!.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        
        if(stackView == nil){
            stackView = view.subviews[0] as! UIStackView
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        var constant = 0
        
        if(TabbedViewController.showingAd){
            constant = TabbedViewController.adBannerHeight
        }
        
        if(constraint != nil){
            self.view.removeConstraint(constraint!)
        }
        
        constraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: CGFloat(-constant))
        constraint!.isActive = true
        
        for subView in searchBar.subviews {
            searchBar.barStyle = UIBarStyle.blackOpaque
            searchBar.barTintColor = UIColor(red: 30/255, green: 0, blue:28/255, alpha:1)
            let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
            textFieldInsideSearchBar.textColor = UIColor.black
            textFieldInsideSearchBar.tintColor = UIColor.black
            for subViewOne in subView.subviews {
                
                if let textField = subViewOne as? UITextField {
                    
                    subViewOne.backgroundColor = UIColor(red: 250/255, green: 248/255, blue:1, alpha:1)
                    
                    //use the code below if you want to change the color of placeholder
                    let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
                    textFieldInsideUISearchBarLabel?.textColor = UIColor.blue
                }
                
            }
        }
        
        do{

            completeLoading()
            
        } catch{
            print(error.localizedDescription)
        }
        
    }
    
    func completeLoading(){
        buildData()
        
        for subViews in indexView.subviews{
            subViews.removeFromSuperview()
        }
        
        indexView.tableView = self.tableView
        if(sections.count == 0){
            indexView.indexes = ["0"]
        } else {
            indexView.indexes = sections
        }
        indexView.setup()
    }
    
    func buildData(){
        
        let searchString = searchBar.text!
        var spellData = [Spell]()
        
        self.spells.sort{
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }
        
        if !searchString.isEmpty {
            spellData = spells.filter{spell in
                let words = spell.name.lowercased().components(separatedBy: CharacterSet.whitespacesAndNewlines)
                let matchingWords = words.filter{
                    if(!searchString.hasPrefix("(")){
                        return $0.replacingOccurrences(of: "(", with: "").hasPrefix(searchString.lowercased())
                    }else{
                        return $0.hasPrefix(searchString.lowercased())
                    }
                }
                return matchingWords.count > 0
                }
        }else{
            spellData = spells
        }
        
        spellLevels.removeAll()
        spellLevels = Array(Set(spellData.map{$0.level}))
        spellLevels.sort {
            return $0 < $1
        }
        
        
        spellsFiltered.removeAll()
            
        for level in spellLevels{
            spellsFiltered.append(spellData.filter({$0.level == level}) )
        }
        
        sections.removeAll()
        
        for level in spellLevels{
            sections.append(String(level))
        }
        
        tableView.reloadData()
        
        var temp = Set(selectedSpells)
        selectedSpells.removeAll()
        
        

        for spell in spells{
                
                if(temp.contains(where:{spellname in spellname.name == spell.name})){
                    
                    for (sectionIndex, section) in spellsFiltered.enumerated(){
                        for (spellIndex, spell) in section.enumerated(){
                            if(temp.contains(where:{spellname in spellname.name == spell.name})){
                            tableView.selectRow(at: IndexPath(row: spellIndex, section: sectionIndex), animated: false, scrollPosition: .none)
                            }
                        }
                    }
                    
                    selectedSpells.insert(spell)
                }
            
        }
        
    }
    
    static func setConstraint(constant: Int){
        /*
        self.view.removeConstraint(ClassSpellbook.constraint!)
        
        let temp = NSLayoutConstraint(item: stackView,
                                      attribute: .bottom,
                                      relatedBy: .equal,
                                      toItem: self.view,
                                      attribute: .bottom,
                                      multiplier: 1,
                                      constant: -200)
        ClassSpellbook.constraint = temp
        self.view.addConstraint(temp)
        
        let temp = NSLayoutConstraint(item: stackView,
                                      attribute: .bottom,
                                      relatedBy: .equal,
                                      toItem: self.view,
                                      attribute: .bottom,
                                      multiplier: 1,
                                      constant: constant)
        ClassSpellbook.constraint = temp*/
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return spellLevels.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "level " + sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(spellsFiltered.count == 0){
            return 0
        }
        return spellsFiltered[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(compendiumMode){
            selectedSpell = spellsFiltered[indexPath.section][indexPath.row]
            self.performSegue(withIdentifier: "CompendiumSegue", sender: self)
        } else {
            selectedSpells.insert(spellsFiltered[indexPath.section][indexPath.row])
            print(spellsFiltered[indexPath.section][indexPath.row].name)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if(!compendiumMode){
            selectedSpells.remove(spellsFiltered[indexPath.section][indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.backgroundView?.backgroundColor = UIColor(red: 85/255, green: 40/255, blue: 95/255, alpha: 1)
        
        headerView.textLabel?.textColor = UIColor.white
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SomeCell")!
        
        let spell = spellsFiltered[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = spell.name
        
        return cell
        
    }    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let spellViewController = segue.destination as? SpellViewController else{
            guard let importViewController = segue.destination as? MainViewController else{
                guard let spellbookViewController = segue.destination as? MySpellbookController else {
                    guard let spellbookSpellsViewController = segue.destination as? ClassSpellbook else {
                       fatalError("Invalid destination")
                    }
                    
                    spellbookSpellsViewController.spells = TabbedViewController.spells
                    spellbookSpellsViewController.selectedSpells = Set(spells)
                    spellbookSpellsViewController.compendiumMode = false
                    spellbookSpellsViewController.editMode = true
                    spellbookSpellsViewController.selectedSpellbook = selectedSpellbook
                    return
                }
                let backButtonItem = UIBarButtonItem()
                backButtonItem.title = "Spells"
                self.navigationItem.backBarButtonItem = backButtonItem
                
                return
            }
            importViewController.dataViewController = self.navigationController?.parent as! TabbedViewController
            let popoverViewController = segue.destination
            popoverViewController.popoverPresentationController!.delegate = self
            return
        }
        
        self.navigationItem.backBarButtonItem = nil
        
        spellViewController.spell = selectedSpell
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    //Deselects cell after returning from detail view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            if(compendiumMode){
                tableView.deselectRow(at: indexPath, animated: true)
            }
        } else {
            if(selectedSpellbook != -1 && !editMode){
                spells = MySpellbookController.spellbooks[selectedSpellbook].spells
                completeLoading()
            }
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    /*
    @IBAction func saveSpellbook(_ sender: UIBarButtonItem) {
        
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let viewController = navController.viewControllers[navController.viewControllers.count - 2] as! MySpellbookController
            
            let spellbookName = "Spellbook " + String(viewController.spellbooks.count + 1)
            
            viewController.spellbooks.append(Spellbook(name: spellbookName, spells: Array(selectedSpells)))
            
        }
        
        navigationController?.popViewController(animated: true)
    }
    */
    //Search bar logic///////////////////////////////////////////////////////////
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        buildData()
        indexView.isHidden = false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBarSearchButtonClicked(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton{
            cancelButton.isEnabled = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text == ""){
            indexView.isHidden = false
        }else{
            indexView.isHidden = true
        }
        buildData()
    }
    
    @IBAction func saveSpellbook(_ sender: Any) {
        
        if(!editMode){
            
            let alert = UIAlertController(title: "Name your spellbook", message: nil, preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                
                if let navController = self.navigationController, navController.viewControllers.count >= 2 {
                    
                    var spellbookName = alert.textFields?.first?.text
                    if(spellbookName == nil || spellbookName == ""){
                        spellbookName = "Spellbook " + String(MySpellbookController.spellbooks.count + 1)
                    }
                    
                    MySpellbookController.spellbooks.append(Spellbook(name: spellbookName!, spells: Array(self.selectedSpells)))
                }
                
                self.navigationController?.popViewController(animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            MySpellbookController.spellbooks[selectedSpellbook] = Spellbook(name: MySpellbookController.spellbooks[selectedSpellbook].name, spells: Array(self.selectedSpells))
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func initAdMobBanner(){
        
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        let offset  = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.bounds.height)! + adBannerView!.frame.height
        print(UIScreen.main.bounds.height)
        adBannerView!.frame = CGRect(x: 0.0,
                                  y: UIScreen.main.bounds.height - 0 ,
                                  width: adBannerView!.frame.width,
                                  height: adBannerView!.frame.height)
        adBannerView?.delegate = self
        self.view.addSubview(adBannerView!)
        adBannerView?.adUnitID = "ca-app-pub-9438249199484491/6989308129"
        adBannerView?.rootViewController = self
        
        adBannerView?.load(GADRequest())
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        let offset  = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.bounds.height)! + adBannerView!.frame.height
        print(UIScreen.main.bounds.height)
        let translateTransform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height - offset)
        
        UIView.animate(withDuration: 0.5){
            bannerView.transform = CGAffineTransform.identity
        }
        
    }
    
    func animateConstraints(){
        
        if(constraint == nil){
            return
        }
        
        self.view.removeConstraint(constraint!)
        
        var constant = 0
        
        if(TabbedViewController.showingAd){
            constant = TabbedViewController.adBannerHeight
        }
        
        constraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: CGFloat(-constant))
        constraint!.isActive = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
}

class CellSpell: UITableViewCell {
    
    let selectedColor = UIColor(red: 240/255, green: 238/255, blue: 1, alpha: 1)
    let deselectedColor = UIColor(red: 250/255, green: 248/255, blue: 1, alpha: 1)
    let colorView = UIView()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
        tintColor = UIColor.purple
        colorView.backgroundColor = selected ? selectedColor : deselectedColor
        self.selectedBackgroundView = colorView
    }
    
}
