//
//  LoginViewController.swift
//  Messenger
//
//  Created by Onur Osman Güler on 17.07.2020.
//  Copyright © 2020 Onur Osman Güler. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 5
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        // field.setLeftPaddingPoints(10)
        // field.setRightPaddingPoints(10)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.rightViewMode = .always
        field.backgroundColor = .white
        field.placeholder = "Email Address..."
        return field
    }();
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 5
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        // field.setLeftPaddingPoints(10)
        // field.setRightPaddingPoints(10)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0)) // soldan padding ekle
        field.leftViewMode = .always
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0)) // sağdan padding ekle
        field.rightViewMode = .always
        field.backgroundColor = .white
        field.placeholder = "Password..."
        field.isSecureTextEntry = true // içindeki texti parola olarak göster
        return field
    }();
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .blue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        // button.titleLabel?.font = UIFont.systemFont(ofSize: button.titleLabel!.font.pointSize, weight: UIFont.Weight.semibold)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let size = scrollView.width / 3
        
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 60,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60 ,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60 ,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60 ,
                                   height: 52)
    }
    
    @objc private func loginButtonTapped() {
        // Hide keyboard
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        // Form validation
        guard let email = emailField.text, let password = passwordField.text,
            !email.isEmpty, !password.isEmpty, password.count >= 6 else {
                alertUserLoginError()
                return
        }
        
        // Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to sign in user with email: \(email)")
                return
            }
            
            let user = result.user
            
            print("User \(user) succesfully sign in to app.")
            
            // Go back the main screen - conversations
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    private func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dissmiss",
                                      style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        // Register ekranına yönlendir
        let vc = RegisterViewController()
        vc.title = "Create Account"
        
        // Login ekranına geri dönmüyor login ekranını açtığı gibi açıyor
        // let nav = UINavigationController(rootViewController: vc)
        // nav.modalPresentationStyle = .fullScreen
        // present(nav, animated: false)
        
        // Login ekranına geri dönebilmek için bu şekilde yönlendirdik
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            // email field yazıldıktan sonra entera basıldığında password fielda focusla
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            // pasword field yazıldıktan sonra done a basıldığında otomatik olarak login butonuna tıkla
            loginButtonTapped()
        }
        
        return true
    }
    
}
