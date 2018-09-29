//
//  FinalDrinksTableViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/14/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import DHSmartScreenshot
import SwiftMessages

class FinalDrinksTableViewController: UITableViewController {

    var finalRankArray: [Drink]!
    var choiceType: String!
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! DrinkCell
        
        let drink = finalRankArray[indexPath.row]
        
        cell.rankLabel.text = "#\(indexPath.row + 1)"
        if indexPath.row == 0 {
            cell.rankLabel.font = UIFont(name: "Arial-BoldMT", size: 36)
            cell.rankLabel.textColor = .red
        }
        
        cell.drinkName.text = drink.name!
        
        if let rating = drink.rating {
            cell.drinkRating.rating = Double(rating)!/20
        } else {
            cell.drinkRating.isHidden = true
        }
        
        cell.drinkImage.downloaded(from: drink.thumbnailURLString!)
        cell.drinkImage.layer.borderColor = UIColor.black.cgColor
        cell.drinkImage.layer.borderWidth = 2
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "drinkDetails", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            if segue.identifier == "drinkDetails" {
                if let destination = segue.destination as? DrinksDetailsViewController {
                    destination.drink = finalRankArray[indexPath.row]
                }
            }
        }
        
    }

}
