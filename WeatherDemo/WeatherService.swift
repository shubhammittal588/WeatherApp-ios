//
//  WeatherService.swift
//  WeatherDemo
//
//  Created by Shubham Mittal on 02/02/22.
//  Copyright © 2022 Shubham Mittal. All rights reserved.
//

import Foundation

open class WeatherService {
  public typealias WeatherDataCompletionBlock = (_ data: WeatherData?) -> ()
  
  let openWeatherBaseAPI = "http://api.openweathermap.org/data/2.5/weather?appid=97cce5b42320d87100a885f5dfa0dac9&units=metric&q="
  let urlSession:URLSession = URLSession.shared
  
  open class func sharedWeatherService() -> WeatherService {
    return _sharedWeatherService
  }
  
  open func getCurrentWeather(_ location:String, completion: @escaping WeatherDataCompletionBlock) {
    let openWeatherAPI = openWeatherBaseAPI + location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    print(openWeatherAPI)
    let request = URLRequest(url: URL(string: openWeatherAPI)!)
    let weatherData = WeatherData()
    
    let task = urlSession.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
      
      guard let data = data else {
        if let error = error  {
          print(error)
        }
        
        return
      }
      
      // Retrieve JSON data
      do {
        let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary
        
        // Parse JSON data
        let jsonWeather = jsonResult?["weather"] as! [AnyObject]
        
        for jsonCurrentWeather in jsonWeather {
          weatherData.weather = jsonCurrentWeather["description"] as! String
        }
        
        let jsonMain = jsonResult?["main"] as! Dictionary<String, AnyObject>
        weatherData.temperature = Int(truncating: jsonMain["temp"] as! NSNumber)
        
        completion(weatherData)
        
      } catch {
        print(error)
      }
    })
    
    task.resume()
  }
}

let _sharedWeatherService: WeatherService = { WeatherService() }()
