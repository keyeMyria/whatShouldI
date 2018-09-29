//
//  MovieRankingViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/11/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import TMDBSwift

class MovieRankingViewController: UIViewController {
    
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
    var itemsToRank: [Movie] = []
    var finalRankArray: [Movie] = []
    var currentComparison: [Movie] = []
    var miniRankResults: [Movie] = []
    var currentComparisonIndex:Int = 0
    var numTotalComparisons:Int = 0
    var countIndex:Int = 0 // lets you know the index of the next object to grab from the shuffledArray
    var remainingIndices:[Int] = [] // know when to stop comparisons for a given object
    var thumbFlags: [Int] = [0,0,0,0] // for the thumbs up/thumbs down buttons
    
    var choiceType: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoButton1.isEnabled = false
        infoButton2.isEnabled = false
        submitButton.isEnabled = false

        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        prepareItems()
        
        self.navigationItem.title = "Rank Time"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Env.iPad ? 30 : 20, weight: UIFont.Weight.heavy)]
        
        getMovies()
    }
    
    func getMovies() { // logic to reduce calls to OMDB
        let discoverType = getShowType()
        let genre = getGenre()
        var movieTitles = [String]()
        itemsToRank = []
        numObj = 4
        
        DiscoverMDB.discover(discoverType: discoverType, params: [.primary_release_date_gte(defaults.string(forKey: "showYear")!), .page(1 + Int(arc4random_uniform(49))), .with_genres(genre)], completionHandler: { data, movies, tv in
            if defaults.string(forKey: "showType")! == "movie" {
                if let results = movies {
                    for result in results {
                        movieTitles.append(result.title!)
                    }
                }
            }
            else {
                if let results = tv {
                    for result in results {
                        movieTitles.append(result.name!)
                    }
                }
            }
            
            movieTitles = movieTitles.shuffled()
            
            let myGroup = DispatchGroup()
            
            for movieTitle in movieTitles {
                myGroup.enter()
                self.currentSearchTask = search(for: movieTitle) { [weak self] (searchResult, error) in
                    if let result = searchResult {
                        var movie = result.movies![0]
                        let minRating = defaults.string(forKey: "database")! == "IMDB" ? defaults.string(forKey: "IMDBrating")! : defaults.string(forKey: "RTrating")!
                        var movieRating = defaults.string(forKey: "database")! == "IMDB" ? movie.imdbRating! : movie.tomatoRating!
                        if movieRating == "N/A" {
                            movieRating = "0"
                        }
                        if Double(movieRating)! >= Double(minRating)! && self!.itemsToRank.count < self!.numObj {
                            self?.itemsToRank.append(movie)
                        }
                    }
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                print("Finished all requests.")
                DispatchQueue.main.async {
                    self.loadRanks()
                }
            }
        })
    }
    
    
    func getShowType() -> DiscoverType {
        if defaults.string(forKey: "showType") == "movie" {
            return DiscoverType(rawValue: "movie")!
        }
        else {
            return DiscoverType(rawValue: "tv")!
        }
    }
    
    func loadRanks() {
        countIndex = 0
        if itemsToRank.count > numObj {
            itemsToRank = Array(itemsToRank.dropLast(itemsToRank.count - numObj))
            self.numObj = itemsToRank.count
            createComparison(movie1: self.itemsToRank[0], movie2: self.itemsToRank[1], numNewObjects: 2)
        }
        else if itemsToRank.count >= 2 {
            self.numObj = itemsToRank.count
            createComparison(movie1: self.itemsToRank[0], movie2: self.itemsToRank[1], numNewObjects: 2)
        }
        else if itemsToRank.count == 1 {
            let myAlert = UIAlertController(title: "Could only find one movie that meets your search critiera", message: "", preferredStyle: .alert)
            let showAction = UIAlertAction(title: "Show me", style: .default, handler: { _ in
                let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FinalMovieResultsTableViewController") as! FinalMovieResultsTableViewController
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
            let myAlert = UIAlertController(title: "Could not find enough movies that meet your preferences", message: "Try making search criteria less stringent", preferredStyle: .alert)
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
    
    func createComparison(movie1: Movie, movie2: Movie, numNewObjects: Int) {
        loadMovieImages(movie: movie1, imageView: imageView1, label: nameLabel1, activity: activityIndicator1)
        loadMovieImages(movie: movie2, imageView: imageView2, label: nameLabel2, activity: activityIndicator2)
        countIndex = countIndex + numNewObjects
        currentComparison = [movie1, movie2]
    }
    
    func loadMovieImages(movie: Movie, imageView: UIImageView, label: UILabel, activity: UIActivityIndicatorView) {
        
        activity.startAnimating()
        label.text = "Loading..."
        infoButton1.isEnabled = false
        infoButton2.isEnabled = false
        submitButton.isEnabled = false
        
        var movieIndex: Int!
        for (index,someMovie) in itemsToRank.enumerated() {
            if movie.title == someMovie.title {
                movieIndex = index
            }
        }
        
        var thisMovieImage: UIImage!
        if let thumbnailURL = movie.posterURL {
            self.thumbnailDownloadTask = posterImage(for: thumbnailURL) { [weak self] (image) in
                if image != nil {
                    thisMovieImage = image
                }
                else {
                    thisMovieImage = UIImage(named: "placeholder_image")!
                    print("no image for \(movie.title)")
                }
                DispatchQueue.main.async {
                    imageView.image = thisMovieImage
                    label.text = movie.title
                    label.sizeToFit()
                    activity.stopAnimating()
                    self!.submitButton.isEnabled = true
                    self!.infoButton1.isEnabled = true
                    self!.infoButton2.isEnabled = true
                    self!.submitButton.isEnabled = true
                }
            }
        }
        else {
            DispatchQueue.main.async {
                imageView.image = UIImage(named: "placeholder_image")!
                label.text = movie.title
                label.sizeToFit()
                activity.stopAnimating()
                self.submitButton.isEnabled = true
                self.infoButton1.isEnabled = true
                self.infoButton2.isEnabled = true
                self.submitButton.isEnabled = true
            }
        }
        
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
        
        submitButton.isEnabled = false
        submitButton.backgroundColor = aqua
        submitButton.layer.cornerRadius = submitButton.frame.height/2
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
    
    func prepareNextComparison() {
        let numObjectsRankedInFinal = finalRankArray.count
        if numTotalComparisons == 0 { // just submitted first comparison
            finalRankArray = miniRankResults
            createComparison(movie1: finalRankArray[0], movie2: itemsToRank[countIndex], numNewObjects: 1)
            remainingIndices = [1]
            
            numTotalComparisons = numTotalComparisons + 1
            currentComparisonIndex = 0 // this is the index of the object being compared to the new object
            resetThumbs()
        }
        else if numTotalComparisons != 0 {
            if miniRankResults[0].title == itemsToRank[countIndex-1].title { //new object is #1 in current comparison;
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
                        createComparison(movie1: finalRankArray[currentComparisonIndex], movie2: itemsToRank[countIndex], numNewObjects: 1) //  compare with middle seed
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
                    createComparison(movie1: finalRankArray[currentComparisonIndex], movie2: itemsToRank[countIndex-1], numNewObjects: 0)
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
            }
            else if miniRankResults[1].title == itemsToRank[countIndex-1].title { //new object is #2 in current comparison;
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
                        createComparison(movie1: finalRankArray[currentComparisonIndex], movie2: itemsToRank[countIndex], numNewObjects: 1) //  compare with middle seed
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
                    createComparison(movie1: finalRankArray[currentComparisonIndex], movie2: itemsToRank[countIndex-1], numNewObjects: 0)
                    numTotalComparisons = numTotalComparisons + 1
                    resetThumbs()
                }
            }
        }
        
    }
    
    func finishedComparing() {
        let myAlert = UIAlertController(title: "Done!", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Show me my future", style: UIAlertActionStyle.default) { (ACTION) in
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "FinalMovieResultsTableViewController") as! FinalMovieResultsTableViewController
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
        performSegue(withIdentifier: "showDetailsFromRank", sender: sender)
    }
    
    func getGenre() -> String {
        if defaults.bool(forKey: "genrePreference") {
            if defaults.string(forKey: "showType") == "movie" {
                var genreId: String!
                switch defaults.string(forKey: "movieGenrePreference")! {
                case "Action": genreId = "28"
                case "Adventure": genreId = "12"
                case "Animation": genreId = "16"
                case "Comedy": genreId = "35"
                case "Crime": genreId = "80"
                case "Documentary": genreId = "99"
                case "Drama": genreId = "18"
                case "Family": genreId = "10751"
                case "Fantasy": genreId = "14"
                case "Foreign": genreId = "10769"
                case "History": genreId = "36"
                case "Horror": genreId = "27"
                case "Music": genreId = "10402"
                case "Mystery": genreId = "9648"
                case "Romance": genreId = "10749"
                case "Science Fiction": genreId = "878"
                case "TV Movie": genreId = "10770"
                case "Thriller": genreId = "53"
                case "War": genreId = "10752"
                case "Western": genreId = "37"
                default: genreId = ""
                }
                return genreId
            }
            else if defaults.string(forKey: "showType") == "tv" {
                var genreId: String!
                switch defaults.string(forKey: "tvGenrePreference")! {
                case "Action & Adventure": genreId = "10759"
                case "Animation": genreId = "16"
                case "Comedy": genreId = "35"
                case "Crime": genreId = "80"
                case "Documentary": genreId = "99"
                case "Drama": genreId = "18"
                case "Education": genreId = "10761"
                case "Family": genreId = "10751"
                case "Kids": genreId = "10762"
                case "Mystery": genreId = "9648"
                case "News": genreId = "10763"
                case "Reality": genreId = "10764"
                case "Sci-Fi & Fantasy": genreId = "10765"
                case "Soap": genreId = "10766"
                case "Talk": genreId = "10767"
                case "War & Politics": genreId = "10768"
                case "Western": genreId = "37"
                default: genreId = ""
                }
                return genreId
            }
        }
        return ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailsFromRank" {
            if let destination = segue.destination as? MovieDetailsViewController {
                if (sender as? UIButton)?.tag == 11 { // left button item
                    destination.movie = currentComparison[0]
                }
                else if (sender as? UIButton)?.tag == 12 { // right button item
                    destination.movie = currentComparison[1]
                }
            }
        }
    }


}
