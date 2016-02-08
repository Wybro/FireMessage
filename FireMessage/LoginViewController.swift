//
//  LoginViewController.swift
//  FireMessage
//
//  Created by Connor Wybranowski on 2/7/16.
//  Copyright © 2016 Wybro. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet var welcomeImageView: UIImageView!
    @IBOutlet var chooseUsernameLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var confirmButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureUIElements()
//        animateWelcome()
    }
    
    override func viewDidAppear(animated: Bool) {
        animateWelcome()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirm(sender: UIButton) {
        // Login user
        
        if !usernameTextField.text!.isEmpty {
            let ref = Firebase(url: "https://messagetestapp.firebaseio.com")
            ref.authAnonymouslyWithCompletionBlock { (error, authData) -> Void in
                if error != nil {
                    // Error logging in anonymously
                }
                else {
                    // We are now logged in -- save user data in DB here
                    
                    let newUser = ["username": self.usernameTextField.text, "provider": authData.provider, "uID": authData.uid]
                    ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
                    self.saveToDefaults(newUser)
                    self.performSegueWithIdentifier("userLoggedIn", sender: self)
                }
            }
        }
    }
    
    func animateWelcome() {
        UIView.animateWithDuration(0.3, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.welcomeImageView.transform = CGAffineTransformMakeScale(1, 1)
            self.welcomeImageView.alpha = 1
            }) { (completed) -> Void in
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.chooseUsernameLabel.alpha = 1
                    self.usernameTextField.alpha = 1
                    self.confirmButton.alpha = 1
                })
        }
    }
    
    func configureUIElements() {
        welcomeImageView.alpha = 0
        self.welcomeImageView.transform = CGAffineTransformMakeScale(0.3, 0.3)
        
        chooseUsernameLabel.alpha = 0
        usernameTextField.alpha = 0
        confirmButton.alpha = 0
        
        confirmButton.layer.cornerRadius = 5
    }
    
    func saveToDefaults(dictionary: [String:AnyObject]) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(dictionary, forKey: "currentUser")
    }

}
