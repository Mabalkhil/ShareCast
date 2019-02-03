
//
//  ResetPassViewController.swift
//  Podcast
//
//  Created by Mohammed Abalkhail on 2/3/19.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import Firebase




class ResetPassViewController: UIViewController {
    // Outlet
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var cancell: UIButton! {
        didSet {
            let origImage = UIImage(named: "close");
            let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cancell.setImage(tintedImage, for: .normal)
            cancell.tintColor = UIColor.white
        }
    }
    // variables
    var alert: UIAlertController!
    var alertAction: UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
 
    }

    @IBAction func resetPass(sender: UIButton){
        guard let email = emailField.text, email != "" else {
             self.alert = UIAlertController(title: "Input Error", message: "Please Provide your email for password reset", preferredStyle: .alert)
             self.alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(alertAction)
            self.present(alert,animated: true,completion: nil)
            return
        }
        // send reset password
        print(email)
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            let title = (error == nil) ? "Password Reset Follow-Up" : "Password Reset Error"
            let message = (error == nil) ? "We have just send you password reset email, Please check your inbox and follow the instruction to reset your password" : error?.localizedDescription
             self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            self.alertAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                if error == nil {
                        self.view.endEditing(true)
                        self.dissmis()
                    }
                })
            self.alert.addAction(self.alertAction)
           self.present(self.alert,animated: true,completion: nil)
   
        }
    }

    @IBAction func cancelButton(sender: UIButton){
        dissmis()
    }
    
    func dissmis() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
