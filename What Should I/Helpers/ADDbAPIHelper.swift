//
//  ADDbAPIHelper.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/14/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit

// NO LONGER IN USE B/C ABSOLUT NO LONGER SUPPORTS THEIR API

func getADDbSearchUrl() -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "addb.absolutdrinks.com"
    let base = "/drinks/rating/gte\(defaults.double(forKey: "drinkRating")*20)"
    if defaults.bool(forKey: "withAlcohol") {
        if defaults.string(forKey: "madeWith")! != defaults.stringArray(forKey: "liquorOptions")![0] {
            urlComponents.path = "\(base)/alcoholic/withtype/\(defaults.string(forKey: "madeWith")!)/"
        }
        else {
            urlComponents.path = "\(base)/alcoholic/"
        }
    }
    else {
        urlComponents.path = "\(base)/not/alocholic/"
    }
    
    let apiQueryItem = URLQueryItem(name: "apiKey", value: "a676605b108948d2aeca7b21baade00d")
    //let skipItem = URLQueryItem(name: "start", value: "\(Int(arc4random_uniform(UInt32(3500))))") // 3534 items as of 2/15/18
    
    urlComponents.queryItems = [apiQueryItem]
    print(urlComponents)
    return urlComponents.url!
}


func parseADDb(json data: Data) -> [String: Any]? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String:Any]
    } catch {
        print("JSON Error: \(error)")
        return nil
    }
}

func parseADDb(dictionary: [String: Any]) -> [Drink] {
    guard let array = dictionary["result"] as? [Any], array.count > 0  else {
        print("Expected 'results' array or Array is empty")
        return []
    }
    
    var searchResults: [Drink] = []
    for resultDict in array {
        
        var drink = Drink()
        if let resultDict = resultDict as? [String : Any] {
            
            if let name = resultDict["name"] as? String {
                drink.name = name
            }
            
            if let drink_id = resultDict["id"] as? String {
                drink.drinkId = drink_id
            }
            
            if let directions = resultDict["descriptionPlain"] as? String {
                drink.directions = directions
            }
            
            if let story = resultDict["story"] as? String {
                drink.story = story
            }
            
            if let rating = resultDict["rating"] as? Int {
                drink.rating = "\(rating)"
            }
            
            if let skill = resultDict["skill"] as? String {
                drink.skill = skill
            }
            
            if let ingredientDict = resultDict["ingredients"] as? [Any] {
                var ingredientArray = [String]()
                for ingredients in ingredientDict {
                    if let ingredients = ingredients as? [String : Any] {
                        if let ingredient = ingredients["textPlain"] as? String {
                            ingredientArray.append(ingredient)
                        }
                    }
                }
                //drink.ingredients = ingredientArray.joined(separator: "\n")
            }
            
            if let tasteDict = resultDict["tastes"] as? [Any] {
                var tasteArray = [String]()
                for tastes in tasteDict {
                    if let tastes = tastes as? [String: Any] {
                        if let taste = tastes["text"] as? String {
                            tasteArray.append(taste)
                        }
                    }
                }
                drink.tastes = tasteArray.joined(separator: ", ")
            }
            
            if let toolsDict = resultDict["tools"] as? [Any] {
                var toolsArray = [String]()
                for tools in toolsDict {
                    if let tools = tools as? [String: Any] {
                        if let tool = tools["text"] as? String {
                            toolsArray.append(tool)
                        }
                    }
                }
                drink.tools = toolsArray.joined(separator: ", ")
            }
            
            if let videos = resultDict["videos"] as? [Any] {
                for video in videos {
                    if let video = video as? [String: Any] {
                        if video["type"] as? String == "assets" {
                            drink.videoName = video["video"] as? String
                        }
                    }
                }
                
            }
            
            searchResults.append(drink)
        }
        
    }
    return searchResults
}


