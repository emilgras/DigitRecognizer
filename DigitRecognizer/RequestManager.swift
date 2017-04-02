//
//  RequestUtils.swift
//  DigitRecognizer
//
//  Created by Emil Gräs on 16/03/2017.
//  Copyright © 2017 Emil Gräs. All rights reserved.
//

import Foundation



class RequestManager {
    
    let api = "https://demo-dig-rec.herokuapp.com/api/recognize"
    
    init() {}
    
    func sendRequest(withImageData imgData: Data, completion: @escaping (_ result: String?, _ error: Error?) -> Void) {
        
        guard let url = URL(string: api) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var parameters = Dictionary<String, String>()
        parameters["image"] = "data:image/png;base64,\(imgData.base64EncodedString(options: []))"

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print("json serialization error: \(error.localizedDescription)")
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            if let error = error {
                print("Error from util: \(String(describing: error.localizedDescription))")
                completion(nil, error)
                return
            }
            guard let data = data else {
                print("Error from util: No Data")
                completion(nil, nil)
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] {
                    if let prediction = jsonResult["prediction"] as? String {
                        completion(prediction, nil)
                    } else {
                        completion(nil, nil)
                    }
                } else {
                    completion(nil, nil)
                }
            } catch let error {
                completion(nil, error)
            }

        })
        task.resume()
    }
    
}
