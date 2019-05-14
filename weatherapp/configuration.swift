//
//  configuration.swift
//  weatherapp
//
//  Created by Mac on 6/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
struct API {

    static var urlFromString: URL = URL(string: "http://api.openweathermap.org/data/2.5/weather?")!

    
    static func getURL(cityName: String) -> URL {
        
        let url: NSString = "http://api.openweathermap.org/data/2.5/weather?q=\(cityName)=API_KEY" as NSString
        let urlStr: NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
        let finalURL : NSURL = NSURL(string: urlStr as String)!
        
            urlFromString = finalURL as URL
        
        
        return urlFromString
    }
}
