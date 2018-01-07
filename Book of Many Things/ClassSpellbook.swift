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

class ClassSpellbook: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indexView: M4KTableIndexView!
    
    var spellDetail = SpellViewController()
    var tabName = ""
    var spells = [Spell]()
    var spellLevels = [Int]()
    var spellsFiltered = [[Spell]]()
    var sections = [String]()
    var selectedSpell = Spell(name: "Placeholder")
    var compendiumMode = false
    static var file: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return spellLevels.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "level " + sections[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spellsFiltered[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(compendiumMode){
            selectedSpell = spellsFiltered[indexPath.section][indexPath.row]
            self.performSegue(withIdentifier: "CompendiumSegue", sender: self)
        } else {
            
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
                    fatalError("Invalid destination")
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
        }
        
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
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
