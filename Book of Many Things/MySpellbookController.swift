//
//  MySpellbookController.swift
//  
//
//  Created by Victor Jifcu on 2017-12-28.
//

import UIKit

class MySpellbookController: UITableViewController {

    var spellbooks = [Spellbook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Spellbooks"
        spellbooks.append(Spellbook(name:"Spellbook 1", spells: [Spell]()));
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return spellbooks.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpellbookCell", for: indexPath)

        if(indexPath.row == spellbooks.count)
        {
            cell.textLabel!.text = "➕ New Spellbook"
            cell.backgroundColor = UIColor(red: 250/255, green: 225/255, blue: 1, alpha: 1)
            return cell
        }
        
        cell.textLabel!.text = spellbooks[indexPath.row].name

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == spellbooks.count){
            return false
        }
        return true
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
        guard let cell = sender as? UITableViewCell else {
            return
        }
        
        if let navController = self.navigationController, navController.viewControllers.count >= 2 {
            let viewController = navController.viewControllers[navController.viewControllers.count - 2] as! ClassSpellbook
            let tabBarController = viewController.tabBarController as! TabbedViewController
            
            spellbookViewController.spells = tabBarController.spells
            
        }
        
        spellbookViewController.tabName = cell.textLabel!.text!
        
    }
    

}
