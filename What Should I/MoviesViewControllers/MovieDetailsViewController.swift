//
//  MovieDetailsViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/12/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import DHSmartScreenshot
import SwiftMessages

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var ratedLabel: UILabel!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var goToButton: UIButton!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var runtimeLabel: UILabel!
    
    var movie: Movie!
    var thumbnailDownloadTask: URLSessionDataTask?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let thumbnailURL = movie.posterURL {
            self.thumbnailDownloadTask = posterImage(for: thumbnailURL) { [weak self] (image) in
                if image != nil {
                    DispatchQueue.main.async {
                        self!.posterImageView.image = image
                    }
                    print("got image for \(self!.movie.title)")
                }
                else {
                    DispatchQueue.main.async {
                        self!.posterImageView.image = UIImage(named: "placeholder_image")!
                        print("no image for \(self!.movie.title)")
                    }
                }
            }
        }
        else {
            posterImageView.image = UIImage(named: "placeholder_image")!
        }
        
        let fontSize: CGFloat = Env.iPad ? 24 : 16
        
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        ratedLabel.text = "Rated: " + movie.rated!
        genresLabel.attributedText = NSMutableAttributedString()
            .bold("Genre(s): ", font: fontSize)
            .normal(movie.genres!, font: fontSize)
        runtimeLabel.text = "Runtime: \(movie.runtime!)"
        castLabel.attributedText = NSMutableAttributedString()
            .bold("Starring: ", font: fontSize)
            .normal(movie.cast!, font: fontSize)
        ratingLabel.attributedText = defaults.string(forKey: "database") == "IMDB" ?
            NSMutableAttributedString()
            .bold("IMDB Rating: ", font: fontSize)
            .normal(movie.imdbRating!, font: fontSize) :
            NSMutableAttributedString()
            .bold("Tomatometer: ", font: fontSize)
            .normal(movie.tomatoRating!, font: fontSize)
        plotLabel.attributedText = NSMutableAttributedString()
            .bold("Synopsis: ", font: fontSize)
            .normal(movie.plot!, font: fontSize)
        //goToButton.setTitle(defaults.string(forKey: "database") == "IMDB" ? "Open in IMDB" : "Open in Rotten Tomatoes", for: .normal)
        goToButton.backgroundColor = aqua
    }

    override func viewDidLayoutSubviews() {
        goToButton.frame.size.height = view.frame.height/10
        goToButton.layer.cornerRadius = goToButton.frame.height/2
    }
    

    @IBAction func goToPressed(_ sender: UIButton) {
        let imdbId = movie.imdbID
        UIApplication.shared.openURL(URL(string: "http://www.imdb.com/title/" + imdbId + "/")!)
        
    }
    
    @IBAction func sharePressed(_ sender: UIBarButtonItem) {
        let result = scrollView.screenshot()
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
