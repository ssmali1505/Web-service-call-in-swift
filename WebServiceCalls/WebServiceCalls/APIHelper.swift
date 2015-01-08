//
//  APIHelper.swift
//  WebServiceCalls
//
//  Created by SANDY on 02/01/15.
//  Copyright (c) 2015 Evgeny Nazarov. All rights reserved.
//

import Foundation


@objc protocol APIHelperDelegate
{
    /// This will return response from webservice if request successfully done to server
    func apiHelperResponseSuccess(apihelper:APIHelper)
    
    /// This is for Fail request or server give any error
    optional func apiHelperResponseFail(connection: NSURLConnection?,error: NSError)
}

public class APIHelper: NSObject,NSURLConnectionDelegate
{
    
    public enum MethodType : Int{
        case GET = 1
        case POST = 2
        case JSON = 3
        case IMAGE = 4
    }
    
    
    let timeinterval:Int = 239
    private var objConnection:NSURLConnection?
    private var objURL:NSString!
    private var objParameter:NSMutableDictionary?
    private var objUtility:APIUtilityHelper!
    public  var responseData:NSMutableData!
    var delegate:APIHelperDelegate?
    public var ApiIdentifier:NSString!=""
    
    
    
    override init()
    {
        super.init();
        objUtility=APIUtilityHelper()
    }
    
    // MARK: Method Web API
    
    /// Call GET request webservice (urlMethodOrFile, parameters:,apiIdentifier,delegate)
    func APIHelperAPI_GET(urlMethodOrFile:NSString, parameters:NSMutableDictionary?,apiIdentifier:NSString,delegate:APIHelperDelegate!)
    {
        self.objParameter=parameters
        self.ApiIdentifier=apiIdentifier
        self.delegate=delegate
        
        var strParam :NSString? = objUtility!.JSONStringify(objParameter!)
        
        if (strParam != "")
        {
            strParam = "?" + strParam!
        }
        
        var strURL:String = "\(urlMethodOrFile)" + strParam!
        self.objURL=strURL
        
        self.CallURL(nil, methodtype: MethodType.GET)
        
    }
    
    /// Call POST request webservice (urlMethodOrFile, parameters,apiIdentifier,delegate)
    func APIHelperAPI_POST(urlMethodOrFile:NSString, parameters:NSMutableDictionary?,apiIdentifier:NSString,delegate:APIHelperDelegate!)
    {
        self.objParameter=parameters
        self.ApiIdentifier=apiIdentifier
        self.delegate=delegate
        
        var strParam :NSString? = objUtility!.JSONStringify(objParameter!)
        
        println("wenservice Post Input >>> \(strParam)")
        
        var strURL:String = (urlMethodOrFile)
        self.objURL=strURL
        
        self.CallURL(strParam?.dataUsingEncoding(NSUTF8StringEncoding), methodtype: MethodType.POST);
    }
    
    /// Upload file and text data through webservice (urlMethodOrFile, parameters,parametersImage(dictionary of NSData),apiIdentifier,delegate)
    func APIHelperAPI_FileUpload(urlMethodOrFile:NSString, parameters:NSMutableDictionary?,parametersImage:NSMutableDictionary?,apiIdentifier:NSString,delegate:APIHelperDelegate!)
    {
        self.objParameter=parameters
        self.ApiIdentifier=apiIdentifier
        self.delegate=delegate
        
        
        var strParam :NSString? = objUtility!.JSONStringify(self.objParameter!)
        var strURL:String = (urlMethodOrFile)
        self.objURL=strURL
        
        var body : NSMutableData?=NSMutableData()
        
        
        var dicParam:NSDictionary = parameters!
        var dicImageParam:NSDictionary = parametersImage!
        
        
        var boundary:NSString? = "---------------------------14737809831466499882746641449"
        
        // process text parameters
        for (key, value) in dicParam {
            body?.appendData(("\r\n--\(boundary)\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
            body?.appendData(("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
            body?.appendData(("\r\n--\(boundary)\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
        }
        
        
        //process images parameters
        var i:Int=0
        for (key, value) in dicImageParam {
            body?.appendData(("\r\n--\(boundary)\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
            body?.appendData(("Content-Disposition: file; name=\"\(key)\"; filename=\"image.png\(i)\"\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
            body?.appendData(("Content-Type: application/octet-stream\r\n\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
            body?.appendData(value as NSData);
            body?.appendData(("\r\n--\(boundary)\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
        }
        
        
        body?.appendData(("\r\n--\(boundary)\r\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!);
        
        
        self.CallURL(body!, methodtype: MethodType.IMAGE);
        
    }
    
    
    /// Call JSON webservice (urlMethodOrFile,json,apiIdentifier,delegate)
    func APIHelperAPI_JSON(urlMethodOrFile:NSString, json:NSString?,apiIdentifier:NSString,delegate:APIHelperDelegate!)
    {
        self.ApiIdentifier=apiIdentifier
        self.delegate=delegate
        
        var strParam :NSString? = json
        var strURL:String = urlMethodOrFile
        self.objURL=strURL
        
        self.CallURL(strParam?.dataUsingEncoding(NSUTF8StringEncoding),methodtype: MethodType.JSON)
        
    }
    
    private func CallURL(dataParam:NSData?,methodtype:MethodType)
    {
        //println(self.objURL)
        
        if(!self.objUtility.isInternetAvailable())
        {
            println("INTERNET NOT AVAILABLE")
            var error :NSError=NSError(domain: "INTERNET NOT AVAILABLE", code: 404, userInfo: nil)
            delegate?.apiHelperResponseFail?(nil, error: error)
            
            return;
        }
        
        var objurl = NSURL(string: self.objURL)
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:objurl!)
        
        
        if(methodtype == MethodType.GET)
        {//if simple GET method -- here we are not using strParam as it concenate with url already
            
            request.timeoutInterval = NSTimeInterval(self.timeinterval)
            request.HTTPMethod = "GET";
        }
        
        if(methodtype == MethodType.POST)
        {//if simple POST method
            
            //            request.addValue("\(strParam?.length)", forHTTPHeaderField: "Content-length")
            request.timeoutInterval = NSTimeInterval(self.timeinterval)
            request.HTTPMethod = "POST";
            request.HTTPBody=dataParam
            
            
        }
        
        if(methodtype == MethodType.JSON)
        {//if JSON type webservice called
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            //            request.addValue("\(strParam?.length)", forHTTPHeaderField: "Content-length")
            request.timeoutInterval = NSTimeInterval(self.timeinterval)
            request.HTTPMethod = "POST";
            request.HTTPBody=dataParam
        }
        
        if(methodtype == MethodType.IMAGE)
        {//if webservice with Image Uploading
            
            var boundary:NSString? = "---------------------------14737809831466499882746641449"
            var contentType:NSString? = "multipart/form-data; boundary=\(boundary)"
            
            request.addValue(contentType, forHTTPHeaderField: "Content-Type")
            
            request.timeoutInterval = NSTimeInterval(self.timeinterval)
            request.HTTPMethod = "POST";
            request.HTTPBody=dataParam
            
        }
        
        self.objConnection = NSURLConnection(request: request, delegate: self, startImmediately: true)
        self.responseData=NSMutableData()
        
    }
    
    // MARK: NSURLConnection
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse)
    {
        //println("response")
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData)
    {
        self.responseData.appendData(data)
    }
    func connectionDidFinishLoading(connection: NSURLConnection)
    {
        
        //println(NSDate().timeIntervalSince1970)
        
        //        println("json : \(NSString(data: self.responseData!, encoding: NSUTF8StringEncoding))")
        delegate?.apiHelperResponseSuccess(self)
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError)
    {
        println("error iHelperClass: \(error)");
        
        delegate?.apiHelperResponseFail?(connection, error: error)
    }
    
    
}