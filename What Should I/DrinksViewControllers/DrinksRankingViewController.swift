//
//  DrinksRankingViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/14/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import GoogleMobileAds

class DrinksRankingViewController: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var nameLabel1: UILabel!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var nameLabel2: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator1: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var infoButton1: UIButton!
    @IBOutlet weak var infoButton2: UIButton!
    
    var numObj: Int = 4 // # total objects being compared; arbitrarily set at 4
    var currentSearchTask: URLSessionDataTask?
    var thumbnailDownloadTask: URLSessionDataTask?
    var searchResults: [Drink] = []
    var itemsToRank: [Drink] = []
    var finalRankArray: [Drink] = []
    var currentComparison: [Drink] = []
    var miniRankResults: [Drink] = []
    var currentComparisonIndex:Int = 0
    var numTotalComparisons:Int = 0
    var countIndex:Int = 0 // lets you know the index of the next object to grab from the shuffledArray
    var remainingIndices:[Int] = [] // know when to stop comparisons for a given object
    var thumbFlags: [Int] = [0,0,0,0] // for the thumbs up/thumbs down buttons
    
    var choiceType: String!
    
    var interstitial: GADInterstitial!
    
    var group = DispatchGroup()
    var group2 = DispatchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !defaults.bool(forKey: "premium") {
            //showAds()
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        prepareItems()
        
        self.navigationItem.title = "Rank Time"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Env.iPad ? 30 : 20, weight: UIFont.Weight.heavy)]
        
        if defaults.bool(forKey: "withAlcohol") {
            if defaults.string(forKey: "madeWith")! == defaults.stringArray(forKey: "liquorOptions")![0] { // no preference = need 4 randoms
                for _ in 0..<numObj {
                    group.enter()
                    let url = getCocktailDBSearchUrl()
                    startRandomSearch(url: url)
                }
                group.notify(queue: .main) {
                    print("Finished all requests.")
                    DispatchQueue.main.async {
                        self.loadRanks()
                    }
                }
            }
            else {
                let url = getCocktailDBSearchUrl()
                startADDbSearch(url: url)
            }
            
        }
        else {
            let url = getCocktailDBSearchUrl()
            startADDbSearch(url: url)
        }
        
    }
    
    func showAds() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6869347155518066/1525929154")
        interstitial.delegate = self
        let request = GADRequest()
        //request.testDevices = [ kGADSimulatorID, "b4ff0166b130d69f021e40b34ffabcb9" ]
        interstitial.load(request)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if interstitial.isReady {
            defaults.set(0, forKey: "adCount")
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func startRandomSearch(url: URL) { // for random cocktail drink
        searchResults = []
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            if let error = error {
                print("Failure! \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data, let jsonDictionary = parseCocktailDB(json: data) {
                    let result = parseCocktailDB(dictionary: jsonDictionary)
                    self.itemsToRank.append(result[0])
                    self.group.leave()
                    return
                }
            } else {
                print("Fail! \(response!)")
                let myAlert = UIAlertController(title: "Could not access drinks", message: "Please try again later", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                myAlert.addAction(okAction)
                
                if let popoverController = myAlert.popoverPresentationController {
                    popoverController.sourceView = self.view
                }
                self.present(myAlert, animated: true)
            }
        })
        dataTask.resume()
    }
    
    func startADDbSearch(url: URL) {
        searchResults = []
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            if let error = error {
                print("Failure! \(error)")
            } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data, let jsonDictionary = parseCocktailDB(json: data) {
                    self.searchResults = parseCocktailDB(dictionary: jsonDictionary)
                    //print("self.searchResults \(self.searchResults)")
                    let shuffledSearchResults = self.searchResults.shuffled()
                    
                    if shuffledSearchResults.count < self.numObj {
                        self.itemsToRank = shuffledSearchResults
                    }
                    else {
                        self.itemsToRank = Array(shuffledSearchResults.prefix(upTo: self.numObj))
                    }
                    
                    // loop through items to rank and get the remaining info
                    for (index,item) in self.itemsToRank.enumerated() {
                        self.group2.enter()
                        let url = getSpecificCocktailURL(drinkID: item.drinkId!)
                        self.getRemainingInfo(url: url, index: index)
                    }
                    
                    self.group2.notify(queue: .main) {
                        print("Finished getting specific details.")
                        DispatchQueue.main.async {
                            self.loadRanks()
                        }
                    }
                    
                    return
                }
            } else {
                print("Fail! \(response!)")
                let myAlert = UIAlertController(title: "Could not access drinks", message: "Please try again later", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                myAlert.addAction(okAction)
                
                if let popoverController = myAlert.popoverPresentationController {
                    popoverController.sourceView = self.view
                }
                self.present(myAlert, animated: true)
            }
        })
        dataTask.resume()
    }
    
    func loadRanks() {
        countIndex = 0
        
        if itemsToRank.count >= 2 {
            self.numObj = itemsToRank.count
            createComparison(drink1: itemsToRank[0], drink2: itemsToRank[1], numNewObjects: 2)
        }
        else if itemsToRank.count == 1 {
            let myAlert = UIAlertController(title: "Could only find one drink that meets your search critiera", message: "", preferredStyle: .alert)
            let showAction = UIAlertAction(title: "Show me", style: .default, handler: { _ in
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FinalDrinksTableViewController") as! FinalDrinksTableViewController
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
    
    func createComparison(drink1: Drink, drink2: Drink, numNewObjects: Int) {
        self.loadDrinkImages(drink: drink1, imageView: self.imageView1, label: self.nameLabel1, activity: self.activityIndicator1)
        self.loadDrinkImages(drink: drink2, imageView: self.imageView2, label: self.nameLabel2, activity: self.activityIndicator2)
        self.countIndex = self.countIndex + numNewObjects
        self.currentComparison = [drink1, drink2]
        
    }
        
    func getRemainingInfo(url: URL, index: Int) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            if let error = error {
                print("Failure! \(error)")
            }
            else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let data = data, let jsonDictionary = parseCocktailDB(json: data) {
                    self.searchResults = parseCocktailDB(dictionary: jsonDictionary)
                    self.itemsToRank[index] = self.searchResults[0]
                }
            }
            self.group2.leave()
        })
        dataTask.resume()
    }
    
    func prepareItems() {
        infoButton1.imageView?.contentMode = .scaleAspectFit
        infoButton2.imageView?.contentMode = .scaleAspectFit
        
        imageView1.layer.borderColor = UIColor.black.cgColor
        imageView1.layer.borderWidth = 2
        imageView2.layer.borderColor = UIColor.black.cgColor
        imageView2.layer.borderWidth = 2
        
        nameLabel1.text = "Loading..."
        nameLabel2.text = "Loading..."
        
        infoButton1.isEnabled = false
        infoButton2.isEnabled = false
        submitButton.isEnabled = false
        submitButton.backgroundColor = aqua
        submitButton.layer.cornerRadius = submitButton.frame.height/2
    }
    
    func loadDrinkImages(drink: Drink, imageView: UIImageView, label: UILabel, activity: UIActivityIndicatorView) {
        
        activity.startAnimating()
        infoButton1.isEnabled = false
        infoButton2.isEnabled = false
        submitButton.isEnabled = false
        label.text = "Loading..."
        
        if let urlString = drink.thumbnailURLString {
            imageView.downloaded(from: urlString)
        }
        else {
            imageView.image = UIImage(named: "placeholder_inage")!
        }
        
        label.text = drink.name!
        label.sizeToFit()
        self.infoButton1.isEnabled = true
        self.infoButton2.isEnabled = true
        self.submitButton.isEnabled = true
        activity.stopAnimating()
    }
    
    func prepareNextComparison() {
        let numObjectsRankedInFinal = finalRankArray.count
        if numObj == 2 {
            finalRankArray = miniRankResults
            finishedComparing()
        }
        else if numTotalComparisons == 0 { // just submitted first comparison
            finalRankArray = miniRankResults
            createComparison(drink1: finalRankArray[0], drink2: itemsToRank[countIndex], numNewObjects: 1)
            remainingIndices = [1]
            
            numTotalComparisons = numTotalComparisons + 1
            currentComparisonIndex = 0 // this is the index of the object being compared to the new object
            resetThumbs()
        }
        else if numTotalComparisons != 0 {
            if miniRankResults[0].name == itemsToRank[countIndex-1].name { //new object is #1 in current comparison;
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
                        createComparison(drink1: finalRankArray[currentComparisonIndex], drink2: itemsToRank[countIndex], numNewObjects: 1) //  compare with middle seed
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
                    createComparison(drink1: finalRankArray[currentComparisonIndex], drink2: itemsToRank[countIndex-1], numNewObjects: 0)
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
            }
            else if miniRankResults[1].name == itemsToRank[countIndex-1].name { //new object is #2 in current comparison;
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
                        createComparison(drink1: finalRankArray[currentComparisonIndex], drink2: itemsToRank[countIndex], numNewObjects: 1) //  compare with middle seed
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
                    createComparison(drink1: finalRankArray[currentComparisonIndex], drink2: itemsToRank[countIndex-1], numNewObjects: 0)
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
            }
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
    
    @IBAction func showInfo(_ sender: UIButton) {
        performSegue(withIdentifier: "showDetailsFromDrinkRank", sender: sender)
    }
    
    func finishedComparing() {
        let myAlert = UIAlertController(title: "Done!", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Show me my future", style: UIAlertActionStyle.default) { (ACTION) in
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FinalDrinksTableViewController") as! FinalDrinksTableViewController
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromDrinkRank" {
            if let destination = segue.destination as? DrinksDetailsViewController {
                if (sender as? UIButton)?.tag == 11 { // left button item
                    destination.drink = currentComparison[0]
                }
                else if (sender as? UIButton)?.tag == 12 { // right button item
                    destination.drink = currentComparison[1]
                }
            }
        }
    }

}
