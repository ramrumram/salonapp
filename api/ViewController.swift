//
//  ViewController.swift
//  api
//
//  Created by dev on 12/17/15.
//  Copyright © 2015 Salon Objectives. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import LocalAuthentication
import WebKit


var passedValues:  [String: String] = ["ob": "s"]

var IOS_TOKEN = "IOS_TOKEN_ADV"




/*var signInEndpoint: String = "https://dev2.salonobjectives.com/api/v1/auth/sign_in/"
var signUpEndpoint: String = "https://dev2.salonobjectives.com/api/v1/auth/"
var remoteURL = "https://dev2.salonobjectives.com/remote/index/"
var forgotPassword = "https://dev2.salonobjectives.com/password/new"
var initializeURL = "https://dev2.salonobjectives.com/users/registrations/sign_up2"
//used for inserting the device_id and also for delete notifications
let ios_push_notif:String =  "https://dev2.salonobjectives.com/users/devices/"
*/


var signInEndpoint: String = "https://app.salonobjectives.com/api/v1/auth/sign_in/"
var signUpEndpoint: String = "https://app.salonobjectives.com/api/v1/auth/"
var remoteURL = "https://app.salonobjectives.com/remote/index/"
var forgotPassword = "https://app.salonobjectives.com/password/new"
var initializeURL = "https://app.salonobjectives.com/users/registrations/sign_up2"
let ios_push_notif:String =  "https://app.salonobjectives.com/users/devices/"


//to check from how the user signs in...is that email login or facebook login?..will be store in keychain
var provider = "email"

var globalFields: AnyObject = ""
var browserURL = ""
var callBackSignin = false
var  postString: AnyObject = ""
var device_id = ""

var httpMethod = "GET"

var allowPossibleSignin = true
class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    
    
    
    
    
    @IBOutlet weak var viewLoginForm: UIScrollView!
    
    
    @IBOutlet weak var viewAfterLogin: UIView!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var viewBeforeLogin: UIView!
    
    @IBOutlet weak var fbloginbutton: FBSDKLoginButton!
    
    @IBOutlet var viewContainer: UIView!
    
    @IBOutlet weak var switchTouchID: UISwitch!
    
    @IBOutlet weak var viewFormFields: UIView!
    
    @IBOutlet weak var btnTouchID: UIButton!
    @IBOutlet weak var txtuname: UITextField!
    
    @IBOutlet weak var lblstatus: UILabel!
    
    @IBOutlet weak var txtpassword: UITextField!
    
    @IBOutlet weak var btnsignin: UIButton!
    
    
    @IBOutlet weak var btnsignup: UIButton!
    
    override func viewDidLoad() {
       
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //border and corner for login form
        
        
        makeViewCurved()
        

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
      
        
    
       // loginWithKeychain()
    }
    
    
   
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.loader.stopAnimating()
        
        
        if(allowPossibleSignin == true) {
            possibleAutoLogin()
        }
        
        //just after signup we need to login
        if (callBackSignin == true) {
            let email = globalFields["email"]! as? String
            let uid = globalFields["id"]! as? String
            let password = globalFields["password"]! as? String
            if (uid != "") {
                httpMethod = "GET"
                //this will login straightaway with the recently logged in user
                self.checkUserExistsAndSignIn(globalFields)
            }else {
                
                self.signin(email!, password: password!, uid: uid!)
            }
        }
        
       
        
       
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func btnsigninclick(sender: UIButton) {
        
        if (txtuname.text != "" && txtpassword.text != "") {
            loader.startAnimating()
            provider = "email"
         
            signin(txtuname.text!.trim(), password: txtpassword.text!, uid: "")
        }
        
    }
    
    @IBAction func btnsignupclick(sender: UIButton) {
        httpMethod = "POST"
        resetErrors()
        bringSignupViewToFront()
    }
    
    
    
  
    
    override func viewWillAppear(animated: Bool) {
        
        navigationController?.navigationBarHidden = true
        super.viewWillAppear(true)
    }
    
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // print("logged out")
    }
    
    func logUserData() {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name,email"])
        graphRequest.startWithCompletionHandler { (connection, result, error) -> Void in
            if error != nil {
              
            } else {
             
                provider = "facebook"
                self.checkUserExistsAndSignIn(result)
               
            }
        }
    }
    
    
    
    
    func storeInChainAndPostToRemote(email :String, password :String, uid :String) {
        
        
        passedValues = ["email": email, "password": password, "uid": uid]
        

        
        KeychainWrapper.setString(passedValues["email"]!, forKey: "salon_email")
        KeychainWrapper.setString(passedValues["password"]!, forKey: "salon_password")
        KeychainWrapper.setString(passedValues["uid"]!, forKey: "salon_uid")
        KeychainWrapper.setString(provider, forKey: "provider")
        
        
        browserURL = remoteURL + "?email="+passedValues["email"]!+"&password="+passedValues["password"]!+"&uid="+passedValues["uid"]!
       
        
       // print(browserURL)
        
        loader.startAnimating()
        
      //  print (device_id)
        
        //inser the device_id for this user
        
        let url = NSURL(string: ios_push_notif)!
        let session = NSURLSession.sharedSession()
        let postParams: [String: AnyObject] = ["email": passedValues["email"]!, "device_id": device_id]
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options:NSJSONWritingOptions())
            
        } catch {
            print("bad things happened")
        }
        
        
        
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            
        }).resume()

        
       
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("Dashboard")
        
     
        dispatch_async(dispatch_get_main_queue(), {

        self.navigationController!.pushViewController(vc, animated: true)
        })
        
        
    }
    
    //check user for facebook login
    
    func checkUserExistsAndSignIn(fbfields:AnyObject) {
        
        loader.startAnimating()
        
        let email = fbfields["email"]! as? String
        
        let uid = fbfields["id"]! as? String
        
        //try signing in first..if no record found will get credential error..which leads to signup
        let url = NSURL(string: signInEndpoint)!
        let session = NSURLSession.sharedSession()
        // let postParams = ["email" : email, "password" : password]
        let postParams: [String: AnyObject] = ["email": email!, "uid": uid!]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        
        
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options:NSJSONWritingOptions())
            
        } catch {
            print("bad things happened")
        }
        
        
        
        
        session.dataTaskWithRequest(request, completionHandler: { ( data, response: NSURLResponse?, error: NSError?) -> Void in
            
            let errorstring = NSString(data: data!, encoding: NSUTF8StringEncoding)
           
            
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                
                realResponse.statusCode == 200 else {
                   
                    provider = "facebook"
                    globalFields = fbfields
              
                    //cannot give credential error in fb login
                    //user does not exists..go for regisration
                    if (errorstring!.containsString("DOES_NOT_EXISTS")) {
//
                        httpMethod = "POST"
                        self.performSelectorOnMainThread("bringSignupViewToFront", withObject: nil, waitUntilDone: true)
                    }else if (errorstring!.containsString("FB_NOT_REGISTERED")){
                        //user exists through normal login! but credential error. go for update the existing..
                        httpMethod = "PATCH"
                        self.performSelectorOnMainThread("bringSignupViewToFront", withObject: nil, waitUntilDone: true)
                                           }
                    else {
                        print ("something wrong")
                    }
                    
                                      return
                    
            }
            
            //sign in success..log him in
            
            if let _ = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                
              
                
                
                self.storeInChainAndPostToRemote(email!, password: IOS_TOKEN, uid: uid!)
                
                
                
            }
            
        }).resume()
        
        
        
        
    }
    
    func bringSignupViewToFront() {
        
        
            
              
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("Signup")
        
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.navigationController!.pushViewController(vc, animated: true)
        })
    }
    
    
    func signin(email :String, password :String, uid :String) {
        
        
        
        let url = NSURL(string: signInEndpoint)!
        let session = NSURLSession.sharedSession()
        let postParams: [String: AnyObject] = ["email": email, "password": password, "uid": uid]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options:NSJSONWritingOptions())
            
        } catch {
            print("bad things happened")
        }
        
        
              session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
      

            
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.lblstatus.text = "Invalid credentials"
                        
                        self.loader.stopAnimating()
                        self.logout()
                        

                        
                    }
                    return
                    
            }
            
            
            if let _ = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                
                
                
              
                self.storeInChainAndPostToRemote(email, password: password, uid: uid)
                
                
                
            }
            
        }).resume()
        
        
    }
    
    

    
  
    
    @IBAction func unameTouchDown(sender: UITextField) {
        resetErrors()
    }
    
    
    @IBAction func pwdTouchDown(sender: UITextField) {
        resetErrors()
    }
    
    func logout(){

       // txtpassword.text = ""
        //logout of facebook
        
        fbLogout()
        
      //  loader.stopAnimating()

    }
    
    
    func fbLogout() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        callBackSignin = false
        KeychainWrapper.removeObjectForKey("salon_password")
    }
    func possibleAutoLogin() {
        
        
        //check if Auto login enabled last time
        
        let email: String? = KeychainWrapper.stringForKey("salon_email")
        let password: String? = KeychainWrapper.stringForKey("salon_password")
        if(email != nil && password != nil) {
           
            loginWithKeychain()
            
        }else {
            
           
            
            if FBSDKAccessToken.currentAccessToken() != nil {
               
                
                // user already has access token
                self.logUserData()
                resetErrors()
            } else {
                
                
                
                self.fbloginbutton.readPermissions = ["email","public_profile"]
                
                self.viewFormFields.addSubview(self.fbloginbutton)
                self.fbloginbutton.delegate = self
                
                
            }
        }
    }
    
   
    
  
    
    
    func resetErrors() {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.lblstatus.text = ""
        }
        
    }
    
    func makeViewCurved() {
        
   
        btnsignin.layer.cornerRadius = 4
        btnsignin.layer.masksToBounds = true
        btnsignup.layer.cornerRadius = 4
        btnsignup.layer.masksToBounds = true
        
        
        btnTouchID.layer.cornerRadius = 4
        btnTouchID.layer.masksToBounds = true
        btnTouchID.layer.cornerRadius = 4
        btnTouchID.layer.masksToBounds = true
    }
    
    func loginWithKeychain() {
        self.resetErrors()
       
        let email: String? = KeychainWrapper.stringForKey("salon_email")
        let password: String? = KeychainWrapper.stringForKey("salon_password")
        let uid: String? = KeychainWrapper.stringForKey("salon_uid")

        txtuname.text = email
        txtpassword.text = password

        
        self.loader.startAnimating()
        self.signin(email!, password: password!, uid: uid!);
    }
    
   
    
    @IBAction func btnTouchIDClick(sender: UIButton) {
        let authContext:LAContext = LAContext()
        var error:NSError?
        
        //Is Touch ID hardware available & configured?
        if(authContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:&error))
        {
            //Perform Touch ID auth
            authContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Login to Salon Objectives", reply: {(wasSuccessful:Bool, error:NSError?) in
                
                if(wasSuccessful)
                {
                    //User authenticated
                    self.touchIDResult(error)
                }
                else
                {
                    //There are a few reasons why it can fail, we'll write them out to the user in the label
                    self.touchIDResult(error)
                }
                
            })
            
        }
        else
        {
            //Missing the hardware or Touch ID isn't configured
            self.touchIDResult(error)
        }
        
        
    }
    
    
    func canEnableTouchid() {
        let authContext:LAContext = LAContext()
        var error:NSError?
        
        //Is Touch ID hardware available & configured?
        if(authContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:&error))
        {
            let salon_email: String? = KeychainWrapper.stringForKey("salon_email")
            let salon_password: String? = KeychainWrapper.stringForKey("salon_password")
            //        let salon_provider: String? = KeychainWrapper.stringForKey("salon_provider")
            
            
            //hide new touch id regitration and show verify touch id
            if (salon_email != nil && salon_password != nil){
                
                
                self.viewBeforeLogin.hidden = true
                self.viewAfterLogin.hidden = false
            }
            
        }else {
            self.viewBeforeLogin.hidden = true
            self.viewAfterLogin.hidden = true
            
        }
        
        
    }
    func touchIDResult(authError:NSError?)
    {
        dispatch_async(dispatch_get_main_queue(), {() in
            if let possibleError = authError
            {
                
                print(possibleError.code)
                print(possibleError.description)
            }
            else
            {
                //login with keychain
                self.loginWithKeychain()
            }
        })
        
    }
    
    @IBAction func btnforgotClick(sender: UIButton) {
        httpMethod = "GET"
        browserURL = forgotPassword
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewControllerWithIdentifier("Dashboard")
        dispatch_async(dispatch_get_main_queue(), {
            
            self.navigationController!.pushViewController(vc, animated: true)
        })

        
    }

    
  

    
    
}

