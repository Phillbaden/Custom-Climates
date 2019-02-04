//
//  ViewController.swift
//  Custom Climates
//
//  Created by Phillip Badenhorst on 8/1/2019.
//  Copyright © 2019 Phillip Badenhorst. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

let KELVIN_DIFFERENCE = 273.15

class WeatherViewController: UIPageViewController {
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let locationManager = CLLocationManager()
    var pageControl = UIPageControl()
    var resultSearchController: UISearchController? = nil
    
    // TODO: create property of type Array containing weather view controllers
    var fiveDayWeatherArray: Array<WeatherInfoViewController> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        self.setViewControllers([newWeatherViewController(temp: 0, location: "", conditionID: -999, date: "2019-01-01") ?? UIViewController()], direction: .forward, animated: false, completion: nil)
        setupSearchBar()
        setupPageControl()
        setupLocationManager()
    }

    func setupPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 50, width: UIScreen.main.bounds.width, height: 50))
        pageControl.tintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.currentPageIndicatorTintColor = UIColor.black
        view.addSubview(pageControl)
        configurePageControl()
    }
    
    func setupSearchBar() {
        let searchBar = resultSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search for new city"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    func configurePageControl() {
        // TODO: update useage of "self.viewController" to use the array of weather view controllers property
        self.pageControl.numberOfPages = self.fiveDayWeatherArray.count
        self.pageControl.currentPage = 0
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    //MARK: - Networking
    
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { [weak self] response in
            if response.result.isSuccess {
                print("Obtained weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                let weatherDataMatrix = WeatherDataModel.parseWeatherJSONData(json: weatherJSON)
                self?.setupViewControllers(with: weatherDataMatrix)
            } else {
                print("Error \(String(describing: response.result.error))")
                let firstWeatherInfo = self?.fiveDayWeatherArray.first
                firstWeatherInfo?.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    //MARK: - PageViewController methods
    private func newWeatherViewController(temp: Double, location: String, conditionID: Int, date: String) -> UIViewController? {
        let weatherInfoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeatherInfoViewController") as? WeatherInfoViewController
        // TODO: Call loadView on the property you create for the WeatherContoller you created.
        weatherInfoViewController?.loadViewIfNeeded()
        weatherInfoViewController?.tempLabel.text = String(Int(round(temp - KELVIN_DIFFERENCE))) + " °C"
        weatherInfoViewController?.cityLabel.text = location
        weatherInfoViewController?.weatherIcon.image = UIImage(named: WeatherDataModel.imageConditionName(condition: conditionID))
        // check this date
        weatherInfoViewController?.dateLabel.text = date
        return weatherInfoViewController
    }
    
    // MARK: - View Controller setup
    func setupViewControllers(with weekWeatherInfo: Array<DayWeatherData>){
        var weatherDataInfoViewControllerArray = [UIViewController?]()
        for dayWeatherInfo in weekWeatherInfo {
            // TODO: then setup the view controller with the data you have in the dayWeatherInfo object
            let firstWeatherViewController = newWeatherViewController(temp: dayWeatherInfo.averageTemp, location: dayWeatherInfo.city, conditionID: dayWeatherInfo.mostFrequentConditionID, date: dayWeatherInfo.day)
            // TODO: add above view controller to array of weather view controllers
            weatherDataInfoViewControllerArray.append(firstWeatherViewController)
        }
        fiveDayWeatherArray = weatherDataInfoViewControllerArray as! Array<WeatherInfoViewController>
        // TODO: set "self.viewControllers" as the first item in the weather view controllers array
        self.setViewControllers([fiveDayWeatherArray.first!], direction: .forward, animated: true, completion: nil)
        // TODO: reconfigure the page view controller
        setupPageControl()
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    //Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            self.locationManager.stopUpdatingLocation()
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            getWeatherDataWith(lat: String(location.coordinate.latitude),
                           lon: String(location.coordinate.longitude))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
        
    func getWeatherDataWith(lat: String, lon: String) {
        let latitude = lat
        let longitude = lon
        let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        let firstWeatherInfo = fiveDayWeatherArray.first
        firstWeatherInfo?.cityLabel.text = "Location Unavailable"
    }
}

extension WeatherViewController: UIPageViewControllerDataSource {
    // TODO: update all useages of "self.viewController" to use the array of weather view controllers property
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = fiveDayWeatherArray.firstIndex(of: viewController as! WeatherInfoViewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return fiveDayWeatherArray.last
        }
        guard fiveDayWeatherArray.count > previousIndex else {
            return nil
        }
        return fiveDayWeatherArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = fiveDayWeatherArray.firstIndex(of: viewController as! WeatherInfoViewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let viewControllerCount = fiveDayWeatherArray.count
        guard viewControllerCount != nextIndex else {
            return fiveDayWeatherArray.first
        }
        guard viewControllerCount > nextIndex else {
            return nil
        }
        return fiveDayWeatherArray[nextIndex]
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return fiveDayWeatherArray.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = fiveDayWeatherArray.first,
            let firstViewControllerIndex = fiveDayWeatherArray.firstIndex(of: firstViewController) else {
            return 0
        }
        return firstViewControllerIndex
    }
    
}

extension WeatherViewController: UIPageViewControllerDelegate {
    // TODO: update all useages of "self.viewController" to use the array of weather view controllers property
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        // TODO: update this method to get the index of the last view controller in the array of previous view controllers and add 1 to the index count then return that
        
        guard let viewControllerIndex = fiveDayWeatherArray.firstIndex(of: pageContentViewController as! WeatherInfoViewController) else {
            return
        }
        self.pageControl.currentPage = viewControllerIndex
    }
}

