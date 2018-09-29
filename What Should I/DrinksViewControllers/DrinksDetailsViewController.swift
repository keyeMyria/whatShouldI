//
//  DrinksDetailsViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/14/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import Cosmos
import AVKit
import AVFoundation
import ReachabilityLib
import DHSmartScreenshot
import SwiftMessages

class DrinksDetailsViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    var drink: Drink!
    
    let reachability = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = drink.thumbnailURLString {
            drinkImageView.downloaded(from: urlString)
        }
        else {
            drinkImageView.image = UIImage(named: "placeholder_image")!
        }
        
        drinkNameLabel.text = drink.name
        
        let fontSize: CGFloat = Env.iPad ? 24 : 16
        
        if drink.ingredients.count > 0 {
            let ingredients = NSMutableAttributedString().bold("Ingredients:\n\n", font: fontSize)
            for (index,ingredient) in drink.ingredients.enumerated() {
                if drink.measurements.count > index {
                    if drink.measurements[index] != "" {
                        ingredients.normal(drink.measurements[index] + " " + ingredient + "\n", font: fontSize)
                    }
                    else {
                        ingredients.normal(ingredient + "\n", font: fontSize)
                    }
                }
            }
            ingredientsLabel.attributedText = ingredients
            
            if let instructions = drink.directions { // no need for instructions if no ingredients
                instructionsLabel.attributedText = NSMutableAttributedString()
                    .bold("How to mix:\n\n", font: fontSize)
                    .normal(instructions, font: fontSize)
            }
        }
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
    
    
}
