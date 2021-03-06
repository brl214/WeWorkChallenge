//
//  ProfileVC.swift
//  WeWorkTest
//
//  Created by Brandon Leeds on 1/22/17.
//  Copyright © 2017 Brandon Leeds. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileVC: RootVC, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, IssuesDelegate {
    
    @IBOutlet weak var IBavatar : UIImageView!
    @IBOutlet weak var IBusername : UILabel!
    @IBOutlet weak var IBname : UILabel!
    @IBOutlet weak var IBbio : UILabel!
    @IBOutlet weak var IBcollectionView : UICollectionView!
    @IBOutlet weak var IBfollowers : CustomLabel!
    @IBOutlet weak var IBfollowing : CustomLabel!
    @IBOutlet weak var IBrepositories : CustomLabel!
    
    var welRepos = Array<RepoObject>()
    
    var welIssuesNavController : UINavigationController!
    var welIssuesController : IssuesVC!
    var welDimOverlay : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Would not call api everytime but did this for the sake of time
    override func viewWillAppear(_ animated: Bool) {
        setUpUI()
        getRepos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UI Setup
    // Setup profile UI elements
    func setUpUI() {
        // Register custom cells with collection view
        registerCustomCells()
        
        navigationController?.isNavigationBarHidden = true
        if UserInfo.currentUser.welAvatarURL != nil {
            let url = URL(string: UserInfo.currentUser.welAvatarURL!)
            IBavatar.kf.setImage(with: url)
            IBavatar.layer.masksToBounds = true
            IBavatar.layer.cornerRadius = 5
        }
        
        IBusername.text = UserInfo.currentUser.welLogin
        IBname.text = UserInfo.currentUser.welName
        IBbio.text = UserInfo.currentUser.welBio
        IBfollowers.text = String(format: "%i", UserInfo.currentUser.welFollowers)
        IBfollowing.text = String(format: "%i", UserInfo.currentUser.welFollowing)
        // Custom method to make label circular
        IBfollowers.setCircular()
        IBfollowing.setCircular()
        IBrepositories.setCircular()
    }
    
    func registerCustomCells() {
        IBcollectionView!.register(UINib(nibName: "RepoCell", bundle: nil), forCellWithReuseIdentifier: "repoCell")
    }
    
    //MARK: API Call
    
    func getRepos() {
        showLoadingView()
        APIManagerImplement.getRepos { (repos, error) in
            self.hideLoadingView()
            if error == nil {
                if let userRepos = repos as? Array<RepoObject> {
                    self.welRepos = userRepos
                    self.IBrepositories.text = String(format: "%i", self.welRepos.count)
                    self.IBcollectionView.reloadData()
                }
            } else {
                self.showStandardAlert("Error", message: error?.localizedDescription, style: .alert)
            }
        }
    }
    
    //MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return welRepos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let repo = welRepos[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "repoCell", for: indexPath) as! RepoCell
        cell.setUpCell(repo: repo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let repo = welRepos[indexPath.row]
        showIssues(repo: repo)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 5, 5, 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 320, height: 150)
    }
}
