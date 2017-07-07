//
//  weatherModel.swift
//  weatherapp
//
//  Created by Mac on 6/30/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
class Weather: NSObject {
    let humidity: String
    let pressure: String
    let temp: String
    let tempMax: String
    let tempMin: String
    let weatherDescription: String
    
    override var description: String {
        return "Humidity: \(humidity), Pressure: \(pressure), Temp: \(temp), TempMax: \(tempMax), TempMin: \(tempMin), Description: \(weatherDescription)"
    }
    
    init(humidity: String, pressure: String, temp: String, tempMax: String, tempMin: String, weatherDescription: String) {
        self.humidity = humidity
        self.pressure = pressure
        self.temp = temp
        self.tempMax = tempMax
        self.tempMin = tempMin
        self.weatherDescription = weatherDescription
    }
    
    
    
    
}
