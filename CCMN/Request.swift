//
//  Request.swift
//  CCMN
//
//  Created by Olga SKULSKA on 11/21/18.
//  Copyright © 2018 Olga SKULSKA. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class Request{
    
    var baseURL : String
    var passwd : String
    var user  : String
    var auth: String
    
    init(baseURL : String, user : String, passwd : String){
        
        self.baseURL = "\(baseURL)"
        self.passwd = passwd
        self.user = user
        self.auth = "\(user):\(passwd)".base64Encoded()!
    }

    
    private static var Manager : Alamofire.SessionManager = {
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "cisco-cmx": .disableEvaluation,
            "cisco-presence": .disableEvaluation,
            "cmxloactionsandbox": .disableEvaluation
        ]
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        let manager = Alamofire.SessionManager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
    
    
    private func setDelegate(){
        
        let delegate: Alamofire.SessionDelegate = Request.Manager.delegate
        delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = Request.Manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
    }
    
    
    public func makeRequest(url: String, completion:@escaping (JSON) -> Void){
        
        // Handle Authentication challenge
        setDelegate()
        
        //Web service Request
        let header: HTTPHeaders = ["Accept": "application/json", "Authorization": "Basic \(auth)"]
        Request.Manager.request(baseURL + url, method: .get, encoding: JSONEncoding(options: []),headers :header).responseJSON { response in
            if let j = response.result.value {
                completion(JSON(j))
            }
            else{
                completion(JSON(response.error!))
            }
        }
    }
    
    
    public func getImg(url: String, imgName : String, completion:@escaping (String) -> Void){
        
        // Handle Authentication challenge
        setDelegate()
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(imgName)

            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let headers: HTTPHeaders = ["Accept": "image/*", "Authorization": "Basic \(auth)"]
        Request.Manager.download(baseURL+url, method: .get, headers: headers, to: destination).response { response in
            if response.error == nil, let imagePath = response.destinationURL?.path {
                completion(imagePath)
            }else {
                completion(String())
            }
            
        }
    }
    
    
    public func getParam(url:String, param : [String:Any], completion:@escaping (JSON) -> Void){
            
        // Handle Authentication challenge
        let delegate: Alamofire.SessionDelegate = Request.Manager.delegate
        delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = Request.Manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
            
        //Web service Request
        let header: HTTPHeaders = ["Authorization": "Basic \(auth)"]
        Request.Manager.request(baseURL + url, method: .get, parameters: param, headers: header).validate().responseJSON { response in
            if let j = response.result.value {
                completion(JSON(j))
            }
            else{
                completion(JSON(response.error!))
            }
        }
    }
}

extension String {

    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
}


