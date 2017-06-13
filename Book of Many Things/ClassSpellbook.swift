//
//  FirstViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-04.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class ClassSpellbook: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var indexView: M4KTableIndexView!
    
    var tab = 0
    var tabName = ""
    var spells = [[Spell]]()
    var spellLevels = [Int]()
    var spellsFiltered = [[Spell]]()
    var sections = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        self.navigationItem.title = tabName
        
        
        
        do{
        if let file = Bundle.main.url(forResource: "data", withExtension: "json")
        {
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let spellData = json?["spells"] as! [String: [[String: Any]]]
            for (key, value) in spellData{
                self.spells.append(value.map{
                    Spell(dictionary: $0)
                })                
            }
            
            buildData()
            
            indexView.tableView = self.tableView
            indexView.indexes = sections
            indexView.setup()
            
        }
        } catch{
            print(error.localizedDescription)
        }
        
    }
    
    func buildData(){
        
        let searchString = searchBar.text!
        var spellData = [Spell]()
        
        if !searchString.isEmpty {
            spellData = spells[tab].filter{spell in
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
            spellData = spells[tab]
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SomeCell")!
        
        let spell = spellsFiltered[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = spell.name
        
        return cell
        
    }    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let spellViewController = segue.destination as? SpellViewController else{
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectedSpellCell = sender as? UITableViewCell else{
            fatalError("Unexpected sender: \(String(describing: sender))")
        }

        guard let indexPath = tableView.indexPath(for: selectedSpellCell) else{
            fatalError("The selected cell is not being displayed by the table")
        }
        let spell = spellsFiltered[indexPath.section][indexPath.row]
        
        spellViewController.spell = spell
        
    }
    
    //Deselects cell after returning from detail view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
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
