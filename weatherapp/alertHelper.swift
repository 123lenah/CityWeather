//
//  alertHelper.swift
//  weatherapp
//
//  Created by Mac on 7/4/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    
    func showAlert(fromController controller: UIViewController) {
        var alert = UIAlertController(title: "No Internet Connection Detected", message: "Connect to the Internet to use the App", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
}
