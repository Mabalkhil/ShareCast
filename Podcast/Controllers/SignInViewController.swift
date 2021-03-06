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
    
    

    @IBOutlet weak var continueButton: RoundedWhiteButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
 
    var activityView:UIActivityIndicatorView!
    
    var person:Person?
    var uid:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor(red: 222/255, green: 77/255, blue: 79/255, alpha: 1.0)
        // add background gardian color
        //view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)

        continueButton.backgroundColor = UIColor(red: 236/255, green: 98/277, blue: 95/255, alpha: 1.0)
        continueButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        continueButton.alpha = 0.5
      
        
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
        tap.cancelsTouchesInView = false // wait 
        view.addGestureRecognizer(tap)

        // google configration
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    @IBAction func SignInWithGoogle(_ sender: Any) {
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
                self.dismiss(animated: true, completion: nil)
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
        
        Auth.auth().signInAndRetrieveData(with: credentials) { (auth, error) in
            if let err = error {
                let errorMsg = error!.localizedDescription
                let alertController = UIAlertController(title: errorMsg, message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Back", style: .cancel, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController,animated: true)
                return
            }
            if !(auth?.additionalUserInfo!.isNewUser)! {
                
               
                let mainView = MainTabBarController()
                self.present(mainView,animated: true,completion: nil)
                
            }else{
            var dictionary : [String:Any]{
                return [
                    "email": auth?.user.email ?? "",
                    "profileImageURL": "",
                    "firstName": auth?.user.displayName ?? "" ,
                    "lastName":"",
                    "username":"@"
                ]
            }
            self.uid = auth?.user.uid
            self.person = Person(dictionary: dictionary)!
            self.performSegue(withIdentifier: "googleSignUp", sender: nil)
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "googleSignUp" {
             let destination = segue.destination as! googleSignUpController
                destination.person =  self.person
                destination.uid = self.uid
        }
    }
}
