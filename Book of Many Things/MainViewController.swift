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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                self.dataViewController.loadData(response: response.result.value!)
                self.hideLoadingHUD()
            }
            
        })

    }

    @IBAction func resetData(_ sender: Any) {
        showLoadingHUD()
        dataViewController.loadData(response: nil)
        hideLoadingHUD()
    }
    
    @IBAction func saveSpellbook(_ sender: Any) {
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:"us-east-1:aee30c10-c47d-4ff7-9773-181a12eb7453")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        let jsonObject = "{\"spells\":[" + dataViewController.spells.map{$0.jsonRepresentation}.joined(separator: ",") + "]}"
        
        lambdaInvoker.invokeFunction("serverless-admin-dev-save", jsonObject: jsonObject)
            .continueWith(block: {(task: AWSTask<AnyObject>) -> Any? in
                if let error = task.error as NSError? {
                    if error.domain == AWSLambdaInvokerErrorDomain && AWSLambdaInvokerErrorType.functionError == AWSLambdaInvokerErrorType(rawValue: error.code) {
                        print("Function error: \(error.userInfo[AWSLambdaInvokerFunctionErrorKey])")
                    } else {
                        print("Error: \(error)")
                    }
                    return nil
                }
                
                // Handle response in task.result
                if let JSONDictionary = task.result as? NSDictionary {
                    print("Result: \(JSONDictionary)")
                    print("resultKey: \(JSONDictionary["resultKey"])")
                }
                return nil
                })
        
    }
    
    private func showLoadingHUD() {
        let hud = MBProgressHUD.showAdded(to: loadingView, animated: true)
        hud.label.text = "Loading..."
    }
    
    private func hideLoadingHUD() {
        MBProgressHUD.hide(for: loadingView, animated: true)
    }
    
}
