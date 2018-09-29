//
//  RankingViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/3/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import CoreLocation
import ImageSlideshow
import Alamofire
import AlamofireImage

class PlaceRankingViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var nameLabel1: UILabel!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var nameLabel2: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator1: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var infoButton1: UIButton!
    @IBOutlet weak var infoButton2: UIButton!

    let locationManager = CLLocationManager()
    var location: CLLocation?
    var numObj: Int = 4 // # total objects being compared; arbitrarily set at 4
    var searchResults: [Place] = []
    var itemsToRank: [Place] = []
    var finalRankArray: [Place] = []
    var currentComparison: [Place] = []
    var miniRankResults: [Place] = []
    var currentComparisonIndex:Int = 0
    var numTotalComparisons:Int = 0
    var countIndex:Int = 0 // lets you know the index of the next object to grab from the shuffledArray
    var remainingIndices:[Int] = [] // know when to stop comparisons for a given object
    var thumbFlags: [Int] = [0,0,0,0] // for the thumbs up/thumbs down buttons
    
    var choiceType: String!
    
    var filterDict = Dictionary<String, String>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoButton1.isEnabled = false
        infoButton2.isEnabled = false
        submitButton.isEnabled = false

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        if let myLocation = defaults.dictionary(forKey: "myLocation") {
            location = CLLocation(latitude: myLocation["lat"] as! CLLocationDegrees, longitude: myLocation["long"] as! CLLocationDegrees)
        }
        
        prepareItems()
        
        self.navigationItem.title = "Rank Time"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Env.iPad ? 30 : 20, weight: UIFont.Weight.heavy)]
        
        var url: URL!
        
        switch choiceType {
        case rowLabels[0]:
            filterDict["selectedRadius"] = (defaults.string(forKey: "units")! == "kilometers") ? defaults.string(forKey: "searchRadius")! : String(defaults.double(forKey: "searchRadius") * 0.621371)
            
            switch defaults.string(forKey: "foodService")! {
            case "1":
                filterDict["type"] = "meal_takeaway"
            case "2":
                filterDict["type"] = "meal_delivery"
            default:
                filterDict["type"] = "restaurant"
            }
        case rowLabels[2]:
            filterDict["selectedRadius"] = (defaults.string(forKey: "exploreUnits")! == "kilometers") ? defaults.string(forKey: "exploreSearchRadius")! : String(defaults.double(forKey: "exploreSearchRadius") * 0.621371)
            
            filterDict["type"] = defaults.string(forKey: "locationTypeValue")!
            print(filterDict["type"])
        default:
            ()
        }
        
        url = getSearchUrl(searchText: "")
        startSearch(url: url)
    }
    
    func prepareItems() {
        infoButton1.imageView?.contentMode = .scaleAspectFit
        infoButton2.imageView?.contentMode = .scaleAspectFit
        
        imageView1.layer.borderColor = UIColor.black.cgColor
        imageView1.layer.borderWidth = 2
        imageView2.layer.borderColor = UIColor.black.cgColor
        imageView2.layer.borderWidth = 2
        
        submitButton.backgroundColor = aqua
        submitButton.layer.cornerRadius = submitButton.frame.height/2
    }
    
    func loadRanks() {
        countIndex = 0
        let shuffledSearchResults = searchResults.shuffled()
        
        itemsToRank = []
        var itemNames: [String] = [] // prevent repeat names
        for result in shuffledSearchResults {
            if itemsToRank.count < numObj {
                if defaults.bool(forKey: "openOnly") {
                    if result.open_now != nil {
                        if !(itemNames.contains(result.name)) && result.open_now! {
                            itemsToRank.append(result)
                            itemNames.append(result.name)
                        }
                    }
                }
                else {
                    if !(itemNames.contains(result.name)) {
                        itemsToRank.append(result)
                        itemNames.append(result.name)
                    }
                }
            }
        }
        
        if itemsToRank.count >= 2 {
            self.numObj = itemsToRank.count
            for (index,place) in itemsToRank.enumerated() {
                getPlaceDetails(place: place, index: index)
            }
            createComparison(place1: itemsToRank[0], place2: itemsToRank[1], numNewObjects: 2)
        }
        else if itemsToRank.count == 1 {
            let myAlert = UIAlertController(title: "Could only find one place that meets your search critiera", message: "", preferredStyle: .alert)
            let showAction = UIAlertAction(title: "Show me", style: .default, handler: { _ in
                self.getPlaceDetails(place: self.itemsToRank[0], index: 0)
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FinalResultsTableViewController") as! FinalResultsTableViewController
                myVC.finalRankArray = self.itemsToRank
                myVC.choiceType = self.choiceType
                self.navigationController?.pushViewController(myVC, animated: true)
            })
            let homeAction = UIAlertAction(title: "Change search criteria", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            myAlert.addAction(showAction)
            myAlert.addAction(homeAction)
            
            if let popoverController = myAlert.popoverPresentationController {
                popoverController.sourceView = self.view
            }
            self.present(myAlert, animated: true)
        }
        else {
            let myAlert = UIAlertController(title: "Could not find enough places that meet your preferences", message: "Try using different search criteria", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            myAlert.addAction(okAction)
            
            if let popoverController = myAlert.popoverPresentationController {
                popoverController.sourceView = self.view
            }
            self.present(myAlert, animated: true)
        }
    }
    
    func createComparison(place1: Place, place2: Place, numNewObjects: Int) {
        loadPlaceImages(place: place1, imageView: imageView1, label: nameLabel1, activity: activityIndicator1)
        loadPlaceImages(place: place2, imageView: imageView2, label: nameLabel2, activity: activityIndicator2)
        countIndex = countIndex + numNewObjects
        currentComparison = [place1, place2]
    }
    
    @IBAction func submitRank(_ sender: UIButton) {
        if !(thumbFlags.occurrences(of: 1) == 2) {
            alert(message: "Rank your preference first!", title: "Hey!")
        }
        else {
            if thumbFlags[0] == 1 {
                miniRankResults = [currentComparison[0],currentComparison[1]]
            }
            else if thumbFlags[2] == 1 {
                miniRankResults = [currentComparison[1],currentComparison[0]]
            }
            prepareNextComparison()
        }
        
    }
    
    func resetThumbs() {
        thumbFlags = [0,0,0,0]
        for (index,flag) in thumbFlags.enumerated() {
            let thumbButton = view.viewWithTag(index+1) as! UIButton
            if index % 2 == 0 {
                thumbButton.setImage(UIImage(named: "thumbsUpBlank"), for: .normal)
            }
            else {
                thumbButton.setImage(UIImage(named: "thumbsDownBlank"), for: .normal)
            }
        }
    }
    
    func prepareNextComparison() {
        let numObjectsRankedInFinal = finalRankArray.count
        if numTotalComparisons == 0 { // just submitted first comparison
            finalRankArray = miniRankResults
            createComparison(place1: finalRankArray[0], place2: itemsToRank[countIndex], numNewObjects: 1)
            remainingIndices = [1]
            
            numTotalComparisons = numTotalComparisons + 1
            currentComparisonIndex = 0 // this is the index of the object being compared to the new object
            resetThumbs()
        }
        else if numTotalComparisons != 0 {
            if miniRankResults[0] == itemsToRank[countIndex-1] { //new object is #1 in current comparison;
                if remainingIndices.isEmpty || (currentComparisonIndex < remainingIndices.min()!) { // this means we're done comparing this object
                    finalRankArray.insert(miniRankResults[0], at: currentComparisonIndex)
                    
                    // Prepare new rank
                    remainingIndices = Array(0..<finalRankArray.count)
                    
                    if (numObjectsRankedInFinal % 2 == 0) {
                        currentComparisonIndex = numObjectsRankedInFinal/2 // odd # ranked now; this is index of next object being compard with new object
                    }
                    else if (numObjectsRankedInFinal % 2 == 1) {
                        let upper = finalRankArray.count/2
                        let lower = (finalRankArray.count/2)-1
                        currentComparisonIndex = lower + Int(arc4random_uniform(UInt32(upper - lower))) //random index surrounding #objects/2
                    }
                    
                    if finalRankArray.count == numObj {
                        finishedComparing()
                    }
                    else {
                        createComparison(place1: finalRankArray[currentComparisonIndex], place2: itemsToRank[countIndex], numNewObjects: 1) //  compare with middle seed
                    }
                    
                    if let nix = remainingIndices.index(of: currentComparisonIndex) { // remove this index from possible remaining indices
                        remainingIndices.remove(at: nix)
                    }
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
                else { // not done comparing here
                    remainingIndices = remainingIndices.filter{ $0 < currentComparisonIndex }
                    
                    if remainingIndices.count == 1 {
                        currentComparisonIndex = remainingIndices[0] // choose remaining middle index
                    }
                    else if remainingIndices.count % 2 == 0 {
                        let upper = remainingIndices.count/2
                        let lower = (remainingIndices.count/2)-1
                        currentComparisonIndex = remainingIndices[lower + Int(arc4random_uniform(UInt32(upper - lower)))] //random index surrounding n/2
                    }
                    else if remainingIndices.count % 2 == 1 {
                        currentComparisonIndex = remainingIndices[(remainingIndices.count-1)/2] // choose remaining middle index
                    }
                    
                    if let nix = remainingIndices.index(of: currentComparisonIndex) { // remove this index from possible remaining indices
                        remainingIndices.remove(at: nix)
                    }
                    createComparison(place1: finalRankArray[currentComparisonIndex], place2: itemsToRank[countIndex-1], numNewObjects: 0)
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
            }
            else if miniRankResults[1] == itemsToRank[countIndex-1] { //new object is #2 in current comparison;
                if remainingIndices.isEmpty || (currentComparisonIndex > remainingIndices.max()!) { // this means we're done comparing this object
                    finalRankArray.insert(miniRankResults[1], at: currentComparisonIndex+1)
                    
                    // Prepare new rank
                    remainingIndices = Array(0..<finalRankArray.count)
                    
                    if (numObjectsRankedInFinal % 2 == 0) {
                        currentComparisonIndex = numObjectsRankedInFinal/2 // odd # ranked now; this is index of next object being compard with new object
                    }
                    else if (numObjectsRankedInFinal % 2 == 1) {
                        let upper = finalRankArray.count/2
                        let lower = (finalRankArray.count/2)-1
                        currentComparisonIndex = lower + Int(arc4random_uniform(UInt32(upper - lower))) //random index surrounding #objects/2
                    }
                    
                    if finalRankArray.count == numObj {
                        finishedComparing()
                    }
                    else {
                        createComparison(place1: finalRankArray[currentComparisonIndex], place2: itemsToRank[countIndex], numNewObjects: 1) //  compare with middle seed
                    }
                    
                    if let nix = remainingIndices.index(of: currentComparisonIndex) { // remove this index from possible remaining indices
                        remainingIndices.remove(at: nix)
                    }
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
                else { // not done comparing here
                    remainingIndices = remainingIndices.filter{ $0 > currentComparisonIndex }
                    print(remainingIndices)
                    
                    if remainingIndices.count == 1 {
                        currentComparisonIndex = remainingIndices[0] // choose remaining middle index
                    }
                    else if remainingIndices.count % 2 == 0 {
                        let upper = remainingIndices.count/2
                        let lower = (remainingIndices.count/2)-1
                        currentComparisonIndex = remainingIndices[lower + Int(arc4random_uniform(UInt32(upper - lower)))] //random index surrounding n/2
                    }
                    else if remainingIndices.count % 2 == 1 {
                        currentComparisonIndex = remainingIndices[(remainingIndices.count-1)/2] // choose remaining middle index
                    }
                    
                    if let nix = remainingIndices.index(of: currentComparisonIndex) { // remove this index from possible remaining indices
                        remainingIndices.remove(at: nix)
                    }
                    createComparison(place1: finalRankArray[currentComparisonIndex], place2: itemsToRank[countIndex-1], numNewObjects: 0)
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
            }
        }
        
    }
    
    func loadPlaceImages(place: Place, imageView: UIImageView, label: UILabel, activity: UIActivityIndicatorView) {
        
        activity.startAnimating()
        label.text = "Loading..."
        
        infoButton1.isEnabled = false
        infoButton2.isEnabled = false
        submitButton.isEnabled = false
        
        let defaultImage = UIImage(named:"placeholder_image")
        
        if let photos = place.photos {
            if photos.count >= 1 {
                let photoUrlString = String(format: Constants.PLACES_PHOTO_URL, photos[0], Constants.PLACES_API_KEY)
                imageView.af_setImage(withURL: URL(string: photoUrlString)!, completion: { response in
                    activity.stopAnimating()
                })
                label.text = place.name
                label.sizeToFit()
            }
            else {
                imageView.image = defaultImage
                activity.stopAnimating()
            }
        }
        
        infoButton1.isEnabled = true
        infoButton2.isEnabled = true
        submitButton.isEnabled = true
    }
    
    func startSearch(url: URL) {
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
    
    func getSearchUrl(searchText: String) -> URL {
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
    
    func calculateDistanceToStore(storeCoordinate: CLLocation) -> Double? {
        if let location = location {
            let distanceInMeter = location.distance(from: storeCoordinate)
            let distanceinKiloMeter = distanceInMeter/1000
            print ("distance \(distanceinKiloMeter)")
            return distanceinKiloMeter
        } else {
            return nil
        }
    }
    
    @IBAction func thumbTap(_ sender: UIButton) {
        let index = sender.tag - 1
        if thumbFlags[index] == 0 {
            
            if thumbFlags.occurrences(of: 1) == 2 { // reset other icons if needed
                for (index,flag) in thumbFlags.enumerated() {
                    if flag == 1 {
                        thumbFlags[index] = 0
                        let thisButton = view.viewWithTag(index+1) as! UIButton
                        if index % 2 == 0 {
                            thisButton.setImage(UIImage(named: "thumbsUpBlank"), for: .normal)
                        }
                        else {
                            thisButton.setImage(UIImage(named: "thumbsDownBlank"), for: .normal)
                        }
                    }
                }
            }
            
            thumbFlags[index] = 1
            switch (index) {
            case 0:
                sender.setImage(UIImage(named: "thumbsUpGreen"), for: .normal)
                let compliment = view.viewWithTag(4) as! UIButton
                compliment.setImage(UIImage(named: "thumbsDownRed"), for: .normal)
                thumbFlags[3] = 1
            case 1:
                sender.setImage(UIImage(named: "thumbsDownRed"), for: .normal)
                let compliment = view.viewWithTag(3) as! UIButton
                compliment.setImage(UIImage(named: "thumbsUpGreen"), for: .normal)
                thumbFlags[2] = 1
            case 2:
                sender.setImage(UIImage(named: "thumbsUpGreen"), for: .normal)
                let compliment = view.viewWithTag(2) as! UIButton
                compliment.setImage(UIImage(named: "thumbsDownRed"), for: .normal)
                thumbFlags[1] = 1
            case 3:
                sender.setImage(UIImage(named: "thumbsDownRed"), for: .normal)
                let compliment = view.viewWithTag(1) as! UIButton
                compliment.setImage(UIImage(named: "thumbsUpGreen"), for: .normal)
                thumbFlags[0] = 1
            default: ()
            }
            
        }
        else {
            thumbFlags[index] = 0
            switch (index) {
            case 0:
                sender.setImage(UIImage(named: "thumbsUpBlank"), for: .normal)
                let compliment = view.viewWithTag(4) as! UIButton
                compliment.setImage(UIImage(named: "thumbsDownBlank"), for: .normal)
                thumbFlags[3] = 0
            case 1:
                sender.setImage(UIImage(named: "thumbsDownBlank"), for: .normal)
                let compliment = view.viewWithTag(3) as! UIButton
                compliment.setImage(UIImage(named: "thumbsUpBlank"), for: .normal)
                thumbFlags[2] = 0
            case 2:
                sender.setImage(UIImage(named: "thumbsUpBlank"), for: .normal)
                let compliment = view.viewWithTag(2) as! UIButton
                compliment.setImage(UIImage(named: "thumbsDownBlank"), for: .normal)
                thumbFlags[1] = 0
            case 3:
                sender.setImage(UIImage(named: "thumbsDownBlank"), for: .normal)
                let compliment = view.viewWithTag(1) as! UIButton
                compliment.setImage(UIImage(named: "thumbsUpBlank"), for: .normal)
                thumbFlags[0] = 0
            default: ()
            }
        }
        
    }
    
    func finishedComparing() {
        let myAlert = UIAlertController(title: "Done!", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Show me my future", style: UIAlertActionStyle.default) { (ACTION) in
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FinalResultsTableViewController") as! FinalResultsTableViewController
            myVC.finalRankArray = self.finalRankArray
            myVC.choiceType = self.choiceType
            self.navigationController?.pushViewController(myVC, animated: true)
        }
        myAlert.addAction(okAction)
        
        if let popoverController = myAlert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func showMoreInfo(_ sender: UIButton) {
        performSegue(withIdentifier: "showDetailsFromPlaceRank", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromPlaceRank" {
            if let destination = segue.destination as? PlaceDetailsViewController {
                if (sender as? UIButton)?.tag == 11 { // left button item
                    destination.place = currentComparison[0]
                }
                else if (sender as? UIButton)?.tag == 12 { // right button item
                    destination.place = currentComparison[1]
                }
            }
        }
    }

}
