//
//  WeatherGetter.swift
//  LocationAndWeather
//
//  Created by 1024 on 03.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import Foundation

protocol WeatherGetterDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: Error)
}

class WeathetGetter {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "5b067e2232f356d99005fd5df6aded29"
    
    private var delegate: WeatherGetterDelegate
    
    
    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }
    
    func getWeatherByCity(_ city: String) {
        let weatherRequestUrl = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getWeather(weatherRequestUrl)
    }
    
    func getWeatherByCoordinates(_ latitude: Double, longitude: Double) {        
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getWeather(weatherRequestURL)
    }
    
    private func getWeather(_ weatherRequstURL: URL) {
        let session = URLSession.shared
        
        
        let dataTask = session.dataTask(with: weatherRequstURL){
            (data: Data?, response: URLResponse?, error: Error?) in
            if let networkError = error {
                // Case 1: Error
                self.delegate.didNotGetWeather(error: networkError)
            } else {
                // Case 2: Success. We got data from the server.
                do {
                    // Try to convert data into a Swift dictionary
                    let weatherData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                    let weather = Weather(weatherData: weatherData)
                    self.delegate.didGetWeather(weather: weather)
                } catch {
                    print("JSON error description: \(error)")
                    self.delegate.didNotGetWeather(error: error)
                }
            }
        }
        dataTask.resume()
    }

}
