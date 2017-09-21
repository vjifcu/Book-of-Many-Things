//
//  MainViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-08-16.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import AWSCore
import AWSLambda
import AWSCognito

class MainViewController: UIViewController {

    var dataViewController = TabbedViewController()
    @IBOutlet weak var loadingView: UIView!
    var spellCode = ""
    var lastGenerated = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storedCode = UserDefaults.standard.string(forKey: "spellCode"){
            spellCode = storedCode
        } else {
            spellCode = ""
        }
        if let storedDate = UserDefaults.standard.string(forKey: "lastGenerated"){
            lastGenerated = storedDate
        } else {
            lastGenerated = ""
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadData(_ sender: Any) {
        DBChooser.default().open(for: DBChooserLinkTypeDirect, from: self, completion: {(results: [Any]!) -> Void in
            guard let result = results.first as? DBChooserResult else{
                return
            }
            
            self.showLoadingHUD()
            
            Alamofire.request(result.link).responseString{ response in
                self.dataViewController.loadData(response: response.result.value!, data: nil)
                self.hideLoadingHUD()
            }
            
        })

    }

    @IBAction func resetData(_ sender: Any) {
        showLoadingHUD()
        dataViewController.loadData(response: nil, data: nil)
        hideLoadingHUD()
    }
    
    @IBAction func loadCode(_ sender: Any) {
        let alert = UIAlertController(title: "Enter a Spell Data code", message: nil, preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            
            self.showLoadingHUD()
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:"us-east-1:aee30c10-c47d-4ff7-9773-181a12eb7453")
            let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
            
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            let lambdaInvoker = AWSLambdaInvoker.default()
            
            let jsonObject = alert.textFields?.first?.text
            
            lambdaInvoker.invokeFunction("serverless-admin-dev-load", jsonObject: jsonObject)
                .continueWith(block: {(task: AWSTask<AnyObject>) -> Any? in
                    if let error = task.error as NSError? {
                        if error.domain == AWSLambdaInvokerErrorDomain && AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code) {
                            print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey])")
                        } else {
                            print("Error: \(error)")
                        }
                        return nil
                    }
                    
                    if task.result == nil || task.result as! String == "" {
                        DispatchQueue.main.async(){
                            let alertController = UIAlertController(title: "Invalid code", message: "We could not find this code in our database.\nIt does not exist or it was deleted.", preferredStyle: .alert)
                            
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            self.hideLoadingHUD()
                        }
                        return nil
                    }
                    
                    DispatchQueue.main.async(){
                        self.dataViewController.loadData(response: nil, data: task.result as! String)
                        self.hideLoadingHUD()
                    }
                    return nil
                })

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let codeViewController = segue.destination.childViewControllers.first as? CodeViewController else{
            fatalError("Segue led to an unexpected destination.")
        }
        
        codeViewController.mainViewController = self
        
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: loadingView, animated: true)
        hud.label.text = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hide(for: loadingView, animated: true)
    }
    
}
