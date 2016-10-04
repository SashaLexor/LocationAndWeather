//
//  LocationViewController.swift
//  LocationAndWeather
//
//  Created by 1024 on 03.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import UIKit
import CoreLocation


class LocationViewController: UIViewController {
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var getWeatherButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark? // Contains the address results.
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    var timer: Timer?
    var weatherGetter: WeathetGetter?
    
    var weather: Weather?
    
    @IBAction func getWeatherButtonClicked(_ sender: UIButton) {
        print("Get Weather")
        if let weatherGetter = weatherGetter {
            weatherGetter.getWeatherByCity("Minsk")
        }
        updateLabels()
    }
    
    
    @IBAction func getLocationButtonClicked(_ sender: AnyObject) {
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureButtons()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization() // Allows to get location updates while app is open and the user is interacting with app
        }
        
        if authStatus == .denied || authStatus == .restricted {
            messageLabel.text = "Location Services Disabled"
        }
        
        weatherGetter = WeathetGetter(delegate: self)
        
        weatherLabel.text = ""
        temperatureLabel.text = ""
        cloudCoverLabel.text = ""
        windLabel.text = ""
        rainLabel.text = ""
        humidityLabel.text = ""
        
        
        startLocationManager()
        updateLabels()
        configureButtons()
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

    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            messageLabel.text = "Updating location"
            if !updatingLocation {
                messageLabel.text = ""
            }
            
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching adress..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error finding adress"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            let statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location services disabled"
                } else {
                    statusMessage = "Error getting location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location services disabled"
            } else {
                statusMessage = "Updating location"
            }
            messageLabel.text = statusMessage
        }
    }
    
    func configureButtons() {
        if updatingLocation {
            getLocationButton.setTitle("Stop", for: .normal)
            getWeatherButton.isHidden = true
        } else {
            getLocationButton.setTitle("Get location", for: .normal)
            getWeatherButton.isHidden = false
        }
    }
    
   
    
    func startLocationManager() {
        print("Start Location Manager")
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // accuracy < 10m
            locationManager.startUpdatingLocation()
            updatingLocation = true
            lastLocationError = nil
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func stopLocationManager() {
        print("Stop Location Manager")
        if updatingLocation {
            if let timer = timer {
                timer.invalidate()
            }
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }
    
    func stringFromPlacemark(_ placemark: CLPlacemark) -> String {
        var line1 = ""
        if let subThoroughfare = placemark.subThoroughfare {
            line1 += subThoroughfare + " "
        }
        if let thoroughfare = placemark.thoroughfare {
            line1 += thoroughfare + " "
        }
        
        var line2 = ""
        if let locality = placemark.locality {
            line2 += locality + " "
        }
        if let area = placemark.administrativeArea {
            line2 += area + " "
        }
        if let postalCode = placemark.postalCode {
            line2 += postalCode
        }
        print(line1 + "\n" + line2)
        return line1 + "\n" + line2
    }
    
    func didTimeOut() {
        print("*** time out ***")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureButtons()
        }
    }
    
   
    
    
}


// MARK: - CLLocationManagerDelegate

extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did fail with error: \(error)")
        if error._code == CLError.Code.locationUnknown.rawValue {
            // The location is currently unknown, but Core Location will keep trying.
            return
        }
        lastLocationError = error as NSError?
        stopLocationManager()
        updateLabels()
        configureButtons()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("Did update locations: \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 || newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            location = newLocation
            lastLocationError = nil
            updateLabels()
            configureButtons()
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("We get location")
                stopLocationManager()
                
                weatherGetter?.getWeatherByCoordinates(newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                updateLabels()
                configureButtons()
            }
            
            if !performingReverseGeocoding {
                print("Try geocoding")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    placemarks, error in
                    print("Found placemarks: \(placemarks) Error: \(error)")
                    self.lastGeocodingError = error as NSError?
                    if error == nil, let p = placemarks , !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
            }
        }
    }
    
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style:  .default,
            handler: nil
        )
        alert.addAction(okAction)
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
}

extension LocationViewController: WeatherGetterDelegate {
    
    func didGetWeather(weather: Weather) {
        self.weather = weather
        
        DispatchQueue.main.async {
            self.weatherLabel.text = weather.weatherDescription
            self.temperatureLabel.text = String(format: "%.1f", weather.tempCelsius) + " °C"
            self.cloudCoverLabel.text = String(weather.cloudCover) + " %"
            self.windLabel.text = String(weather.windSpeed) + " m/s"
            if let rain = weather.rainfallInLast3Hours {
                self.rainLabel.text = String(rain) + " mm"
            } else {
                self.rainLabel.text = "None"
            }
            self.humidityLabel.text = String(weather.humidity) + " %"
        }
    }
    
    
    func didNotGetWeather(error: Error) {
        print(error)
        DispatchQueue.main.async {
            self.showSimpleAlert(title: "Can't get the weather", message: "The weather service isn't responding.")
        }
    }
    
}
