//
//  Weather.swift
//  LocationAndWeather
//
//  Created by 1024 on 04.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import Foundation

struct Weather {
    
    let dateAndTime: Date
    
    let city: String
    let country: String
    let longitude: Double
    let latitude: Double
    
    let weatherID: Int
    let mainWeather: String
    let weatherDescription: String
    let weatherIconID: String
    
    let temp: Double
    var tempCelsius: Double {
        get {
            return temp - 273.15
        }
    }
    var tempFahrenheit: Double {
        get {
            return (temp - 273.15) * 1.8 + 32
        }
    }
    
    let humidity: Int
    let pressure: Int
    let cloudCover: Int
    let windSpeed: Int
    
    let windDirection: Double?
    let rainfallInLast3Hours: Double?
    
    let sunrise: Date
    let sunset: Date
    
    
    init(weatherData: [String: AnyObject]) {
        
        // Parse JSON dict to Weather struct
        
        dateAndTime = Date(timeIntervalSince1970: weatherData["dt"] as! TimeInterval)
        city = weatherData["name"] as! String
        
        let coordinateDict = weatherData["coord"] as! [String: AnyObject]
        latitude = coordinateDict["lat"] as! Double
        longitude = coordinateDict["lon"] as! Double
        
        let weatherArray = weatherData["weather"] as! NSArray
        let weatherDict = weatherArray[0] as! NSDictionary
        
        weatherID = weatherDict["id"] as! Int
        mainWeather = weatherDict["main"] as! String
        weatherDescription = weatherDict["description"] as! String
        weatherIconID = weatherDict["icon"] as! String
        
        let mainDict = weatherData["main"] as! [String: AnyObject]
        temp = mainDict["temp"] as! Double
        humidity = mainDict["humidity"] as! Int
        pressure = mainDict["pressure"] as! Int
        
        cloudCover = weatherData["clouds"]!["all"] as! Int
        
        let windDict = weatherData["wind"] as! [String: AnyObject]
        windSpeed = Int(windDict["speed"] as! Double)
        windDirection = windDict["deg"] as? Double
        
        if weatherData["rain"] != nil {
            let rainDict = weatherData["rain"] as! [String: AnyObject]
            rainfallInLast3Hours = rainDict["3h"] as? Double
        }
        else {
            rainfallInLast3Hours = nil
        }
        
        let sysDict = weatherData["sys"] as! [String: AnyObject]
        country = sysDict["country"] as! String
        sunrise = Date(timeIntervalSince1970: sysDict["sunrise"] as! TimeInterval)
        sunset = Date(timeIntervalSince1970: sysDict["sunset"] as! TimeInterval)
        
    }
    
    func getShortDescription() -> String {
        return "\(mainWeather) \(weatherDescription)\n" + "Tempretute: \(tempCelsius) C\n" + "Clouds: \(cloudCover)"
    }
}
