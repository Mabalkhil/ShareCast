//
//  SignUpViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 11/17/18.
//  Copyright © 2018 MacBook. All rights reserved.
//

import UIKit
import Firebase

class googleSignUpController: UIViewController , UITextFieldDelegate{
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastnameText: UITextField!
    

    
    var continueButton:RoundedWhiteButton!
    var activityView:UIActivityIndicatorView!
    var person : Person?
    var uid : String!
    
    let ref = Database.database().reference(fromURL: "https://sharecast-c780f.firebaseio.com/")
    
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
   
        usernameText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailText.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if person != nil {
            emailText.text = person?.email ?? ""
            firstNameText.text = person?.firstName ?? ""
            lastnameText.text = person?.lastName ?? ""
            usernameText.text = person?.username ?? ""
        }
        
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        let firstName = firstNameText.text
        let lastName = lastnameText.text
        let formFilled = username != nil && username != "" && email != nil && email != "" &&  firstName != nil && firstName != "" && lastName != nil && lastName != ""
        setContinueButton(enabled: formFilled)
    }
       
    @objc func handleSignUp() {
        guard let username = usernameText.text else { return }
        guard let email = emailText.text else { return }
        guard let firstName = self.firstNameText.text else { return }
        guard let lastName = self.lastnameText.text else { return }
        if username.isValidName == false {
            let notMatch = UIAlertController(title: "Username or Password Not Valid", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            notMatch.addAction(action)
            self.present(notMatch,animated: true,completion: nil)
        }else{
            print("This will run also")
            setContinueButton(enabled: false)
            continueButton.setTitle("", for: .normal)
            activityView.startAnimating()
    
                let values =
                        ["email": email,
                         "profileImageURL": "https://firebasestorage.googleapis.com/v0/b/sharecast-c780f.appspot.com/o/profile_Image%2FDefault.png?alt=media&token=37fdc72b-ffbe-430a-85c8-07dde877e71d",
                         "firstName":firstName,
                         "lastName":lastName,
                         "username":"@\(username)"]
                    let person = Person(dictionary: values)

                    
                    DBService.shared.singup(person: person!, uid: self.uid, completionHandler: {
                        alert in
                        self.present(alert,animated: true,completion: nil)
                    })
                    
                    let userInfoRefrence = self.ref.child("usersInfo").child(self.uid)
                    let data =
                        ["profileImgaeURL": person?.profileImageURL,"firstName":firstName,"lastName":lastName,"username":"@\(username)", "searchName": person?.name.lowercased()]
                    
                    userInfoRefrence.updateChildValues(data)
                    
                    let mainView = MainTabBarController()
                    self.present(mainView,animated: true,completion: nil)
                }
        }
    }

