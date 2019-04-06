//
//  SignInViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/18/18.
//  Copyright © 2018 MacBook. All rights reserved.

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate{
    
    

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
 //   @IBOutlet weak var back: UILabel!
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add background gardian color
        //view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.setTitle("Sign in", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.backgroundColor = UIColor(red: 236/255, green: 98/277, blue: 95/255, alpha: 1.0)
        continueButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        continueButton.alpha = 0.5
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center

        view.addSubview(activityView)
        
        emailField.delegate = self
        passwordField.delegate = self

        
        emailField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // to dismiss the keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(SignInViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
       // let tap = UITapGestureRecognizer(target: self, action: #selector(backTomain))
       // back.isUserInteractionEnabled=true
        //back.addGestureRecognizer(tap)
        //back.ta
        setupGoogleButtons()
    }
    fileprivate func setupGoogleButtons() {
        //add google sign in button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 300, width: view.frame.width - 32, height: 50)
//        view.addSubview(googleButton)
        
        let customButton = UIButton(type: .system)
        customButton.frame = CGRect(x: 16, y: 116 + 300 + 66, width: view.frame.width - 32, height: 50)
        customButton.backgroundColor = .orange
        customButton.setTitle("Custom Google Sign In", for: .normal)
        customButton.addTarget(self, action: #selector(handleCustomGoogleSign), for: .touchUpInside)
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        view.addSubview(customButton)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @objc func handleCustomGoogleSign() {
        GIDSignIn.sharedInstance().signIn()
    }

    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


    @objc func textFieldChanged(_ target:UITextField) {
        let email = emailField.text
        let password = passwordField.text
        let formFilled = email != nil && email != "" && password != nil && password != ""
        setContinueButton(enabled: formFilled)
    }
    
    
    func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
            
        }
    }
    
    
    @objc func backTomain() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func handleSignIn() {
        guard let email = emailField.text else { return }
        guard let pass = passwordField.text else { return }
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                let mainView = MainTabBarController()
                DBService.shared.uid = (Auth.auth().currentUser?.uid)!
                self.present(mainView,animated: true,completion: nil)
            } else {
                let errorMsg = error!.localizedDescription
                let alertController = UIAlertController(title: errorMsg, message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Back", style: .cancel) { (action) in
                    //self.navigationController?.popViewController(animated: true)
                    self.backTomain()
                }
                alertController.addAction(okAction)
                self.present(alertController,animated: true)
            }
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to log into Google: ", err)
            return
        }
        
        print("Successfully logged into Google", user)
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            DBService.shared.personExists(uid: user!.uid, completionHandler: {
                (exists) in
                
                if(!exists){
                    guard let uid = user?.uid else { return }
                    var dictionary : [String:Any]{
                        return [
                            "email": user?.email ?? "",
                            "profileImageURL": user?.photoURL?.absoluteString ?? "",
                            "firstName": user?.displayName ?? "",
                            "username": "@\(user?.displayName?.trimmingCharacters(in: .whitespaces))",
//                            "lastName": GIDSignIn.sharedInstance()?.currentUser.profile.givenName
                        ]
                    }
                    
                    
                    let person = Person(dictionary: dictionary)!
                    DBService.shared.singup(person: person, uid: uid, completionHandler: { (alert) in
                        
                    })
                    
                }
                else{
                    
                }
                let mainView = MainTabBarController()
                self.present(mainView,animated: true,completion: nil)

            })
            
            print("Successfully logged into Firebase with Google", user!.uid)
        })
    }

}
