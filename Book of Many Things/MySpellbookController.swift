//
//  MySpellbookController.swift
//  
//
//  Created by Victor Jifcu on 2017-12-28.
//

import UIKit

class MySpellbookController: UITableViewController {

    static var spellbooks = [Spellbook]()
    var selectedSpellbook = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MySpellbookController.spellbooks = loadSpellbooks() ?? [Spellbook]();
        
        self.title = "My Spellbooks"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        saveSpellbooks()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MySpellbookController.spellbooks.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpellbookCell", for: indexPath)

        if(indexPath.row == MySpellbookController.spellbooks.count)
        {
            cell.textLabel!.text = "➕ New Spellbook"
            cell.backgroundColor = UIColor(red: 250/255, green: 225/255, blue: 1, alpha: 1)
            return cell
        }
        
        cell.textLabel!.text = MySpellbookController.spellbooks[indexPath.row].name
        cell.backgroundColor = UIColor(red: 250/255, green: 248/255, blue: 1, alpha: 1)

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == MySpellbookController.spellbooks.count){
            return false
        }
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSpellbook = indexPath.row
        if (indexPath.row == MySpellbookController.spellbooks.count){
            self.performSegue(withIdentifier: "newSpellbookSegue", sender: self)
        } else {
            self.performSegue(withIdentifier: "showSpellbookSegue", sender: self)
        }
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let spellbookViewController = segue.destination as? ClassSpellbook else {
            return
        }
        
        var tabTitle = ""
        
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            if(selectedSpellbook == MySpellbookController.spellbooks.count){
                let viewController = navController.viewControllers[navController.viewControllers.count - 2] as! ClassSpellbook
                let tabBarController = viewController.tabBarController as! TabbedViewController
                
                spellbookViewController.spells = TabbedViewController.spells
                spellbookViewController.compendiumMode = false;
                tabTitle = "New Spellbook"
            } else {
                spellbookViewController.spells = MySpellbookController.spellbooks[selectedSpellbook].spells
                tabTitle = MySpellbookController.spellbooks[selectedSpellbook].name
                spellbookViewController.compendiumMode = true;
                spellbookViewController.selectedSpellbook = selectedSpellbook
            }
            
        }
        
        spellbookViewController.tabName = tabTitle
        
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            MySpellbookController.spellbooks.remove(at: indexPath.row)
            saveSpellbooks()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    public func saveSpellbooks(){
        NSKeyedArchiver.archiveRootObject(MySpellbookController.spellbooks, toFile: Spellbook.ArchiveURL.path)
        
    }
    
    private func loadSpellbooks() -> [Spellbook]?{
        let result = NSKeyedUnarchiver.unarchiveObject(withFile: Spellbook.ArchiveURL.path) as? [Spellbook]
        if (result == nil || result!.count > 0){
            return result
        }
        return nil
    }
    

}
