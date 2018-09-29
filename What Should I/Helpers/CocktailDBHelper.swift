//
//  CocktailDBHelper.swift
//  What Should I
//
//  Created by Tony Jiang on 9/3/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import Foundation

// api key = 8543

func getCocktailDBSearchUrl() -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.thecocktaildb.com"
    let base = "/api/json/v1/8543"
    if defaults.bool(forKey: "withAlcohol") {
        if defaults.string(forKey: "madeWith")! != defaults.stringArray(forKey: "liquorOptions")![0] {
            urlComponents.path = "\(base)/filter.php"
            urlComponents.query = "i=\(defaults.string(forKey: "madeWith")!)"
        }
        else { // no preference chosen
            urlComponents.path = "\(base)/random.php"
        }
    }
    else {
        urlComponents.path = "\(base)/filter.php"
        urlComponents.query = "a=Non_Alcoholic"
    }
    
    print(urlComponents)
    return urlComponents.url!
}

func getSpecificCocktailURL(drinkID: String) -> URL {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.thecocktaildb.com"
    
    let base = "/api/json/v1/8543"
    urlComponents.path = "\(base)/lookup.php"
    urlComponents.query = "i=\(drinkID)"
    
    print(urlComponents)
    return urlComponents.url!
}

func parseCocktailDB(json data: Data) -> [String: Any]? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String:Any]
    } catch {
        print("JSON Error: \(error)")
        return nil
    }
}

func parseCocktailDB(dictionary: [String: Any]) -> [Drink] {
    guard let array = dictionary["drinks"] as? [Any], array.count > 0  else {
        print("Expected 'results' array or Array is empty")
        return []
    }
    
    var searchResults: [Drink] = []
    for resultDict in array {
        
        let drink = Drink()
        if let resultDict = resultDict as? [String : Any] {
            
            if let name = resultDict["strDrink"] as? String {
                drink.name = name
            }
            
            if let drink_id = resultDict["idDrink"] as? String {
                drink.drinkId = drink_id
            }
            
            if let directions = resultDict["strInstructions"] as? String {
                drink.directions = directions
            }
            
            if let thumbnail = resultDict["strDrinkThumb"] as? String {
                drink.thumbnailURLString = thumbnail
            }
            
            var ingredients = [String]()
            for i in 1...15 {
                if let ingredient = resultDict["strIngredient\(i)"] as? String {
                    if ingredient != "" {
                        ingredients.append(ingredient)
                    }
                }
            }
            drink.ingredients = ingredients
            
            var measurements = [String]()
            for i in 1...15 {
                if let measurement = resultDict["strMeasure\(i)"] as? String {
                    if measurement != "" {
                        measurements.append(measurement)
                    }
                }
            }
            drink.measurements = measurements
            
            searchResults.append(drink)
        }
        
    }
    return searchResults
}
