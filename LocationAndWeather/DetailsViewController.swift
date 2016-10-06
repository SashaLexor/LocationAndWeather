//
//  DetailsViewController.swift
//  LocationAndWeather
//
//  Created by 1024 on 05.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    var managedObjectContext: NSManagedObjectContext!
    var weatherData: WeatherData? {
        didSet {
            if let weatherData = weatherData {
                latitude = weatherData.latitude
                longitude = weatherData.longitude
                address = weatherData.address
                weatherDescription = weatherData.weatherDescription
                temperature = weatherData.weatherTemperature
                cloudCover = Int(weatherData.weatherCloudCover)
                windSpeed = Int(weatherData.weatherWind)
                if let rain = weatherData.weatherRain {
                    rainInLast3h = Double(rain)
                } else {
                    rainInLast3h = 0.0
                }
                humidity = Int(weatherData.weatherHumidity)
                date = weatherData.date as Date
            }
        }
    }
    
    var latitude = 0.0
    var longitude = 0.0
    var address = ""
    var weatherDescription = ""
    var temperature = 0.0
    var cloudCover = 0
    var windSpeed = 0
    var rainInLast3h = 0.0
    var humidity = 0
    var date = Date(timeIntervalSince1970: 0)
    
    
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        latitudeLabel.text = String(format: "%.6f", latitude)
        longitudeLabel.text = String(format: "%.6f", longitude)
        addressLabel.text = address
        weatherLabel.text = weatherDescription
        let sign = temperature > 0 ? "+" : "-"
        temperatureLabel.text = sign + String(format: "%.1f", temperature) + "º"
        cloudCoverLabel.text = String(cloudCover) + " %"
        windLabel.text = String(windSpeed) + " m/s"
        if rainInLast3h == 0 {
            rainLabel.text = "None"
        } else {
            rainLabel.text = String(rainInLast3h) + " mm"
        }
        
        humidityLabel.text = String(humidity) + " %"
        dateLabel.text = dateFormatter.string(from: date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
