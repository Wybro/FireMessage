//
//  ViewController.swift
//  FireMessage
//
//  Created by Connor Wybranowski on 2/6/16.
//  Copyright © 2016 Wybro. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet var postTableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var postButton: UIButton!
    
    var posts = [String]()
//    var nsPosts = NSArray()
    
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        postButton.layer.cornerRadius = 5
        
        self.messageTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        enableKeyboardHideOnTap()
        
        let ref = Firebase(url: "https://messagetestapp.firebaseio.com/posts")
        ref.observeEventType(.Value, withBlock: { snapshot in
            
            var newItems = [String]()
            
            for item in snapshot.children {
                let post = item.value as String
                newItems.append(post)
            }
            
            self.posts = newItems
            self.postTableView.reloadData()
            self.scrollToBottom()
            
//            print(snapshot.value)
            }, withCancelBlock: { error in
                print(error.description)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func post(sender: UIButton) {
        postMessage(messageTextField.text!)
    }
    
    
    func postMessage(text: String) {
        let ref = Firebase(url: "https://messagetestapp.firebaseio.com")
        let usersRef = ref.childByAppendingPath("posts")
        let usersRefChild = usersRef.childByAutoId()
        
        // only post if less than/ equal to 50 characters
        if text.characters.count <= 50 && !text.isEmpty {
            usersRefChild.setValue(text)
            messageTextField.text = ""
        }
        else {
            print("Too few/ many characters")
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = posts[indexPath.row] as String
        
        return cell
    }
    
    func scrollToBottom() {
        let lastRow = postTableView.numberOfRowsInSection(0) - 1
        postTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }
    
    func enableKeyboardHideOnTap() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        self.view.addGestureRecognizer(tap)
        
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(duration) { () -> Void in
            self.toolbarBottomConstraint.constant = keyboardFrame.size.height + 5
            
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animateWithDuration(duration) { () -> Void in
            self.toolbarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        scrollToBottom()
    }
    
}

