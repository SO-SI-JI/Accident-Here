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
    var switchSpeed = "KPH"
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
    var arrayMPH: [Double]! = []
    var arrayKPH: [Double]! = []
    
    @IBOutlet var speedDisplay: UILabel!

    @IBOutlet var headingDisplay: UILabel!
    
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
            if switchSpeed == "MPH" {
                if traveledDistance < 1609 {
                    let tdF = traveledDistance / 3.28084
                    distanceTraveled.text = (String(format: "%.1f Feet", tdF))
                } else if traveledDistance > 1609 {
                    let tdM = traveledDistance * 0.00062137
                    distanceTraveled.text = (String(format: "%.1f Miles", tdM))
                }
            }
            if switchSpeed == "KPH" {
                if traveledDistance < 1609 {
                    let tdMeter = traveledDistance
                    distanceTraveled.text = (String(format: "%.0f Meters", tdMeter))
                } else if traveledDistance > 1609 {
                    let tdKm = traveledDistance / 1000
                    distanceTraveled.text = (String(format: "%.1f Km", tdKm))
                }
            }
        }
        lastLocation = locations.last

    }

    func updateLocationInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees, speed: CLLocationSpeed, direction: CLLocationDirection) {
        let speedToMPH = (speed * 2.23694)
        let speedToKPH = (speed * 3.6)
        let val = ((direction / 22.5) + 0.5);
        var arr = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
        let dir = arr[Int(val.truncatingRemainder(dividingBy: 16))]
        //lonDisplay.text = coordinateString(latitude, longitude: longitude)

        lonDisplay.text = (String(format: "%.3f", longitude))
        latDisplay.text = (String(format: "%.3f", latitude))
        if switchSpeed == "MPH" {
            // Chekcing if speed is less than zero or a negitave number to display a zero
            if (speedToMPH > 0) {
                speedDisplay.text = (String(format: "%.0f mph", speedToMPH))
                arrayMPH.append(speedToMPH)
                let lowSpeed = arrayMPH.min()
                let highSpeed = arrayMPH.max()
                minSpeedLabel.text = (String(format: "%.0f mph", lowSpeed!))
                maxSpeedLabel.text = (String(format: "%.0f mph", highSpeed!))
                avgSpeed()
            } else {
                speedDisplay.text = "0 mph"
            }
        }

        if switchSpeed == "KPH" {
            // Checking if speed is less than zero
            if (speedToKPH > 0) {
                speedDisplay.text = (String(format: "%.0f km/h", speedToKPH))
                arrayKPH.append(speedToKPH)
                let lowSpeed = arrayKPH.min()
                let highSpeed = arrayKPH.max()
                minSpeedLabel.text = (String(format: "%.0f km/h", lowSpeed!))
                maxSpeedLabel.text = (String(format: "%.0f km/h", highSpeed!))
                avgSpeed()
                //                print("Low: \(lowSpeed!) - High: \(highSpeed!)")
            } else {
                speedDisplay.text = "0 km/h"
            }
        }

        // Shows the N - E - S W
        headingDisplay.text = "\(dir)"

    }

    func avgSpeed(){
        if switchSpeed == "MPH" {
            let speed:[Double] = arrayMPH
            let speedAvg = speed.reduce(0, +) / Double(speed.count)
            avgSpeedLabel.text = (String(format: "%.0f", speedAvg))
            //print( votesAvg )
        } else if switchSpeed == "KPH" {
            let speed:[Double] = arrayKPH
            let speedAvg = speed.reduce(0, +) / Double(speed.count)
            avgSpeedLabel.text = (String(format: "%.0f", speedAvg))
            //print( votesAvg
        }
    }
    @IBAction func restTripButton(_ sender: Any) {
        arrayMPH = []
        arrayKPH = []
        traveledDistance = 0
        minSpeedLabel.text = "0"
        maxSpeedLabel.text = "0"
        headingDisplay.text = "None"
        speedDisplay.text = "0"
        distanceTraveled.text = "0"
        avgSpeedLabel.text = "0"
    }
    @IBAction func startTrip(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    @IBAction func endTrip(_ sender: Any) {
        locationManager.stopUpdatingLocation()
    }
}

