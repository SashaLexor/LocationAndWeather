//
//  HistoryViewController.swift
//  LocationAndWeather
//
//  Created by 1024 on 04.10.16.
//  Copyright © 2016 Aliaksandr Karzhenka. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var weatherDataArray = [WeatherData]()
    
    @IBAction func clearHistory(_ sender: UIBarButtonItem) {
        let fetchRequest: NSFetchRequest<WeatherData> = WeatherData.fetchRequest()
        do {
            self.weatherDataArray = try managedObjectContext.fetch(fetchRequest)
            for weatherData in weatherDataArray {
                managedObjectContext.delete(weatherData)
            }
            weatherDataArray.removeAll()
            tableView.reloadData()
        } catch {
            fatalCoreDataError(error: error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.rowHeight = 88
        let bgImage = UIImage(named: "bg 1")
        let bgView = UIImageView(image: bgImage)
        tableView.backgroundView = bgView
        performFetchRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        performFetchRequest()
        tableView.reloadData()
    }
    

  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryCell
        //let weatherData = fetchedResultsController.object(at: indexPath)
        let weatherData = weatherDataArray[indexPath.row]
        cell.configure(forWeatherData: weatherData)
        return cell
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! DetailsViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let weatherData = weatherDataArray[indexPath.row]
                controller.weatherData = weatherData
            }
        }
    }
    
    func performFetchRequest() {
        let fetchRequest: NSFetchRequest<WeatherData> = WeatherData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        do {
            weatherDataArray = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error: error)
        }
    }


}

