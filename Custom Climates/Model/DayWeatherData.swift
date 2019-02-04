//
//  DayWeatherData.swift
//  Custom Climates
//
//  Created by Phillip Badenhorst on 13/1/2019.
//  Copyright © 2019 Phillip Badenhorst. All rights reserved.
//

import UIKit
import SwiftyJSON

class DayWeatherData: NSObject {
    var date: Date?
    var city: String = ""
    var day: String = ""
    var averageTemp: Double {
        var tempSum = 0.0
        for weatherItem in weatherData {
            tempSum = tempSum + weatherItem.temperature
        }
        return tempSum / Double(weatherData.count)
    }
    var weatherData: Array<WeatherDataModel> = []
    var mostFrequentConditionID: Int {
        let conditionID = usedConditionID()
        return conditionID ?? 0
    }
    
    func usedConditionID() -> Int? {
        var weatherDataConditionIDArray: Array<Int> = []
        for model in weatherData{
            let conditionID = model.condition
            weatherDataConditionIDArray.append(conditionID)
        }
        var counts = [Int: Int]()
        weatherDataConditionIDArray.forEach { (conditionID) in
            counts[conditionID] = (counts[conditionID] ?? 0) + 1
        }
        let conditionIDMaxCountKeyValuePair = counts.max { (conditionID1, conditionID2) -> Bool in
            conditionID1 < conditionID2
        }
        let mostFrequentConditionID = conditionIDMaxCountKeyValuePair?.key
        return mostFrequentConditionID
    }
}
