//
//  ViewController.swift
//  Salt
//
//  Created by surendra kumar on 11/8/17.
//  Copyright © 2017 weza. All rights reserved.
//
// amazonnews3.s3.amazonaws.com

import UIKit
import FBSDKLoginKit
import AWSAuthCore
import AWSDynamoDB
import AWSCognito
import AWSS3
let uploedurl = "/Users/surendrakumar/Library/Developer/CoreSimulator/Devices/AB8A49E4-CD45-4C9B-A552-8EA3B1190CCB/data/Containers/Data/Application/C0A54AEE-8B0A-42C3-A3D4-75C4CEC5B5BA/tmp/13554167-458B-4E32-BFA6-89B7FFC69C12.jpeg"
let sec = "/private/var/mobile/Containers/Data/Application/5B0BC72F-5776-4C57-A95E-3898A805E8F7/tmp/04FEF887-61C1-4038-BACA-3B1546E2E498.jpeg"

class ViewController: UIViewController {

    var tokens : [String:String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.up()
        
       
    }

    

    @IBAction func fb(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: nil, from: self) { result, error in
            guard error == nil else { return }
            let fbloginresult : FBSDKLoginManagerLoginResult = result!
            
            guard !fbloginresult.isCancelled else {return}
            guard let accessToken = FBSDKAccessToken.current().tokenString else {
              print("Error ttikfx")
                return
            }
            let tokenString = accessToken
            self.tokens =  ["graph.facebook.com": tokenString]
            
            // CALL AMAZON
            let customIdentityProvider = CustomIdentityProvider(tokens: self.tokens)
            // reason for your s3 bucket
            let cognitoRegion = AWSRegionType.APSouth1  // Region of your Cognito Identity Pool
            let cognitoIdentityPoolId = "us-east-1:f0db97ae-fe65-4005-a69f-a79006de7e2c"
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: cognitoRegion,
                                                                    identityPoolId: cognitoIdentityPoolId,
                                                                    identityProviderManager: customIdentityProvider)
            let configuration = AWSServiceConfiguration(region: cognitoRegion,
                                                        credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            // GET ID
            credentialsProvider.getIdentityId().continueWith(block: { (task) in
                guard task.error == nil else { print(task.error ?? "NO ERROR"); return nil }
                // We've got a session and now we can access AWS service via default()
                // e.g.: let cognito = AWSCognito.default()
                print("SUCCESS")
                self.up()
                return task
                
            })
        }
    }
 
    func up(){
        let transferManager = AWSS3TransferManager.default()
        
        let path = Bundle.main.path(forResource: "my", ofType: "txt")
        let uploadingFileURL = URL(fileURLWithPath: path!)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = "amazonnews3"
        uploadRequest?.key = "12.txt"
        uploadRequest?.body = uploadingFileURL
        
        
        transferManager.upload(uploadRequest!).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as? NSError {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                    }
                } else {
                    print("Error uploading: \(uploadRequest?.key) Error: \(error)")
                }
                return nil
            }
            
            let uploadOutput = task.result
            print("Upload complete for: \(uploadRequest?.key)")
            return nil
        })
    }
    func upload(){
        let transferManager = AWSS3TransferManager.default()
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("myImage.jpg")
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        
        downloadRequest?.bucket = "amazonnews3"
        downloadRequest?.key = "my.jpg"
        downloadRequest?.downloadingFileURL = downloadingFileURL
        print(downloadRequest?.downloadingFileURL)
        transferManager.download(downloadRequest!).continueWith { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error as? NSError {
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading: \(downloadRequest?.key) Error: \(error)")
                    }
                } else {
                    print("Error downloading: \(downloadRequest?.key) Error: \(error)")
                }
                return nil
            }
            print("Download complete for: \(downloadRequest?.key)")
            let downloadOutput = task.result
            return nil
            
        }
    }
  
}



