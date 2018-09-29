//
//  DetailsViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/5/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import ImageSlideshow
import Alamofire
import AlamofireImage
import Cosmos
import Localide

class PlaceDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNoLabel: UILabel!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var directionsIconImage: UIImageView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var openNowLabel: UILabel!
    @IBOutlet weak var ratingNumberLabel: UILabel!
    @IBOutlet weak var phoneIconImage: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    var place: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPlaceImages()
        loadStatics()
        
        imageSlideShow.backgroundColor = UIColor.white
        //imageSlideShow.slideshowInterval = 5.0
        imageSlideShow.pageControlPosition = PageControlPosition.insideScrollView
        imageSlideShow.pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        imageSlideShow.pageControl.pageIndicatorTintColor = UIColor.gray
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        imageSlideShow.currentPageChanged = { page in
            print("current page:", page)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
        
        let nib = UINib(nibName: "ReviewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell1")
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageSlideShow.addGestureRecognizer(imageTap)
        
        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(phoneTapped))
        phoneNoLabel.isUserInteractionEnabled = true
        phoneNoLabel.addGestureRecognizer(phoneTap)
        phoneIconImage.addGestureRecognizer(phoneTap)
        
        let directionsTap = UITapGestureRecognizer(target: self, action: #selector(getDirections))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(directionsTap)
        directionsIconImage.addGestureRecognizer(directionsTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        print("table height1 -> \(self.tableView.frame.height)")
    }
    
    func loadPlaceImages() {
        var remoteImageSource = [AlamofireSource] ()
        let defaultImage = UIImage(named:"placeholder_image")
        
        if let photos = place?.photos {
            for photo in photos {
                let photoUrlString = String(format: Constants.PLACES_PHOTO_URL, photo, Constants.PLACES_API_KEY)
                print("photoUrlString \(photoUrlString)")
                //let url = URL(string: urlString)
                let source = AlamofireSource(urlString: photoUrlString, placeholder: defaultImage)!
                remoteImageSource.append(source)
            }
            imageSlideShow.setImageInputs(remoteImageSource)
        }
    }
    
    func loadStatics() {
        nameLabel.text = place.name
        
        ratingView.settings.fillMode = .precise
        ratingView.settings.updateOnTouch = false
        ratingView.settings.starSize = Double(phoneNoLabel.frame.height)
        
        addressLabel.text = place.vicinity
        
        if let rating = place.rating {
            ratingView.rating = rating
            ratingNumberLabel.text = String(format:"%.1f", rating)
            ratingNumberLabel.font = UIFont.systemFont(ofSize: 20)
        }
        else {
            ratingView.isHidden = true
            ratingNumberLabel.isHidden = true
        }
        
        if let openNow = place.open_now {
            if openNow {
                openNowLabel.text = "OPEN"
                openNowLabel.textColor = UIColor(hue: 0.2778, saturation: 0.93, brightness: 0.62, alpha: 1.0)
            } else {
                openNowLabel.text = "CLOSED"
                openNowLabel.textColor = UIColor.red
            }
        }
        else {
            openNowLabel.isHidden = true
        }
        
        if let distanceInKm = place.distance {
            awayLabel.text = "\(self.formatDistance(distance: distanceInKm)) away"
        }
        
        if let phoneNo = place.phone_number {
            phoneNoLabel.text = phoneNo
        }
        else {
            phoneNoLabel.isHidden = true
            phoneIconImage.isHidden = true
        }
    }
    
    @objc func imageTapped(_ sender: UIGestureRecognizer) {
        imageSlideShow.presentFullScreenController(from: self)
    }
    
    @objc func phoneTapped(_ sender: UIGestureRecognizer) {
        callNumber(phoneNumber: place.phone_number!)
    }
    
    private func callNumber(phoneNumber: String) {
        let parsedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        if let phoneCallURL = URL(string: "tel://\(parsedNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            } else {
                print("phoneCallURL canOpenURL nil")
            }
        } else {
            print("phoneCallURL is nil")
        }
    }
    
    @objc func getDirections(_ sender: UIGestureRecognizer) {
        Localide.sharedManager.promptForDirections(toLocation: self.place.coordinate, onCompletion: nil)
    }
    
    
    // MARK: Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return place.reviews!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "cell1", for: indexPath) as! ReviewCell
        let review: Review = place.reviews![indexPath.row]
        cell.nameLabel.text = review.username
        cell.reviewLabel.numberOfLines = 0
        cell.reviewLabel.text = review.review_text
        cell.starRatingView.rating = Double(review.rating)
        let defaultImage = UIImage(named: "placeholder_image")
        cell.profileImage.af_setImage(withURL: URL(string: review.user_profile_image)!, placeholderImage: defaultImage)
        cell.reviewDateLabel.text = review.review_time
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Reviews"
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
