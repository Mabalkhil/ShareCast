//
//  SignUpViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/17/18.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var back: UILabel!
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add background gardian color 
        //view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.setTitle("Sing Up", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center=CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.backgroundColor = UIColor(red: 236/255, green: 98/277, blue: 95/255, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.color = secondaryColor
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center

        view.addSubview(activityView)
        
        usernameText.delegate = self
        emailText.delegate = self
        passwordText.delegate = self
        
        usernameText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backTomain))
        back.isUserInteractionEnabled=true
        back.addGestureRecognizer(tap)
        
    }
    
    /**
     Enables or Disables the **continueButton**.
     */
    func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    
    /**
     Enables the continue button if the **username**, **email**, and **password** fields are all non-empty.
     - Parameter target: The targeted **UITextField**.
     */
    @objc func textFieldChanged(_ target:UITextField) {
        let username = usernameText.text
        let email = emailText.text
        let password = passwordText.text
        let formFilled = username != nil && username != "" && email != nil && email != "" && password != nil && password != ""
        setContinueButton(enabled: formFilled)
    }
    
    @objc func backTomain() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func handleSignUp() {
        guard let username = usernameText.text else { return }
        guard let email = emailText.text else { return }
        guard let pass = passwordText.text else { return }
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView.startAnimating()
        
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                print("User created!")
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        let mainView = MainTabBarController()
                        self.navigationController?.pushViewController(mainView, animated: true)
                        
                    } else {
                        let errorMsg = error!.localizedDescription
                        let alertController = UIAlertController(title: errorMsg, message: "", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Back", style: .cancel) { (action) in
                            self.backTomain()
                        }
                        alertController.addAction(okAction)
                        self.present(alertController,animated: true)
                    }
                }
                
            } else {
                let errorMsg = error!.localizedDescription
                let alertController = UIAlertController(title: errorMsg, message: "", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Back", style: .cancel) { (action) in
                    self.backTomain()
                }
                alertController.addAction(okAction)
                self.present(alertController,animated: true)
            }
        }
        
        
    }
    

}
