//
//  SignupViewController.swift
//  api
//
//  Created by dev on 2/5/16.
//  Copyright © 2016 Salon Objectives. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var errPwd: UILabel!
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var errFname: UILabel!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var errAll: UILabel!
    @IBOutlet weak var errUsername: UILabel!
    @IBOutlet weak var errLname: UILabel!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    
    
    @IBOutlet weak var btnCancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //border and corner for login form
        
        if (globalFields["email"] != nil)
        {
            fillForms()
            txtUsername.enabled = false
            txtUsername.backgroundColor = UIColor(red: 235/255, green: 239/255, blue: 246/255, alpha: 1)
        }
        

        btnSignup.layer.cornerRadius = 4
        btnSignup.layer.masksToBounds = true
       
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func fillForms() {
       
        let email = globalFields["email"]! as? String
  //      let uid = globalFields["id"]! as? String
        let name = globalFields["name"] as? String
        var nameArr = name?.componentsSeparatedByString(" ")
        let fname: String = nameArr! [0]
        let lname: String = nameArr! [1]
        
        txtFname.text = fname
        txtLname.text = lname
        txtUsername.text = email
        
        }
    
    
    func  validateSignup()  -> Bool {
        
        if (txtFname.text == "" ){
            errFname.text = "can't be blank"
            return false
        }
        if (txtLname.text == "" ) {
            errLname.text = "can't be blank"
            return false
        }
        if (txtUsername.text == ""){
            errUsername.text = "can't be blank"
            return false
        }else if (txtUsername.text!.isEmail != true) {
            errUsername.text = "wrong email format"
            return false
        }
        if (txtPwd.text == "" ) {
            errPwd.text = "can't be blank"
            return false
        }else if (txtPwd.text!.characters.count < 8 ){
            errPwd.text = "is too short(minimum is 8 characters)"
            return false
        }
        return true
        
     }
    //only used for fb signup at the momment, as the other signup will happen in the webpgae itself.
    //just api signup
    func signup()
    {
        
        var uid = ""
        if (globalFields["id"] != nil ){
           uid = (globalFields["id"]! as? String)!
        }
        let email =  txtUsername.text
      
        let password = txtPwd.text
        let fname = txtFname.text
        let lname = txtLname.text
        
        
        let url = NSURL(string: signUpEndpoint)!
        let session = NSURLSession.sharedSession()
        
        let postParams: [String: AnyObject] = ["email": email!, "password": password! , "first_name": fname!, "last_name": lname!, "uid": uid, "provider":provider]
        
        self.loader.startAnimating()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = httpMethod
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options:NSJSONWritingOptions())
        } catch {
            print("bad things happened")
        }
        
        
        
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            
            
           
            
            
            //if email already taken log him out sending a warning
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                      
                        self.loader.stopAnimating()
            
                       
                        
                        var temp = ""
                        do {
                            let JSON = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0))
                            guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                                //print("Not a Dictionary")
                                
                                return
                                
                            }
                            let err = JSONDictionary["errors"]?["full_messages"]!  as! NSArray
                            temp = err[0]  as! String
                            
                            
                        }
                        catch let JSONError as NSError {
                            print("\(JSONError)")
                        }
                        
                        self.errAll.text = temp
                        
                    }
                    return
            }
            
            //successful sign up ...sign him in as well
       
                
    
                
                
                dispatch_async(dispatch_get_main_queue(), {() in
                   
                    self.loader.stopAnimating()

                    
                    httpMethod = "GET"
                    self.bringLoginViewToFront(email!, password: password!)
                  
                })
                
      
            
        }).resume()
        
        
        
    }
    
    @IBAction func btnSignup(sender: UIButton) {
        if(validateSignup()) {
            signup()
        }
    }
    
    
    
    
    func bringLoginViewToFront(email: String, password: String) {
        
        
       
        
        allowPossibleSignin = false
        callBackSignin = true
        

        var uid = ""
        if(globalFields["id"] != nil){
            uid = (globalFields["id"]! as? String)!
        }
        let temp: AnyObject = ["email": email, "password": password, "id" : uid]
        globalFields = temp

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
        
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController!.pushViewController(vc, animated: true)
        }
        
        
    }
    
    
    @IBAction func btnCancelClick(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
         httpMethod = "GET"
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
        
        let cont =  ViewController()
      
          self.presentViewController(vc, animated: true, completion: nil)
          cont.fbLogout()
        
    }
    
}

extension String {
    var isEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .CaseInsensitive)
            return regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count)) != nil
        } catch {
            return false
        }
    }
}
