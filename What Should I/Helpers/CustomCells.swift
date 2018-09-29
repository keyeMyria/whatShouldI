//
//  CustomCells.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/3/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class HomeViewCell: UITableViewCell {
    @IBOutlet weak var buttonAction: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                iconImage.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                iconImage.addConstraint(aspectConstraint!)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
    }
    
    func setPostedImage(image: UIImage) {
        
        let aspect = image.size.width / image.size.height
        
        aspectConstraint = NSLayoutConstraint(item: iconImage, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: iconImage, attribute: NSLayoutAttribute.height, multiplier: aspect, constant: 0.0)
        
        iconImage.image = image
    }
}

class FirstChoiceCell: UITableViewCell {
    @IBOutlet weak var firstChoiceLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        firstChoiceLabel.text = ""
    }
}

class FinalResultCell: UITableViewCell {
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var openNowLabel: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starRatingView.settings.fillMode = .precise
        starRatingView.settings.updateOnTouch = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var reviewDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starRatingView.settings.fillMode = .precise
        starRatingView.settings.updateOnTouch = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SliderCell: UITableViewCell {
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieRating: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rankLabel.text = ""
        movieTitle.text = ""
        movieYear.text = ""
        movieRating.text = ""
        moviePoster.image = nil
    }

    
}

class DrinkCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var drinkName: UILabel!
    @IBOutlet weak var drinkImage: UIImageView!
    @IBOutlet weak var drinkRating: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        drinkRating.settings.fillMode = .precise
        drinkRating.settings.updateOnTouch = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rankLabel.text = ""
        drinkName.text = ""
        drinkRating.text = ""
        drinkImage.image = nil
    }
}


class DrinkDetailCell: UITableViewCell {
    
    @IBOutlet weak var numberRatingLabel: UILabel!
    @IBOutlet weak var drinkName: UILabel!
    @IBOutlet weak var drinkImage: UIImageView!
    @IBOutlet weak var drinkRating: CosmosView!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var tastesLabel: UILabel!
    @IBOutlet weak var toolsLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var howToMixLabel: UILabel!
    @IBOutlet weak var fullDirectionsLabel: UILabel!
    @IBOutlet weak var showVidButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        drinkRating.settings.fillMode = .precise
        drinkRating.settings.updateOnTouch = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        numberRatingLabel.text = ""
        drinkName.text = ""
        drinkRating.text = ""
        drinkImage.image = nil
        storyLabel.text = ""
        tastesLabel.text = ""
        toolsLabel.text = ""
        ingredientsLabel.text = ""
        howToMixLabel.text = ""
        fullDirectionsLabel.text = ""
    }
}
