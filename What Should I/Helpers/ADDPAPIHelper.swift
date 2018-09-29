//
//  ADDPAPIHelper.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/14/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit

func startADDbSearch(url: URL) {
    let session = URLSession.shared
    
    let dataTask = session.dataTask(with: url, completionHandler: {
        data, response, error in
        
        if let error = error {
            print("Failure! \(error)")
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            if let data = data, let jsonDictionary = self.parse(json: data) {
                self.searchResults = self.parse(dictionary: jsonDictionary)
                print("self.searchResults \(self.searchResults)")
                
                DispatchQueue.main.async {
                    self.loadRanks()
                }
                return
            }
        } else {
            print("Fail! \(response!)")
        }
        
    })
    
    dataTask.resume()
}

func getADDbSearchUrl(searchText: String) -> URL {
    let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    
    let latitude = String(format: "%f", location!.coordinate.latitude)
    let longitude = String(format: "%f", location!.coordinate.longitude)
    let radius = String(format: "%.0f", Float(filterDict["selectedRadius"]!)! * 1000)
    let types = filterDict["type"]
    
    let urlString = String(format:
        Constants.PLACES_SEARCH_URL, latitude, longitude, radius, types!, escapedSearchText, Constants.PLACES_API_KEY)
    
    let url = URL(string: urlString)
    print("url ==> \(url!)")
    return url!
}

func getPlaceDetails(place: Place, index: Int) {
    let urlString = String(format: Constants.PLACES_DETAIL_URL, place.place_id, Constants.PLACES_API_KEY)
    
    let url = URL(string: urlString)
    let session = URLSession.shared
    
    //3
    let dataTask = session.dataTask(with: url!, completionHandler: {
        data, response, error in
        // 4
        if let error = error {
            print("Failure! \(error)")
        } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200{
            if let data = data, let jsonDictionary = self.parse(json: data) {
                
                print("data jsonDictionary")
                self.parseDetails(dictionary: jsonDictionary, index: index)
                
                return
            }
            //print("data \(data)")
        } else {
            print("Fail! \(response!)")
        }
        
    })
    // 5
    dataTask.resume()
}


func parse(json data: Data) -> [String: Any]? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String:Any]
    } catch {
        print("JSON Error: \(error)")
        return nil
    }
}

func parse(dictionary: [String: Any]) -> [Place] {
    guard let status = dictionary["status"] as? String, status == "OK"  else {
        print(dictionary["status"] as! String)
        print(dictionary["error_message"] as! String)
        print("Invalid status")
        return []
    }
    
    guard let array = dictionary["results"] as? [Any], array.count > 0  else {
        print("Expected 'results' array or Array is empty")
        return []
    }
    
    var searchResults: [Place] = []
    for resultDict in array {
        
        var place:Place
        if let resultDict = resultDict as? [String : Any] {
            
            if let name = resultDict["name"] as? String, let place_id = resultDict["place_id"] as? String, let geometryDict = resultDict["geometry"] as? [String : Any] {
                if let locationDict = geometryDict["location"] as? [String : Any] {
                    if let lat = locationDict["lat"] as? Double, let lng = locationDict["lng"] as? Double {
                        
                        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                        
                        place = Place(name: name, place_id: place_id, locationCoordinate: coordinate)
                        print(place.name)
                        
                        if let rating = resultDict["rating"] as? Double {
                            place.rating = rating
                        }
                        
                        if let vicinity = resultDict["vicinity"] as? String {
                            place.vicinity = vicinity
                        }
                        
                        if let hoursDict = resultDict["opening_hours"] as? [String : Any] {
                            if let openNow = hoursDict["open_now"] as? Bool {
                                place.open_now = openNow
                                print("place.open_now \(place.open_now!)")
                            }
                        }
                        
                        if let location = location {
                            let storeLocation: CLLocation = CLLocation(latitude: lat, longitude: lng)
                            place.distance = calculateDistanceToStore(storeCoordinate: storeLocation)
                        }
                        
                        var photosList = [String]()
                        if let photosArray = resultDict["photos"] as? [Any]{
                            for photoDict in photosArray {
                                if let photoDict = photoDict as? [String : Any] {
                                    if let photoReference = photoDict["photo_reference"] {
                                        photosList.append(photoReference as! String)
                                    }
                                }
                            }
                        }
                        place.photos = photosList
                        
                        searchResults.append(place)
                    }
                }
            }
        }
    }
    return searchResults
}

func parseDetails(dictionary: [String: Any], index: Int) {
    guard let status = dictionary["status"] as? String, status == "OK"  else {
        print("Invalid status >> \(dictionary["status"]! as? String)")
        return
    }
    
    
    guard let resultDict = dictionary["result"] as? [String : Any] else {
        print("Expected 'result' as dict")
        return
    }
    
    
    if let phoneNo = resultDict["international_phone_number"] as? String {
        itemsToRank[index].phone_number = phoneNo
        print("place!.phone_number \(itemsToRank[index].phone_number)")
    }
    
    if let openingHoursDict = resultDict["opening_hours"] as? [String : Any]{
        if let openingHoursArr = openingHoursDict["weekday_text"] as? [String] {
            itemsToRank[index].timings = openingHoursArr
            //print("place!.timings \(place!.timings)")
        }
    }
    
    var photosList = [String]()
    if let photosArray = resultDict["photos"] as? [Any]{
        for photoDict in photosArray {
            if let photoDict = photoDict as? [String : Any] {
                if let photoReference = photoDict["photo_reference"] {
                    photosList.append(photoReference as! String)
                }
            }
        }
    }
    itemsToRank[index].photos = photosList
    
    var reviewList = [Review]()
    if let reviewArray = resultDict["reviews"] as? [Any]{
        for reviewDict in reviewArray {
            if let reviewDict = reviewDict as? [String : Any] {
                if let author_name = reviewDict["author_name"],
                    let profile_photo_url = reviewDict["profile_photo_url"],
                    let rating = reviewDict["rating"] as? Float,
                    let relative_time_description = reviewDict["relative_time_description"],
                    let text = reviewDict["text"]{
                    
                    let review = Review(username: author_name as! String, review_text: text as! String, review_time: relative_time_description as! String, user_profile_image: profile_photo_url as! String, rating: rating)
                    //                        print("author_name \(author_name) ")
                    //                        print("profile_photo_url \(profile_photo_url) ")
                    //                        print("rating \(rating) ")
                    //                        print("relative_time_description \(relative_time_description) ")
                    //                        print("text \(text) ")
                    reviewList.append(review)
                }
            }
        }
    }
    itemsToRank[index].reviews = reviewList
}
