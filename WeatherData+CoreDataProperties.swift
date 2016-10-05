//
//  WeatherData+CoreDataProperties.swift
//  LocationAndWeather
//
//  Created by 1024 on 04.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import Foundation
import CoreData


extension WeatherData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherData> {
        return NSFetchRequest<WeatherData>(entityName: "WeatherData");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var date: NSDate
    @NSManaged public var address: String
    @NSManaged public var city: String
    @NSManaged public var weatherDescription: String
    @NSManaged public var weatherTemperature: Double
    @NSManaged public var weatherCloudCover: Int16
    @NSManaged public var weatherWind: Int16
    @NSManaged public var weatherRain: NSNumber?
    @NSManaged public var weatherHumidity: Int16    

}
