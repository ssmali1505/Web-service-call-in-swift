//
//  ViewController.swift
//  WebServiceCalls
//
//  Created by SANDY on 08/01/15.
//  Copyright (c) 2015 Sandeep. All rights reserved.
//

import UIKit

class ViewController: UIViewController,APIHelperDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         fetchdata()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchdata(){
        
        var objHelper:APIHelper=APIHelper()
       
        var parameters:NSMutableDictionary=NSMutableDictionary()
        
        objHelper.APIHelperAPI_POST("http://api.openweathermap.org/data/2.5/weather?q=London,uk", parameters: parameters,apiIdentifier: "weather",delegate: self)
        
    }
    
    
    // MARK: APIHelperDelegate
    func apiHelperResponseSuccess(apiHelper: APIHelper) {
        
        if(apiHelper.ApiIdentifier=="weather")
        {
            var stringJson = NSString(data: apiHelper.responseData!, encoding: NSUTF8StringEncoding)
            
            println("wenservice Post response >>> \(stringJson)")
           
            let alert = UIAlertController(title: "Data", message: "Result : \(stringJson)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func apiHelperResponseFail(connection: NSURLConnection, error: NSError) {
        println("error : \(error)")
        
        let alert = UIAlertController(title: "Error", message: "ERROR : \(error)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }


}

