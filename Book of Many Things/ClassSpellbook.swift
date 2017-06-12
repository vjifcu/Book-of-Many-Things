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
    

    var tab = 0
    var tabName = ""
    var spells = [[Spell]]()
    var spellLevels = [Int]()
    var spellsFiltered = [[Spell]]()
    
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
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return spellLevels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
            }
            else{
                cell.accessoryType = .checkmark
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level " + String(spellLevels[section])
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
        buildData()
    }
    
}
