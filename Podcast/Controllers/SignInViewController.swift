//
//  SignInViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/18/18.
//  Copyright © 2018 MacBook. All rights reserved.

import UIKit
import Firebase

class SignInViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var back: UILabel!
    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add background gardian color
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(secondaryColor, for: .normal)
        continueButton.setTitle("Log In", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
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
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backTomain))
        back.isUserInteractionEnabled=true
        back.addGestureRecognizer(tap)
        //back.ta
        
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
                self.navigationController?.pushViewController(mainView, animated: true)
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

}
