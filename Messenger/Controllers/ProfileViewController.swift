//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Onur Osman Güler on 17.07.2020.
//  Copyright © 2020 Onur Osman Güler. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    private let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // un highlight the cell
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            // Facebook logout
            FBSDKLoginKit.LoginManager().logOut()
            
            // Google log out
            GIDSignIn.sharedInstance()?.signOut()
            
            // Logout
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                // Facebook logout  - if kontrolune gerek yok hata alınmıyor
                //                if AccessToken.current != nil {
                //                    let loginManager = LoginManager()
                //                    loginManager.logOut()
                //                }
                
                // show login screen
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                // animated false olduğunda conversation ekranının görünme süresi biraz daha kısa olur
                strongSelf.present(nav, animated: true)
            }
            catch {
                print("Failed to log out!")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
}
