//
//  AuthService.swift
//  Podcast
//
//  Created by MacBook on 31/03/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import Firebase
import TwitterKit
import FirebaseAuth


class AuthService {
    
    static let shared = AuthService()
    
    let dbs = DBService.shared
    
    var twitterSession : TWTRSession?
    static let twitterKey = ""
    static let twitterSecret = ""
    
    @objc func handelTwitterLogIn(){
        TWTRTwitter.sharedInstance().logIn { (twitterSession, error) in
            if let error = error{
                print("Error with Twitter Login: \(error)")
                return
            }
            else {
                guard let session = twitterSession else {return}
                self.twitterSession = session
                self.signIntoFirebaseWithTwitter()
            }
        }
    }
    func signIntoFirebaseWithTwitter(){
        guard let twitterSession = self.twitterSession else {return}
        let credential = TwitterAuthProvider.credential(withToken: twitterSession.authToken, secret: twitterSession.authTokenSecret)
        Auth.auth().signIn(with: credential) { (user, err) in
            if let err = err {
                print("Failed to create user with Twitter credentials: \(err)")
                return
            }
            else {
                print("Successfully created user with uid \(user?.uid ?? "N/A")")
                
            }
        }
        
    }
    func fetchTwitterPeson(completionHandler: @escaping (Person,UIAlertController) -> ()){
        guard let twitterSession = self.twitterSession else {return}
        let client = TWTRAPIClient()
        client.loadUser(withID: twitterSession.userID) { (user, err) in
            if let err = err {
                print("Failed Fethcing Twitter User : \(err)")
                return
            }
            guard let user = user else {return}
            var dictionary : [String:Any]{
                return [
                    "profileImageURL": user.profileImageLargeURL,
                    "firstName":user.name,
                    "username":"@\(twitterSession.userName)"
                ]
            }
            let person = Person(dictionary: dictionary)!
            self.dbs.singup(person: person, uid: Auth.auth().currentUser!.uid, completionHandler: {
                alert in
                completionHandler(person,alert)

            })
        }
    }
    
    
    
}
