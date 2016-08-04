//
//  TodayViewController.swift
//  WeatherExtensions
//
//  Created by Bryan Ayllon on 8/3/16.
//  Copyright © 2016 Bryan Ayllon. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation
class TodayViewController: UIViewController, NCWidgetProviding,CLLocationManagerDelegate {
        
    var location = [LocationStuff]()
    
    @IBOutlet weak var actualTempeture :UILabel!
    @IBOutlet weak var acutalDetails :UILabel!
    @IBOutlet weak var acutalHumidity :UILabel!
    @IBOutlet weak var acutalVisibility :UILabel!
    @IBOutlet weak var acutalWindspeed :UILabel!
    
    
    var latitude :Double!
    var longitude :Double!
    
    let currentLocation = LocationStuff()
    var locationManager  :CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationSetup()
        setupForData()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func locationSetup(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
        latitude = locationManager.location!.coordinate.latitude
        longitude = locationManager.location!.coordinate.longitude
        
        
        
    }
    
    private func setupForData() {
        print("Lat:\(self.latitude), Long: \(self.longitude)")
        
        let theAPI = "https://api.forecast.io/forecast/ee590865b8cf07d544c96463ae5d47c5/\(self.latitude),\(self.longitude)"
        
        guard let url = NSURL(string: theAPI) else {
            fatalError("Invalid URL")
        }
        let session = NSURLSession.sharedSession()
        
        session.dataTaskWithURL(url) { (data :NSData?, response :NSURLResponse?, error :NSError?) in
            guard let jsonResult = NSString(data: data!, encoding: NSUTF8StringEncoding) else {
                fatalError("Unable to format data")
            }
            let postResult = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves) as! NSDictionary
            
            
            
            let dataArray = postResult["currently"] as! NSDictionary?;
            self.currentLocation.temperature = dataArray!.valueForKey("temperature") as! Int
            self.currentLocation.summary = dataArray!.valueForKey("summary") as! String
            self.currentLocation.humidity = dataArray!.valueForKey("humidity") as! Int
            self.currentLocation.visibility = dataArray!.valueForKey("visibility") as! Int
            self.currentLocation.windspeed = dataArray!.valueForKey("windSpeed") as! Int
            
            self.location.append(self.currentLocation)
            
            dispatch_async(dispatch_get_main_queue(), {
                self.actualTempeture.text = "Temperature: \(self.currentLocation.temperature)℉"
                
                self.acutalDetails.text = "Details: \(self.currentLocation.summary)"
                self.acutalHumidity.text = "Humidity: \(self.currentLocation.humidity)"
                self.acutalVisibility.text = "Visibility: \(self.currentLocation.visibility)"
                self.acutalWindspeed.text = "Windspeed: \(self.currentLocation.windspeed)"
            })
            }.resume()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
               completionHandler(NCUpdateResult.NewData)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let url :NSURL = NSURL(string: "weatherextenions://")!
        self.extensionContext!.openURL(url, completionHandler: nil)
        
        
    }
    
    
}
