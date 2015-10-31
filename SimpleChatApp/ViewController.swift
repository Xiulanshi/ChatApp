//
//  ViewController.swift
//  SimpleChatApp
//
//  Created by Xiulan Shi on 10/30/15.
//  Copyright © 2015 Xiulan Shi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var dockViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    
    var messagesArray:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        
        // Set self as the delegate for the textfield
        self.messageTextField.delegate = self
        
        
        // Add a tap gesture recognizer to the tableview
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        // Retrieve messages from Parse
        self.retrieveMessages()
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTapped(sender: UIButton) {
        
        //Send button is tapped
        
        // Call the end editing method for the text field
        
        self.messageTextField.endEditing(true)
        
        
        // Disable the send button and textfield
        
        self.messageTextField.enabled = false
        self.sendButton.enabled = false
        
        
        // Create a PFObject
        let newMessageObject:PFObject = PFObject(className: "Message")
        
        //Set the Text key to the text of the messageTextField
        newMessageObject["Text"] = self.messageTextField.text
        
        // Save the PFObject
        
        newMessageObject.saveInBackgroundWithBlock { (success:Bool, error:NSError?) -> Void in
            if (success) {
                //Message has been saved! Yay!
                // TODO: Retrieve the latest messages and reload the table
                self.retrieveMessages()
                NSLog("Message saved successfully.")
            }
            else {
                //something bad happened.
                NSLog(error!.description)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
            // Enable the textfield and send button
            self.sendButton.enabled = true
            self.messageTextField.enabled = true
            self.messageTextField.text = ""
            }
        }
        
    }
    
    func retrieveMessages() {
        
        // Create a new PFQuery
        let query:PFQuery = PFQuery(className: "Message")
        
        // Call findObjectsInBackground
        query.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            
            // Clear the messagesArray
            self.messagesArray = [String]()
            
            // Loop through the objects array
            for messageObject in objects! {
                
                // Retrive the Text column value of each PFObject
                let messageText:String? = (messageObject as PFObject)["Text"] as? String
                
                // Assign it into our messagesArray
                if messageText != nil {
                    self.messagesArray.append(messageText!)
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
            // Reload the tableview
            self.messageTableView.reloadData()
            }
        }
        
    }
    
    
    
    
    
    func tableViewTapped() {
        
        // Force the textfield to end editing
        self.messageTextField.endEditing(true)
        
    }
    
    // MARK: Textfield Delegate Methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Perform an animation to grow the dockview
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 350
            self.view.layoutIfNeeded()
            }, completion: nil)

    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Perform an animation to grow the dockview
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.dockViewHeightConstraint.constant = 60
            self.view.layoutIfNeeded()
            }, completion: nil)

    }
    
    // MARK: TableView Delegate Methods
   
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Create a table cell
        let cell = self.messageTableView.dequeueReusableCellWithIdentifier("MessageCell")! as UITableViewCell
        
        //Customize the cell
        cell.textLabel?.text = self.messagesArray[indexPath.row]
        
        //Return the cell
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messagesArray.count
    }
    


}

