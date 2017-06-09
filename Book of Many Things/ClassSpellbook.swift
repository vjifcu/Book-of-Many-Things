//
//  FirstViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-06-04.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit

class ClassSpellbook: UITableViewController {
    
    struct Spell{
        let name: String
        let level: Int
        let _class: [String]
        
        init(dictionary: [String: Any]){
            self.name = dictionary["name"] as! String
            self.level = dictionary["level"] as! Int
            self._class = dictionary["class"] as! [String]
        }
    }
    
    var spells = [Spell]()
    var spellLevels = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
        if let file = Bundle.main.url(forResource: "data", withExtension: "json")
        {
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let spells = json?["spells"] as! [[String: Any]]
            self.spells = spells.map{
                Spell(dictionary: $0)
            }
            spellLevels = Array(Set(self.spells.map{$0.level}))
            spellLevels.sort {
                return $0 < $1
            }
        }
        } catch{
            print(error.localizedDescription)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Set(spells.map{$0.level}).count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Level " + String(spellLevels[section])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spells.filter({$0.level == (spellLevels[section])}).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SomeCell", for: indexPath) as UITableViewCell
        
        let spell = spells.filter({$0.level == spellLevels[indexPath.section]})[indexPath.row]
        
        cell.textLabel?.text = spell.name
        
        return cell
        
    }

}
