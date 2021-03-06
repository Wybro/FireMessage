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
    // Reference to DB
    let ref = Firebase(url: "https://messagetestapp.firebaseio.com/")
    
    // Max length of a post
    let maxMessageLength = 100

    @IBOutlet var postTableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var postButton: UIButton!
    
//    var posts = [String]()
    var posts = [NSDictionary]()
    
    @IBOutlet var toolbarBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        postButton.layer.cornerRadius = 5
        
        self.messageTextField.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        enableKeyboardHideOnTap()
        
        observeNewPosts()

        observeUserAuth()
    }
    
    override func viewDidDisappear(animated: Bool) {
        ref.removeAllObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func post(sender: UIButton) {
        postMessage(messageTextField.text!)
    }
    
    func postMessage(text: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let currentUser = defaults.objectForKey("currentUser") as? [String : AnyObject] {
            if ref.authData != nil {
                let usersRef = ref.childByAppendingPath("posts")
                let usersRefChild = usersRef.childByAutoId()
                
                // only post if less than/ equal to 50 characters
                if text.characters.count <= maxMessageLength && !text.isEmpty {

                    let post = ["username": currentUser["username"]!, "message":text, "timestamp": createTimeStamp()] as [String:AnyObject]
                    usersRefChild.setValue(post)

                    messageTextField.text = ""
                }
                else {
                    print("Too few/ many characters")
                }
                
            }
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let post = posts[indexPath.row]
        let message = post["message"] as? String
        let user = post["username"] as? String
        let timestamp = post["timestamp"] as? String
        
        let formattedTimeStamp = formatTimeStamp(timestamp!)
        
        cell.postLabel.text = message!
        cell.userLabel.text = "\(user!) | \(formattedTimeStamp)"
        cell.timestampLabel.text = timestamp!
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollToBottom() {
        let lastRow = postTableView.numberOfRowsInSection(0) - 1

        if lastRow >= 0 {
            postTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
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
            self.postTableView.contentOffset = CGPointMake(0, self.postTableView.contentOffset.y + keyboardFrame.height)
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
    
    func observeNewPosts() {
        let refPosts = ref.childByAppendingPath("posts")
        refPosts.observeEventType(.Value, withBlock: { snapshot in
            
            var newItems = [NSDictionary]()
            
            for item in snapshot.children {
                let child = item as! FDataSnapshot
                let dict = child.value as! NSDictionary
                newItems.append(dict)
            }
            
            self.posts = newItems
            self.postTableView.reloadData()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.scrollToBottom()
            })
            
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func observeUserAuth() {
        ref.observeAuthEventWithBlock { (authData) -> Void in
            if authData != nil {
                // user is athenticated
//                print("Authenticated: \(authData)")
            }
            else {
                // No user is signed in
                self.performSegueWithIdentifier("userMustLogin", sender: self)
//                print("No user signed in -- logging in anonymously")
            }
        }
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default, handler: { (_) -> Void in
            self.ref.unauth()
        })
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor(red: 239/255, green: 45/255, blue: 86/255, alpha: 1)
        
    }
    
    func createTimeStamp() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let now = NSDate()
        let timeStamp = dateFormatter.stringFromDate(now)
        return timeStamp
    }
    
    func formatTimeStamp(date: String) -> String {
        let calendar = NSCalendar.currentCalendar()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        // Convert string date from DB to NSDate
        let dateFromString = dateFormatter.dateFromString(date)
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        // Format the timeStamp informally according to the date of the post
        if calendar.isDateInToday(dateFromString!) {
            dateFormatter.dateFormat = "h:mm a"
            let timeStampString = dateFormatter.stringFromDate(dateFromString!)
            return "Today, \(timeStampString)"
        }
        else if calendar.isDateInYesterday(dateFromString!) {
            dateFormatter.dateFormat = "h:mm a"
            let timeStampString = dateFormatter.stringFromDate(dateFromString!)
            return "Yesterday, \(timeStampString)"
        }
        else {
            dateFormatter.dateFormat = "EEEE, h:mm a"
            let timeStampString = dateFormatter.stringFromDate(dateFromString!)
            return timeStampString
        }
    }

}

