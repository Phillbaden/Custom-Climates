//
//  WeatherDataModel.swift
//  Custom Climates
//
//  Created by Phillip Badenhorst on 8/1/2019.
//  Copyright © 2019 Phillip Badenhorst. All rights reserved.
//

import UIKit
import Foundation
import SwiftyJSON

protocol WeatherDataParsor {
    static func parseWeatherJSONData(json: JSON) -> Array<DayWeatherData>
}

class WeatherDataModel {
    var temperature: Double = 0.0
    var condition: Int = 0
    var city: String = ""
    var weatherIconName: String = ""
    var date: Date?
    var day: String?
    
    static func imageConditionName(condition: Int) -> String {
        switch (condition) {
        case 0...300 :
            return "tstorm1"
        case 301...500 :
            return "light_rain"
        case 501...600 :
            return "shower3"
        case 601...700 :
            return "snow4"
        case 701...771 :
            return "fog"
        case 772...799 :
            return "tstorm3"
        case 800 :
            return "sunny"
        case 801...804 :
            return "cloudy2"
        case 900...903, 905...1000  :
            return "tstorm3"
        case 903 :
            return "snow5"
        case 904 :
            return "sunny"
        default :
            return "dunno"
        }
    }
}

extension WeatherDataModel: WeatherDataParsor {
    static func parseWeatherJSONData(json: JSON) -> Array<DayWeatherData> {
        var weatherMatrix = Array<DayWeatherData>()
        let dateFormatterWeather = DateFormatter()
        if !dateFormatterWeather.locale.identifier.contains("_POSIX") {
            let locale = dateFormatterWeather.locale.identifier+"_POSIX"
            dateFormatterWeather.locale = Locale.init(identifier: locale)
        }
        dateFormatterWeather.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterDay = DateFormatter()
        dateFormatterDay.dateFormat = "yyyy-MM-dd"
        let city = json["city"]["name"].stringValue
        
        // Exluded 5th day, due to NaN temp error
        for _ in 0...4 {
            weatherMatrix.append(DayWeatherData())
        }
        
        for listItem in json["list"].arrayValue {
            let weatherData = WeatherDataModel()
            let time = listItem["dt_txt"].stringValue
            weatherData.date = dateFormatterWeather.date(from: time)
            let weatherArray = listItem["weather"].arrayValue
            weatherData.condition = weatherArray.first?["id"].intValue ?? 0
            weatherData.temperature = listItem["main"]["temp"].doubleValue
            weatherData.city = city
            
            for index in 0...weatherMatrix.count - 1 {
                if weatherMatrix[index].weatherData.count > 0 {
                    if let jsonDate = weatherData.date,
                        let existingDateInArray = weatherMatrix[index].date,
                        Calendar.current.compare(jsonDate, to: existingDateInArray, toGranularity: .day) == .orderedSame {
                        weatherMatrix[index].weatherData.append(weatherData)
                        break
                    }
                } else {
                    weatherMatrix[index].weatherData.append(weatherData)
                    weatherMatrix[index].date = weatherData.date
                    weatherMatrix[index].city = weatherData.city
                    if let weatherDate = weatherData.date {
                        weatherData.day = dateFormatterDay.string(from: weatherDate)
                    }
                    weatherMatrix[index].day = weatherData.day ?? "N/A"
                    break
                }
            }
        }
        return weatherMatrix
    }
}
