//
//  LoginViewController.swift
//  Messenger
//
//  Created by Onur Osman Güler on 17.07.2020.
//  Copyright © 2020 Onur Osman Güler. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email,public_profile"]
        return button
    }()
    
    private let googleLoginButton = GIDSignInButton()
    
    // Google sign in app delegate te bulunduğu için bir şekilde bunu login controllera bildirmemiz gerekiyor
    // çünkü login olduğunda login ekranını kapatıp ana ekrana geçeceğiz
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver  = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            // Go back the main screen - conversations
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
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
        
        facebookLoginButton.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
        
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom + 10,
                                           width: scrollView.width - 60,
                                           height: 52)
        
        // facebookLoginButton.center = scrollView.center
        // facebookLoginButton.frame.origin.y = loginButton.bottom + 20
        
        googleLoginButton.frame = CGRect(x: 30,
                                         y: facebookLoginButton.bottom + 10,
                                         width: scrollView.width - 60,
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
        
        spinner.show(in: view)
        
        // Firebase login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
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

// Facebook login extension
extension LoginViewController: FBSDKLoginKit.LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // No operation
    }
    
    // facebook login
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token: String = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        // Get public profile data
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completionHandler: { connection, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            print(result)
            
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let email = result["email"] as? String,
                let picture = result["picture"] as? [String: Any],
                let data = picture["data"] as? [String: Any],
                let pictureUrl = data["url"] as? String else {
                    print("Failed to get data from fb result")
                    return
            }
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            // download facebook profile picture
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data from facebook image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
                                guard let data = data else {
                                    print("Failed to get data from facebook")
                                    return
                                }
                                
                                print("Got data from FB, uploading...")
                                // upload downloaded image to firebase
                                let fileName = chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { result in
                                    switch result {
                                    case .success(let downloadURL):
                                        // Cache the profile picture url
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)
                                        break
                                    case .failure(let error):
                                        print("Storage manager error: \(error)")
                                        break
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            let credential: AuthCredential = FacebookAuthProvider.credential(withAccessToken: token)

            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }

                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed - \(error)") // Multi factor authentication problem
                    }
                    return
                }

                print("Succesfully logged in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
    
}
