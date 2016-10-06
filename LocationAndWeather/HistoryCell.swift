//
//  HistoryCell.swift
//  LocationAndWeather
//
//  Created by 1024 on 04.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "en_US")
    return formatter
}()

class HistoryCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(forWeatherData weatherData: WeatherData) {
        dateLabel.text = dateFormatter.string(from: weatherData.date as Date)
        
        cityLabel.text = weatherData.city
        latitudeLabel.text = "Lat: " + String(format: "%.6f", weatherData.latitude)
        longitudeLabel.text = "Long: " + String(format: "%.6f",weatherData.longitude)
    }

}
