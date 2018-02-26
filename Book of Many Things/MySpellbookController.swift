//
//  MySpellbookController.swift
//  
//
//  Created by Victor Jifcu on 2017-12-28.
//

import UIKit
import GoogleMobileAds

class MySpellbookController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    static var spellbooks = [Spellbook]()
    var selectedSpellbook = 0
    var adBannerView: GADBannerView?
    var constraint : NSLayoutConstraint?
    static var instance : MySpellbookController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MySpellbookController.instance = self
        tableView.dataSource = self
        tableView.delegate = self
        /*
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView?.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        adBannerView?.delegate = self
        adBannerView?.rootViewController = self
        
        adBannerView?.load(GADRequest())
 */
        
        var constant = 0
        
        if(TabbedViewController.showingAd){
            constant = TabbedViewController.adBannerHeight
        }
        
        if(constraint != nil){
            self.view.removeConstraint(constraint!)
        }
        
        constraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: CGFloat(-constant))
        constraint!.isActive = true
        
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

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MySpellbookController.spellbooks.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.row == MySpellbookController.spellbooks.count){
            return false
        }
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = MySpellbookController.spellbooks[sourceIndexPath.row]
        MySpellbookController.spellbooks.remove(at: sourceIndexPath.row)
        MySpellbookController.spellbooks.insert(movedObject, at: destinationIndexPath.row)
        self.tableView.reloadData()
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            MySpellbookController.spellbooks.remove(at: indexPath.row)
            saveSpellbooks()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
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
    

    func adViewDidReceiveAd(_ bannerView: GADBannerView!) {
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.tableHeaderView?.frame = bannerView.frame
            bannerView.transform = CGAffineTransform.identity
            self.tableView.tableHeaderView = bannerView
        }
        
    }
    
    func adView(_ bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("Fail to receive ads")
        print(error)
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
        
        constraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: CGFloat(-constant))
        constraint!.isActive = true
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
}
