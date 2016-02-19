//
//  ViewController.swift
//  CybersourceSampleSwift
//
//  Created by hirauchi.shinichi on 2016/02/19.
//  Copyright © 2016年 SAPPOROWORKS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    var API_KEY = "{put your api key here}"
    var SHARED_SECRET = "{put your shared secret here}"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapButton(sender: AnyObject) {


        let baseUri = "cybersource/"
        let resourcePath = "payments/v1/authorizations"
        let url = "https://sandbox.api.visa.com/\(baseUri)\(resourcePath)?apikey=\(API_KEY)"
        let body = "{\"amount\": \"0\", \"currency\": \"USD\", \"payment\": { \"cardNumber\": \"4111111111111111\", \"cardExpirationMonth\": \"10\", \"cardExpirationYear\": \"2016\" }}"
        let xPayToken = getXPayToken(resourcePath, queryString: "apikey=\(API_KEY)", requestBody: body) as String

        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(xPayToken, forHTTPHeaderField: "x-pay-token")


        let postBody = NSMutableData()
        postBody.appendData(body.dataUsingEncoding(NSUTF8StringEncoding)!)
        request.HTTPBody = postBody

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) {
            (
            let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Error")
                return
            }

            let responseString:NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            print(responseString)

            dispatch_async(
                dispatch_get_main_queue(),
                {
                    self.textView.text = responseString as String
                }
            );
        }
       task.resume()
    }

    func getXPayToken(apiNameURI:NSString, queryString:NSString, requestBody:NSString) -> NSString {
        let timestamp = getTimestamp()
        let sourceString = "\(SHARED_SECRET)\(timestamp)\(apiNameURI)\(queryString)\(requestBody)"
        let hash = getDigest(sourceString)
        return "x:\(timestamp):\(hash)"
    }

    func getTimestamp() -> NSString {
        let date = NSDate().timeIntervalSince1970
        return NSString(format: "%.0f", date)
    }

    func getDigest(date:NSString) -> NSString {
        if let d = date.dataUsingEncoding(NSASCIIStringEncoding) {
            var bytes = [UInt8](count: 64, repeatedValue: 0)
            CC_SHA256(d.bytes, CC_LONG(d.length), &bytes)
            let digest = NSMutableString(capacity: 64)
            for var i=0; i<32; i++ {
                digest.appendFormat("%02x", bytes[i])
            }
            return digest
        }
        return ""
    }
}

