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

let bucketName1 = "minespace"       // Private
let bucketName2 = "amazonnews3"     // Public
let bucketName3 = "testsuri"        // Public

let cognitoRegion = AWSRegionType.APSouth1  
let cognitoIdentityPoolId = "ap-south-1:84582160-1320-4336-8231-089aafe5ad2c"

class ViewController: UIViewController {

    @IBOutlet var image: UIImageView!
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
                return
            }
            let tokenString = accessToken
            self.tokens =  ["graph.facebook.com": tokenString]
           
            // CALL AMAZON
            let customIdentityProvider = CustomIdentityProvider(tokens: self.tokens)
            // reason for your s3 bucket
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: cognitoRegion,
                                                                    identityPoolId: cognitoIdentityPoolId,
                                                                    identityProviderManager: customIdentityProvider)
            let configuration = AWSServiceConfiguration(region: cognitoRegion,
                                                        credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            // GET ID
            credentialsProvider.getIdentityId().continueWith(block: { (task) in
                guard task.error == nil else {  return nil }
                // We've got a session and now we can access AWS service via default()
                // e.g.: let cognito = AWSCognito.default()
                
                self.download()
                return task
                
            })
        }
    }
 
    func up(){
        let transferManager = AWSS3TransferManager.default()
        
        let path = Bundle.main.path(forResource: "my", ofType: "txt")
        let uploadingFileURL = URL(fileURLWithPath: path!)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.bucket = bucketName1
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
    
    func download(){
        let transferManager = AWSS3TransferManager.default()
        
        let downloadingFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("my.jpg")
        
        let downloadRequest = AWSS3TransferManagerDownloadRequest()
        
        downloadRequest?.bucket = bucketName1
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
            let data = NSData(contentsOf: (downloadRequest?.downloadingFileURL)!)
            
            if let d = data {
                let image = UIImage(data: d as Data)
                OperationQueue.main.addOperation {
                    self.image?.image = image
                }
            }
            
            let downloadOutput = task.result
            return nil
            
        }
    }
  
}



