//
//  RequestUtils.swift
//  DigitRecognizer
//
//  Created by Emil Gräs on 16/03/2017.
//  Copyright © 2017 Emil Gräs. All rights reserved.
//

import Foundation

class RequestUtils {
    
    static let API = "https://demo-dig-rec.herokuapp.com/api/recognize"
//    static let API = "http://localhost:5000/api/recognize"
    
    static func sendRequest(withImageData imgData: Data, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        //create the url with URL
        let url = URL(string: API)! //change the url
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST

        var parameters = Dictionary<String, String>()
        parameters["image"] = "data:image/png;base64,\(imgData.base64EncodedString(options: []))"

        //request.httpBody = parameters
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print("json serialization error: \(error.localizedDescription)")
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            if error != nil {
                // TODO: Handle Error
                print("Error from util: \(String(describing: error?.localizedDescription))")
                completion(nil, error)
                return
            }

            guard let data = data else {
                // TODO: Handle Error
                print("Error from util: No Data")
                completion(nil, nil)
                return
            }

            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                    if let prediction = jsonResult["prediction"] as? String {
                        completion(prediction, nil)
                    } else {
                        // TODO: Handle Error
                        completion(nil, nil)
                    }
                } else {
                    // TODO: Handle Error
                    completion(nil, nil)
                }
            } catch let error {
                // TODO: Handle Error
                print("catch")
                completion(nil, error)
            }

        })
        task.resume()
    }
    
}
