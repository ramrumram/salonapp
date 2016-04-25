//
//  DashboardViewController.swift
//  api
//
//  Created by dev on 3/25/16.
//  Copyright © 2016 Salon Objectives. All rights reserved.
//

import UIKit
import WebKit

class DashboardViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    @IBOutlet weak var ViewDashboard: UIView!
    
    var proxyViewForStatusBar : UIView!
  
    override func loadView() {
        super.loadView()
        
        
        /* Create our preferences on how the web page should be loaded */
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        /* Create a configuration for our preferences */
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        
        
        self.webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.navigationDelegate = self
     
        self.view = self.webView!
    }
    
    
    override func viewDidLoad() {
        
         super.viewDidLoad()
        
        proxyViewForStatusBar = UIView(frame: CGRectMake(0, 0,self.view.frame.size.width, 20))
        
        proxyViewForStatusBar.backgroundColor=UIColor(red: 75/255, green: 66/255, blue: 118/255, alpha: 1)
        
        self.view.addSubview(proxyViewForStatusBar)
        
        self.performSelectorOnMainThread(#selector(DashboardViewController.openBrowserView), withObject: nil, waitUntilDone: true)
        
       
        // Do any additional setup after loading the view, typically from a nib.
        //border and corner for login form
        
        
        

        
        
        
        
        
        
        
        // loginWithKeychain()
    }
    
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        proxyViewForStatusBar.frame = CGRectMake(0, 0,self.view.frame.size.width, 20)
        if UIDevice.currentDevice().orientation.isLandscape.boolValue && UIDevice.currentDevice().userInterfaceIdiom == .Phone{
            
            proxyViewForStatusBar.backgroundColor = UIColor.clearColor()
        }else {
            proxyViewForStatusBar.backgroundColor=UIColor(red: 75/255, green: 66/255, blue: 118/255, alpha: 1)

        }
        
    }
    
    
    func openBrowserView() {
        
       
      
        
        
        
        // viewContainer.bringSubviewToFront(viewLoginForm)
        
      
        let requestURL = NSURL(string:browserURL)
        
        let request = NSMutableURLRequest(URL: requestURL!)
        
        
        request.HTTPMethod = httpMethod
        
        
        
        
        // if let theWebView = webView{
        /* Load a web page into our web view */
        self.webView!.loadRequest(request)
      //  self.webView?.UIDelegate = self
        self.webView!.navigationDelegate = self
        
        
        ViewDashboard.addSubview(self.webView!)
        
        
        
        //------------right  swipe gestures in view--------------//
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DashboardViewController.rightSwiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRight)
        
        //-----------left swipe gestures in view--------------//
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DashboardViewController.leftSwiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
    }
    
    
    
    /* Start the network activity indicator when the web view is loading */
    func webView(webView: WKWebView,didStartProvisionalNavigation navigation: WKNavigation){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
    }
    
    /* Stop the network activity indicator when the loading finishes */
    func webView(webView: WKWebView,didFinishNavigation navigation: WKNavigation){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
      
        
        
        dispatch_async(dispatch_get_main_queue()) {
            
            
            if(webView.URL?.absoluteString.rangeOfString("/sign_in") != nil ) {
                
                
                //just load remote url without anything just to show a blank page..otherwise it will show login page before every login
            //    browserURL = remoteURL
            //    httpMethod = "GET"
                
             //   self.performSelectorOnMainThread("openBrowserView", withObject: nil, waitUntilDone: true)
                
                ViewController().logout()
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let vc = storyboard.instantiateViewControllerWithIdentifier("LoginScreen")
                
                 self.navigationController!.pushViewController(vc, animated: true)
                
              //  ViewController().logout()
                // self.canEnableTouchid()
                
            }
            
        }
        
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        //this is a 'new window action' (aka target="_blank") > open this URL externally. If we´re doing nothing here, WKWebView will also just do nothing. Maybe this will change in a later stage of the iOS 8 Beta
        if navigationAction.navigationType == WKNavigationType.LinkActivated {
           
            let url = navigationAction.request.URL
            let shared = UIApplication.sharedApplication()
            
            _ = url!.absoluteString
            
            if shared.canOpenURL(url!) {
                shared.openURL(url!)
            }
            
            decisionHandler(WKNavigationActionPolicy.Cancel)
        }
        
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
    
    
    func webViewDidStartLoad(webView
        : UIWebView) {
            
                        
            
            
    }
    //MARK: swipe gestures
    func rightSwiped()
    {
        
        if(webView.canGoBack){
            
            webView.goBack()
        }
        
    }
    
    func leftSwiped()
    {
        if (webView.canGoForward){
           
            webView.goForward()
        }
        
        
    }
    
}
