//
//  ViewController.swift
//  AccidentHere
//
//  Created by 이소민 on 2021/11/23.
//
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    //MARK: Global Var's
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
    var arrayKPH: [Double]! = []
    
    let baseline = 10.0
    
    @IBOutlet var speedDisplay: UILabel!
    @IBOutlet var lonDisplay: UILabel!
    @IBOutlet var latDisplay: UILabel!
    @IBOutlet var distanceTraveled: UILabel!
    @IBOutlet var minSpeedLabel: UILabel!
    @IBOutlet var maxSpeedLabel: UILabel!
    @IBOutlet var avgSpeedLabel: UILabel!
        
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        minSpeedLabel.text = "0"
        maxSpeedLabel.text = "0"
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            // 10미터 이내 정확도
            //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    // 1 mile = 5280 feet
    // Meter to miles = m * 0.00062137
    // 1 meter = 3.28084 feet
    // 1 foot = 0.3048 meters
    // km = m / 1000
    // m = km * 1000
    // ft = m / 3.28084
    // 1 mile = 1609 meters
    //MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        if (location!.horizontalAccuracy > 0) {
            updateLocationInfo(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude, speed: location!.speed, direction: location!.course)
        }
        if lastLocation != nil {
            traveledDistance += lastLocation.distance(from: locations.last!)
            if traveledDistance < 1609 {
                let tdMeter = traveledDistance
                distanceTraveled.text = (String(format: "%.0f Meters", tdMeter))
            } else if traveledDistance > 1609 {
                let tdKm = traveledDistance / 1000
                distanceTraveled.text = (String(format: "%.1f Km", tdKm))
            }
        }
        lastLocation = locations.last
    }

    func updateLocationInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees, speed: CLLocationSpeed, direction: CLLocationDirection) {
        let speedToKPH = (speed * 3.6)

        lonDisplay.text = (String(format: "%.3f", longitude))
        latDisplay.text = (String(format: "%.3f", latitude))
        
        // Checking if speed is less than zero
        if (speedToKPH > 0) {
            if (speedToKPH > baseline) {
                self.view.backgroundColor = UIColor.red
            } else {
                self.view.backgroundColor = nil
            }
            
            speedDisplay.text = (String(format: "%.0f km/h", speedToKPH))
            arrayKPH.append(speedToKPH)
            let lowSpeed = arrayKPH.min()
            let highSpeed = arrayKPH.max()
            minSpeedLabel.text = (String(format: "%.0f km/h", lowSpeed!))
            maxSpeedLabel.text = (String(format: "%.0f km/h", highSpeed!))
            avgSpeed()
        } else {
            speedDisplay.text = "0 km/h"
        }
    }

    func avgSpeed(){
        let speed:[Double] = arrayKPH
        let speedAvg = speed.reduce(0, +) / Double(speed.count)
        avgSpeedLabel.text = (String(format: "%.0f", speedAvg))
    }
    
    @IBAction func startTrip(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func restTripButton(_ sender: Any) {
        arrayKPH = []
        traveledDistance = 0
        speedDisplay.text = "-"
        lonDisplay.text = "-"
        latDisplay.text = "-"
        distanceTraveled.text = "-"
        minSpeedLabel.text = "-"
        maxSpeedLabel.text = "-"
        avgSpeedLabel.text = "-"
    }
    
    @IBAction func endTrip(_ sender: Any) {
        locationManager.stopUpdatingLocation()
    }
}
