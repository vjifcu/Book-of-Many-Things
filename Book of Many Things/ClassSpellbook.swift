//
//  FirstViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-04.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class ClassSpellbook: UITableViewController, UISearchResultsUpdating{
    
    var searchController: UISearchController!
    
    var tab = 0
    var spells = [[Spell]]()
    var spellLevels = [Int]()
    var spellsFiltered = [[Spell]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        self.searchController.hidesNavigationBarDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
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
            
        }
        } catch{
            print(error.localizedDescription)
        }
        
    }
    
    func buildData(){
        
        let searchString = searchController.searchBar.text!
        var spellData = [Spell]()
        
        if !searchString.isEmpty {
            spellData = spells[tab].filter{spell in
                let words = spell.name.lowercased().components(separatedBy: CharacterSet.whitespacesAndNewlines)
                let matchingWords = words.filter{
                    $0.hasPrefix(searchString.lowercased())
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
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return spellLevels.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level " + String(spellLevels[section])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spellsFiltered[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SomeCell")!
        
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

        guard let indexPath = self.tableView.indexPath(for: selectedSpellCell) else{
            fatalError("The selected cell is not being displayed by the table")
        }
        let spell = spellsFiltered[indexPath.section][indexPath.row]
            
        spellViewController.spell = spell
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        buildData()
    }
    
}
