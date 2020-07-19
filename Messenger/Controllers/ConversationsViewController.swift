//
//  ViewController.swift
//  Messenger
//
//  Created by Onur Osman Güler on 17.07.2020.
//  Copyright © 2020 Onur Osman Güler. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // view.backgroundColor = .red
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Eğer kullanıcı login olmamışsa login ekranına yönlendir
        //        let isLogggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        //
        //        if !isLogggedIn {
        //            let vc = LoginViewController()
        //            let nav = UINavigationController(rootViewController: vc)
        //            nav.modalPresentationStyle = .fullScreen
        //            // animated false olduğunda conversation ekranının görünme süresi biraz daha kısa olur
        //            present(nav, animated: false)
        //        }
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            // animated false olduğunda conversation ekranının görünme süresi biraz daha kısa olur
            present(nav, animated: false)
        }
    }
}

