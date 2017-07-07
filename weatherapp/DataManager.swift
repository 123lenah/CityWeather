//
//  DataManager.swift
//  weatherapp
//
//  Created by Mac on 6/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

enum DataManagerError: Error {
    case Unknown
    case FailedRequest
    case InvalidResponse
    case noError
}

var invalidURLError: Bool = false
typealias CompletionHandler = (_ success: Bool) -> Void




final class DataManager {
    typealias WeatherDataCompletion = (AnyObject?, DataManagerError?) -> ()
    
    func didRetrieveData(completionHandler: CompletionHandler) {
        let flag = false
        completionHandler(flag)
    }
    
    //Pass the URL into the didFetchWeatherData function to make the call and parse the JSON
    func weatherDataForLocation(cityName: String, completion: @escaping WeatherDataCompletion) {
        //fetch URL
        let URL = API.getURL(cityName: cityName)
        
        invalidURLError = true

        
        // create data task
        URLSession.shared.dataTask(with: URL) { (data, response, error) in
            self.didFetchWeatherData(data: data, response: response,
            error: error, completion: completion)
            
            invalidURLError = false

            
         
        }.resume()
    }
    
    //Make the call
    func didFetchWeatherData(data: Data?, response: URLResponse?, error: Error?, completion: WeatherDataCompletion) {
        if let _ = error {
            completion(nil, .FailedRequest)
            requestError(typeError: .FailedRequest)
            
        } else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                processWeatherData(data: data, completion: completion)
                requestError(typeError: .noError)
                
            } else {
                completion(nil, .FailedRequest)
                requestError(typeError: .FailedRequest)
            }
        } else {
            completion(nil, .Unknown)
        }
    }
    
    //Serialize the JSON
    func processWeatherData(data: Data, completion: WeatherDataCompletion) {
        if let JSON = try? JSONSerialization.jsonObject(with: data, options: []) {
            completion(JSON as AnyObject?, nil)
        } else {
            completion(nil, .InvalidResponse)
            requestError(typeError: .InvalidResponse)
        }
    }
    
    func requestError(typeError: DataManagerError) {
        
        if typeError == .FailedRequest {
            print("invalid URL")
        }
        if typeError == .InvalidResponse {
            print("can't serialize JSON")
        }
        
        if typeError == .noError {
            print("no error")
        }
        
    }
    
    func checkIfValidURL(cityName: String, successHandler: @escaping (Bool) -> Void)  {
        let url = API.getURL(cityName: cityName)

        var success: Bool = false
        
        let session = URLSession.shared
        let task = session.downloadTask(with:url) { loc, resp, err in
            if let status = (resp as? HTTPURLResponse)?.statusCode {
                if status == 200 {
                    success = true
                    successHandler(success)
                } else {
                    success = false
                    successHandler(success)
                }
                print("response status: \(status)")
            }

            }
        task.resume()
        
    }
    
}
