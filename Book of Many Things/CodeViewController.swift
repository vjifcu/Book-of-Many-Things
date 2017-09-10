//
//  CodeViewController.swift
//  Book of Many Things
//
//  Created by Victor Jifcu on 2017-09-09.
//  Copyright © 2017 Victor Jifcu. All rights reserved.
//

import UIKit
import AWSCore
import AWSLambda
import AWSCognito
import MBProgressHUD

class CodeViewController: UIViewController {

    var mainViewController = MainViewController()
    @IBOutlet weak var codeLabel: UITextField!
    @IBOutlet var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        codeLabel.text = mainViewController.spellCode
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveSpellbook(_ sender: Any) {
        
        self.showLoadingHUD()
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,identityPoolId:"us-east-1:aee30c10-c47d-4ff7-9773-181a12eb7453")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let lambdaInvoker = AWSLambdaInvoker.default()
        
        let jsonObject = "{\"spells\":[" + mainViewController.dataViewController.spells.map{$0.jsonRepresentation}.joined(separator: ",") + "]}"
        
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
                
                NSUserDefaults.standardUserDefaults()
                
                // Handle response in task.result
                self.mainViewController.spellCode = task.result as! String
                DispatchQueue.main.async(){
                    self.hideLoadingHUD()
                    self.codeLabel.text = task.result as! String
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
