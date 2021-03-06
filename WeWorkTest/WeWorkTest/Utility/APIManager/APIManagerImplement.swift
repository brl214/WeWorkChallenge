//
//  APIManagerImplement.swift
//  WeWorkTest
//
//  Created by Brandon Leeds on 1/22/17.
//  Copyright © 2017 Brandon Leeds. All rights reserved.
//

import UIKit

class APIManagerImplement: NSObject {
    
    static let GETuserInfo = "/user"
    static let GETrepos = "/user/repos"
    static let GETissues = "/repos/%@/%@/issues?state=all"
    static let PATCHissue = "/repos/%@/%@/issues/%@"
    static let POSTissue = "/repos/%@/%@/issues"

    //MARK: Login
    class func getUserInfo(completion: @escaping (_ result: Any?, _ error: Any?) -> Void) {
        let fullEndpoint = Constants.API.URL + GETuserInfo
        APIManager.makeGetRequest(fullEndpoint, params: nil) { (result, error) in
            if let user = result as? NSDictionary {
                UserInfo.currentUser.setUserInfo(user)
                
                if let message = user["message"] as? String {
                    completion(nil, message)
                } else {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    //MARK: Profile
    class func getRepos(completion: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        let fullEndpoint = Constants.API.URL + GETrepos
        APIManager.makeGetRequest(fullEndpoint, params: nil) { (result, error) in
            var userRepos = Array<RepoObject>()
            if let repos = result as? NSArray {
                // Create repo objects and add to array
                for repoDic in repos {
                    let repo = RepoObject(result: repoDic as! NSDictionary)
                    userRepos.append(repo)
                }
            }
            completion(userRepos, error)
        }
    }
    
    //MARK: Issues
    class func getRepoIssues(repoName: String, completion: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        let fullEndpoint = Constants.API.URL + String(format: GETissues, UserInfo.currentUser.welLogin!, repoName)
        APIManager.makeGetRequest(fullEndpoint, params: nil) { (result, error) in
            var repoIssues = Array<IssueObject>()
            if let issues = result as? NSArray {
                // Create issue objects and add to array
                for issueDic in issues {
                    let issue = IssueObject(result: issueDic as! NSDictionary)
                    repoIssues.append(issue)
                }
            }
            completion(repoIssues, error)
        }
    }
    
    class func patchUpdateIssue(repoName: String, number: String, title: String?, body: String?, state: String?, completion: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        let fullEndpoint = Constants.API.URL + String(format: PATCHissue, UserInfo.currentUser.welLogin!, repoName, number)
        var params : [String : Any]!
        
        // If title is nil, only the state is changing
        if title == nil {
            params = ["state" : state!]
        } else {
            params = ["title" : title!, "body" : body!]
        }
        
        APIManager.makePatchRequest(fullEndpoint, params: params) { (result, error) in
            if let issue = result as? NSDictionary {
                completion(issue, error)
            }
            completion(nil, error)
        }
    }
    
    class func createIssue(repoName: String, title: String?, body: String?, completion: @escaping (_ result: Any?, _ error: Error?) -> Void) {
        let fullEndpoint = Constants.API.URL + String(format: POSTissue, UserInfo.currentUser.welLogin!, repoName)
        let params : [String : Any] = ["title" : title!, "body" : body!]
        APIManager.makePostRequest(fullEndpoint, params: params) { (result, error) in
            if let issue = result as? NSDictionary {
                completion(issue, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
