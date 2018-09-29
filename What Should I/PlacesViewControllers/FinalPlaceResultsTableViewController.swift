//
//  FinalResultsTableViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/5/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import Localide
import DHSmartScreenshot
import SwiftMessages

class FinalResultsTableViewController: UITableViewController {
    
    var finalRankArray: [Place]!
    var choiceType: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "FinalResultCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell1")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! FinalResultCell
        cell.separatorInset = .zero
        
        let place = finalRankArray[indexPath.row]
        
        cell.rankLabel.text = "#\(indexPath.row + 1)"
        if indexPath.row == 0 {
            cell.rankLabel.font = UIFont(name: "Arial-BoldMT", size: Env.iPad ? 48 : 36)
            cell.rankLabel.textColor = .red
        }
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.vicinity
        if let rating = place.rating {
            cell.starRatingView.rating = rating
        } else {
            cell.starRatingView.isHidden = true
        }
        
        if let distanceInKm = place.distance {
            cell.distanceLabel.text = self.formatDistance(distance: distanceInKm)
        }
        
        
        if let openNow = place.open_now {
            if openNow {
                cell.openNowLabel.text = "OPEN!"
                cell.openNowLabel.textColor = UIColor(hue: 0.2778, saturation: 0.93, brightness: 0.62, alpha: 1.0)
            } else {
                cell.openNowLabel.text = "CLOSED!"
                cell.openNowLabel.textColor = UIColor.red
            }
        }

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myAlert = UIAlertController(title: "Options", message: "", preferredStyle: .alert)
        let mapAlert = UIAlertAction(title: "Show On Map", style: .default, handler: { _ in
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "showMap", sender: indexPath)
        })
        let directionsAlert = UIAlertAction(title: "Get Directions", style: .default, handler: { _ in
            tableView.deselectRow(at: indexPath, animated: true)
            Localide.sharedManager.promptForDirections(toLocation: self.finalRankArray[indexPath.row].coordinate, onCompletion: nil)
        })
        let detailsAlert = UIAlertAction(title: "Details", style: .default, handler: { _ in
            tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "showDetails", sender: indexPath)
        })
        let cancelAlert = UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
        myAlert.addAction(mapAlert)
        myAlert.addAction(directionsAlert)
        myAlert.addAction(detailsAlert)
        myAlert.addAction(cancelAlert)
        
        if let popoverController = myAlert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        self.present(myAlert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            if segue.identifier == "showMap" {
                if let destination = segue.destination as? MapViewController {
                    destination.place = finalRankArray[indexPath.row]
                }
            }
            
            if segue.identifier == "showDetails" {
                if let destination = segue.destination as? PlaceDetailsViewController {
                    destination.place = finalRankArray[indexPath.row]
                }
            }
        }
    }
    

}
