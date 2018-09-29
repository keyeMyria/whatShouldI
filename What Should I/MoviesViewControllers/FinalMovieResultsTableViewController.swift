//
//  FinalMovieResultsTableViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/12/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import DHSmartScreenshot
import SwiftMessages

class FinalMovieResultsTableViewController: UITableViewController {

    var finalRankArray: [Movie]!
    var choiceType: String!
    var thumbnailDownloadTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func sharePressed(_ sender: UIBarButtonItem) {
        let result = tableView.screenshot()
        
        let activityViewController = UIActivityViewController(activityItems: [result!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [.print, .assignToContact, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo]
        
        self.present(activityViewController, animated: true, completion: nil)
        activityViewController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                SwiftMessages.show {
                    let view = MessageView.viewFromNib(layout: .cardView)
                    view.configureTheme(.success)
                    view.configureDropShadow()
                    view.configureContent(title: "Success!", body: "")
                    view.button?.isHidden = true
                    return view
                }
            }
        }
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return finalRankArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! MovieCell
        
        let movie = finalRankArray[indexPath.row]
        
        cell.rankLabel.text = "#\(indexPath.row + 1)"
        if indexPath.row == 0 {
            cell.rankLabel.font = UIFont(name: "Arial-BoldMT", size: 36)
            cell.rankLabel.textColor = .red
        }
        
        cell.movieTitle.text = movie.title
        cell.movieYear.text = movie.year
        
        if defaults.string(forKey: "database") == "IMDB" {
            cell.movieRating.text = "IMDB Rating: \(movie.imdbRating!)/10"
        }
        else {
            cell.movieRating.text = "Tomatometer: \(movie.tomatoRating!)%"
        }
        
        if let thumbnailURL = movie.posterURL {
            self.thumbnailDownloadTask = posterImage(for: thumbnailURL) { [weak self] (image) in
                if image != nil {
                    DispatchQueue.main.async {
                        cell.moviePoster.image = image
                    }
                    print("got image for \(movie.title)")
                }
                else {
                    DispatchQueue.main.async {
                        cell.moviePoster.image = UIImage(named: "placeholder_image")!
                    print("no image for \(movie.title)")
                    }
                }
            }
        }
        else {
            cell.moviePoster.image = UIImage(named: "placeholder_image")!
        }
        
        
        cell.moviePoster.image = UIImage(data: movie.posterImage!)
        cell.moviePoster.layer.borderColor = UIColor.black.cgColor
        cell.moviePoster.layer.borderWidth = 2
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "movieDetails", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            if segue.identifier == "movieDetails" {
                if let destination = segue.destination as? MovieDetailsViewController {
                    destination.movie = finalRankArray[indexPath.row]
                }
            }
        }
        
    }

}
