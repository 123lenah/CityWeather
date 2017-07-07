//
//  ViewController.swift
//  weatherapp
//
//  Created by Mac on 6/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import SystemConfiguration


    // fix constraints on iPhone 5

class ViewController: UIViewController, UITextFieldDelegate {

    let dataManager = DataManager()
    var mainArray = [AnyObject]()
    var allInformation: Weather!
    
    var success: Bool!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var measureControl: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempMinLabel: UILabel!
    @IBOutlet weak var tempMaxLabel: UILabel!
    
    
    func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRoutReachability = withUnsafePointer(to: &zeroAddress, {$0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRoutReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return(isReachable && !needsConnection)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let isConnectedToNetwork = connectedToNetwork()
        if isConnectedToNetwork == true {
            print("connected to the Internet")
        } else {
            print("not connected")
            let alert = AlertHelper()
            alert.showAlert(fromController: self)
        }
       
    }
    
    @IBOutlet weak var searchButton: UIButton!
    
    var date: String {
        let currentDate = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return "Today, \(dateFormatter.string(from: currentDate as Date))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityTextField.delegate = self
        searchButton.layer.cornerRadius = 4
        dateLabel.text = date
        
        measureControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
    }
    
    func convertFarenheitToCelcius(farenheit: String) -> String {
        let fahrenheitFloat = Float(farenheit)
        let celciusFloat: Float = (fahrenheitFloat! - 32) * 5/9 as Float
        return String(celciusFloat)
    }
    
    func valueChanged() {
  
        if measureControl.selectedSegmentIndex == 0 {
            let farenheitTemp = convertedTemp + "°F"
            let farenheitTempMax = convertedTempMax + "°F"
            let farenheitTempMin = convertedTempMin + "°F"
            self.tempLabel.text = farenheitTemp
            self.tempMaxLabel.text = farenheitTempMax
            self.tempMinLabel.text = farenheitTempMin
        
        } else if measureControl.selectedSegmentIndex == 1 {
            let celciusTemp = convertFarenheitToCelcius(farenheit: convertedTemp) + "°C"
            let celciusTempMax = convertFarenheitToCelcius(farenheit: convertedTempMax) + "°C"
            let celciusTempMin = convertFarenheitToCelcius(farenheit: convertedTempMin) + "°C"
            self.tempLabel.text = celciusTemp
            self.tempMaxLabel.text = celciusTempMax
            self.tempMinLabel.text = celciusTempMin
            
        }
    }
    
    
    func getArrayOfWeatherObjects(cityName: String, completion: @escaping (Weather) -> Void){
       dataManager.weatherDataForLocation(cityName: cityName) {
            (response, error) in
        
            //0 declare all variables
        var humidityAsString = ""
        var pressureAsString = ""
        var weatherAsString = ""
        var tempAsString = ""
        var tempMaxAsString = ""
        var tempMinAsString = ""
        
            //1
            if let main = response?["main"] as? NSDictionary {
                
                if let humidity = main["humidity"], let pressure = main["pressure"], let temp = main["temp"], let tempMax = main["temp_max"], let tempMin = main["temp_min"] {
            
                     humidityAsString = "\(humidity)"
                     pressureAsString = "\(pressure)"
                     tempAsString = "\(temp)"
                     tempMaxAsString = "\(tempMax)"
                     tempMinAsString = "\(tempMin)"
    
                }
                
            }
        
        
            if let weatherArray = response?["weather"] as? NSArray {
            if let firstResult = weatherArray.firstObject as? NSDictionary {
                if let weatherDescription = firstResult["main"] {
                     weatherAsString = "\(weatherDescription)"
                 
                    }
                }
        }
        
        
        // collect it as a class
        let allInformation = Weather(humidity: humidityAsString, pressure: pressureAsString, temp: tempAsString, tempMax: tempMaxAsString, tempMin: tempMinAsString, weatherDescription: weatherAsString)
        self.mainArray.append(allInformation)
        
        
        completion(allInformation)
        
        
        
        }
        
    }
    
    func convertKelvinToFarenheit(kelvin: String) -> String {
        let kelvinFloat = Float(kelvin)
        let fahrenheitFloat: Float = (kelvinFloat! - 273.15) * 9/5 + 32
        //let roundedUpFarenheightInt: Int = Int(ceilf(fahrenheitFloat))
        return String(fahrenheitFloat)
    }
    
    func convertHpaToInHg(Hpa: String) -> String {
        let HpaFloat = Float(Hpa)
        let InHgFloat: Float = HpaFloat! / 33.8638866667
        return String(InHgFloat)
    }
    
    var convertedTemp = "0"
    var convertedTempMax = "0"
    var convertedTempMin = "0"
    
    @IBAction func searchButton(_ sender: Any) {
        let cityName = cityTextField.text

        dataManager.checkIfValidURL(cityName: cityName!) { (success) in
            if success == true {
                self.getArrayOfWeatherObjects(cityName: cityName!) { (allInformation) in
                    let humidity = allInformation.humidity + "%"
                    let pressure = allInformation.pressure
                    let temp = allInformation.temp
                    let tempMax = allInformation.tempMax
                    let tempMin = allInformation.tempMin
                    let description = allInformation.weatherDescription
                    
                    var correctTemp = ""
                    var correctTempMax = ""
                    var correctTempMin = ""
                    
                    //Convert to Correct Units of Measure
                    if self.measureControl.selectedSegmentIndex == 0 {
                        self.convertedTemp = self.convertKelvinToFarenheit(kelvin: temp)
                        self.convertedTempMax = self.convertKelvinToFarenheit(kelvin: tempMax)
                        self.convertedTempMin = self.convertKelvinToFarenheit(kelvin: tempMin)
                        correctTemp = self.convertedTemp + "°F"
                        correctTempMax = self.convertedTempMax + "°F"
                        correctTempMin = self.convertedTempMin + "°F"
                        
                    } else if self.measureControl.selectedSegmentIndex == 1 {
                        self.convertedTemp = self.convertKelvinToFarenheit(kelvin: temp)
                        self.convertedTempMax = self.convertKelvinToFarenheit(kelvin: tempMax)
                        self.convertedTempMin = self.convertKelvinToFarenheit(kelvin: tempMin)
                        let celciusTemp = self.convertFarenheitToCelcius(farenheit: self.convertedTemp) + "°C"
                        let celciusTempMax = self.convertFarenheitToCelcius(farenheit: self.convertedTempMax) + "°C"
                        let celciusTempMin = self.convertFarenheitToCelcius(farenheit: self.convertedTempMin) + "°C"
                        
                        correctTemp = celciusTemp
                        correctTempMax = celciusTempMax
                        correctTempMin = celciusTempMin
                    }
                    
                    let convertedPressure = self.convertHpaToInHg(Hpa: pressure)
                    
                    DispatchQueue.main.async {
                        self.humidityLabel.text = humidity
                        self.pressureLabel.text = convertedPressure
                        self.tempLabel.text = correctTemp
                        self.tempMaxLabel.text = correctTempMax
                        self.tempMinLabel.text = correctTempMin
                        self.descriptionLabel.text = description
                        self.locationLabel.text = cityName!
                        if let existingWeatherImage = UIImage(named: description) {
                            self.weatherImage.image = existingWeatherImage
                        } else {
                            self.weatherImage.image = UIImage(named: "Clear")
                        }
                    }
                }
            } else {
                    DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Invalid city name!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                        

                    self.humidityLabel.text = "no result"
                    self.pressureLabel.text = "no result"
                    self.tempLabel.text = "no result"
                    self.tempMaxLabel.text = "no result"
                    self.tempMinLabel.text = "no result"
                    self.descriptionLabel.text = "no result"
                    self.locationLabel.text = "no result"
                    
                }
                

            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

