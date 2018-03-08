//
//  ISSPasstimeViewController.swift
//  ISS_Passtime
//
//  Created by Jagadish R Hattigud on 06/03/18.
//  Copyright © 2018 Jagadish R Hattigud. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class ISSPasstimeViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var latitudeLabel: UITextField!
    @IBOutlet weak var longitudeLabel: UITextField!

    var passTimes = [String:String]()
    @IBOutlet weak var isspasstimetableview: UITableView!
    var passTimeDict = [String : String]()
    var passTimeArray : NSArray = [-1]
    var durationArray:NSArray = [0]
    var risetimeArray : NSArray = [0]
    var retfromMap :[AnyObject] = []
    var currentLatitude: String = ""
    var currentLongitude:String = ""
    var locationManager:CLLocationManager!
    let BASEURL = "http://api.open-notify.org/iss-pass.json"

    override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //determineMyCurrentLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        triggerCoordinateCapture()
    }
    
    // This method triggers capture of co-ordinates
    func triggerCoordinateCapture() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    // Display current location co-ordinates on clicking "Get Coordinates"
    @IBAction func getCurrentLocationCordinates(_ sender: UIButton) {
        triggerCoordinateCapture()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        latitudeLabel.text = String(userLocation.coordinate.latitude)
        longitudeLabel.text = String(userLocation.coordinate.longitude)
        currentLatitude = String(userLocation.coordinate.latitude)
        currentLongitude = String(userLocation.coordinate.longitude)
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    private func locationManager(manager: CLLocationManager!,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var shouldIAllow = false
        var locationStatus : NSString = "Not Started"
        switch status {
        case CLAuthorizationStatus.restricted:
                locationStatus = "Restricted Access to location"
            case CLAuthorizationStatus.denied:
                locationStatus = "User denied access to location"
            case CLAuthorizationStatus.notDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
            }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LabelHasbeenUpdated"), object: nil)
            if (shouldIAllow == true) {
            NSLog("Location to Allowed")
            // Start location services
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
        }
    }
    
    func callPassListService(currentlat:String, currentlon:String) {
        let url = URL(string: BASEURL as String)!
        var urlRequest = URLRequest(url: url)

        let parameters: Parameters = ["lat": currentlat,"lon":currentlon]
        do {
            let encodedURLRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)
            Alamofire.request(encodedURLRequest).responseJSON { response in
            print(response)

            if let json = response.result.value {
                print("JSON: \(json)")
                if let successDict = response.result.value as? NSDictionary {
                    //fetch response array
                    self.passTimeArray  = successDict["response"] as! NSArray
                    //map array
                    self.retfromMap = self.passTimeArray.map { key in
                        return (key as AnyObject)
                    }
                    self.isspasstimetableview.reloadData()
                }
            }
        }
        } catch {
            print("Alamo Error")
        }

    }
    
    @IBAction func generateisspasstime(_ sender: UIButton) {
        if (self.currentLatitude.characters.count > 0 && self.currentLongitude.characters.count > 0) {
            callPassListService(currentlat: self.currentLatitude, currentlon: self.currentLongitude)
        }
    }
    
    // If we have been deined access give the user the option to change it
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to deliver pizza we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //table view delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.passTimeArray.count > 0 && self.retfromMap.count > 0) {
            return self.passTimeArray.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.isspasstimetableview?.dequeueReusableCell(withIdentifier: "ISSPasstimeTableViewCell", for: indexPath) as! ISSPasstimeTableViewCell
        if self.passTimeArray.count > 0 && self.retfromMap.count > 0 {
            cell.durationLabel.text = "Dur"
            if let dur = (retfromMap[indexPath.row].value(forKey:"duration")) as? AnyObject {
                cell.durationTextDisplay.text = String(describing: dur)
            }
            
            cell.risetimeLabel.text = "RT"
            //==== timestamp convertion
            let temp = retfromMap[indexPath.row].value(forKey:"risetime") as! Double
            let date = NSDate(timeIntervalSince1970:temp)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            //print("formatted date is \(formatter.string(from: date as Date))")
            //==== timestamp convertion
            cell.risetimeTextDisplay.text = (formatter.string(from: date as Date))

        return cell
        } else {
            return UITableViewCell()
            
        }
    }
}
