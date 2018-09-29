//
//  MiniSettingsViewController.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/10/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import UIKit
import Eureka
import GoogleMobileAds

class MiniSettingsViewController: FormViewController, GADInterstitialDelegate {
    
    var choices: [String]!
    var choiceType: String!
    
    var interstitial: GADInterstitial!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        self.navigationItem.title = "My Settings"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: Env.iPad ? 30 : 20, weight: UIFont.Weight.heavy)]
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.loadAds()
        }
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        switch choiceType {
        case rowLabels[0]:
            form
            +++ Section("Eat Settings")
                <<< SwitchRow("openOnly") { row in
                    row.value = defaults.bool(forKey: "openOnly") ? true : false
                    row.title = row.value! ? "Show only open places" : "Show open and closed places"
                    }.onChange { row in
                        row.title = row.value! ? "Show only open places" : "Show open and closed places"
                        row.updateCell()
                        if row.value! {
                            defaults.set(true, forKey: "openOnly")
                        }
                        else {
                            defaults.set(false, forKey: "openOnly")
                        }
                }
                <<< SliderRow("foodService") {
                    $0.title = "Food Service"
                    $0.steps = 2
                    $0.value = Float(defaults.string(forKey: "foodService")!)
                    $0.displayValueFor = {
                        defaults.set("\(Int($0 ?? 0))", forKey: "foodService")
                        
                        switch $0 {
                        case _ where ($0 ?? 0) == 1:
                            return "Take away"
                        case _ where ($0 ?? 0) == 2:
                            return "Delivery"
                        default:
                            return "No Preference"
                        }
                    }
                    }.cellSetup { cell, row in
                        cell.slider.minimumValue = 1
                        cell.slider.maximumValue = 3
                }
                <<< SliderRow("searchRadius") {
                    $0.title = "Search Radius"
                    $0.steps = 50
                    $0.value = Float(defaults.string(forKey: "searchRadius")!)
                    $0.displayValueFor = {
                        defaults.set("\(Int($0 ?? 0))", forKey: "searchRadius")
                        
                        switch $0 {
                        case _ where ($0 ?? 0) == 1:
                            return "\(Int($0 ?? 0)) \(defaults.string(forKey: "units")!.dropLast())"
                        default:
                            return "\(Int($0 ?? 0)) \(defaults.string(forKey: "units")!)"
                        }
                    }
                    }.cellSetup { cell, row in
                        cell.slider.minimumValue = 1
                        cell.slider.maximumValue = 50
                }
                <<< SwitchRow("units") { row in
                    row.value = (defaults.string(forKey: "units")! == "miles") ? true : false
                    row.title = row.value! ? "Preferred Units: Miles" : "Preferred Units: Kilometers"
                    }.onChange { row in
                        row.title = row.value! ? "Preferred Units: Miles" : "Preferred Units: Kilometers"
                        row.updateCell()
                        if row.value! {
                            defaults.set("miles", forKey: "units")
                        }
                        else {
                            defaults.set("kilometers", forKey: "units")
                        }
                        self.form.rowBy(tag: "searchRadius")?.updateCell()
            }
        case rowLabels[1]:
            form
                +++ Section("Watch Settings")
                <<< SwitchRow("database") { row in
                    row.value = (defaults.string(forKey: "database")! == "IMDB") ? true : false
                    row.title = row.value! ? "Rating Source: IMDB" : "Rating Source: Rotten Tomatoes"
                    }.onChange { row in
                        row.title = row.value! ? "Rating Source: IMDB" : "Rating Source: Rotten Tomatoes"
                        row.updateCell()
                        if row.value! {
                            defaults.set("IMDB", forKey: "database")
                        }
                        else {
                            defaults.set("RT", forKey: "database")
                        }
                }
                <<< SliderRow("IMDBrating") {
                    $0.title = "Minimum IMDB Rating"
                    $0.steps = 20
                    $0.value = Float(defaults.string(forKey: "IMDBrating")!)
                    $0.displayValueFor = {
                        defaults.set("\(String(format: "%.1f", ($0 ?? 0)))", forKey: "IMDBrating")
                        return "\(String(format: "%.1f", ($0 ?? 0)))"
                    }
                    $0.hidden = Condition.function(["database"], { form in
                        return !((form.rowBy(tag: "database") as? SwitchRow)?.value ?? false)
                    })
                    }.cellSetup { cell, row in
                        cell.slider.minimumValue = 0
                        cell.slider.maximumValue = 10
                }
                <<< SliderRow("RTrating") {
                    $0.title = "Minimum Rotten Tomatoes Rating"
                    $0.steps = 20
                    $0.value = Float(defaults.string(forKey: "RTrating")!)
                    $0.displayValueFor = {
                        defaults.set("\(String(format: "%.1f", ($0 ?? 0)))", forKey: "RTrating")
                        return "\(String(format: "%.1f", ($0 ?? 0)))"
                    }
                    $0.hidden = Condition.function(["database"], { form in
                        return (form.rowBy(tag: "database") as? SwitchRow)?.value ?? false
                    })
                    }.cellSetup { cell, row in
                        cell.slider.minimumValue = 0
                        cell.slider.maximumValue = 100
                }
                <<< SliderRow("showYear") {
                    $0.title = "Released on or after:"
                    $0.steps = 8
                    $0.value = Float(defaults.string(forKey: "showYear")!)
                    $0.displayValueFor = {
                        defaults.set("\(String(format: "%.1f", ($0 ?? 0)))", forKey: "showYear")
                        switch $0 {
                        case _ where $0 == 1930:
                            return "Anytime"
                        default:
                            return "\(String(format: "%.0f", ($0 ?? 0)))"
                        }
                        
                    }
                    }.cellSetup { cell, row in
                        cell.slider.minimumValue = 1930
                        cell.slider.maximumValue = 2010
                }
                <<< SwitchRow("showType") { row in
                    row.value = (defaults.string(forKey: "showType")! == "movie") ? true : false
                    row.title = row.value! ? "Show Type: Movie" : "Show Type: TV"
                    }.onChange { row in
                        row.title = row.value! ? "Show Type: Movie" : "Show Type: TV"
                        row.updateCell()
                        if row.value! {
                            defaults.set("movie", forKey: "showType")
                        }
                        else {
                            defaults.set("TV", forKey: "showType")
                        }
                        
                }
                <<< SwitchRow("genre") { row in
                    row.value = defaults.bool(forKey: "genrePreference") ? true : false
                    if row.value! {
                        let showType = (defaults.string(forKey: "showType")! == "movie") ? "movie" : "tv"
                        if showType == "movie" {
                            row.title = "Genre Preference: \(defaults.string(forKey: "movieGenrePreference")!)"
                        }
                        else {
                            row.title = "Genre Preference: \(defaults.string(forKey: "tvGenrePreference")!)"
                        }
                    }
                    else {
                        row.title = "No Genre Preference"
                    }
                    }.onChange { row in
                        let showType = (self.form.rowBy(tag: "showType") as! SwitchRow).value! ? "movie" : "tv"
                        if showType == "movie" {
                            row.title = row.value! ? "Genre Preference: \(defaults.string(forKey: "movieGenrePreference")!)" : "No Genre Preference"
                        }
                        else {
                            row.title = row.value! ? "Genre Preference: \(defaults.string(forKey: "tvGenrePreference")!)" : "No Genre Preference"
                        }
                        row.updateCell()
                        if row.value! {
                            defaults.set(true, forKey: "genrePreference")
                        }
                        else {
                            defaults.set(false, forKey: "genrePreference")
                        }
            }
            
            let movieGenrePreference = SelectableSection<ListCheckRow<String>>("Movie Genres", selectionType: .singleSelection(enableDeselection: false))
            for genre in defaults.stringArray(forKey: "movieGenres")! {
                movieGenrePreference <<< ListCheckRow<String>(genre) { listRow in
                    listRow.title = genre
                    listRow.selectableValue = genre
                    listRow.value = nil
                    listRow.tag = "b" + genre
                    if genre == defaults.string(forKey: "movieGenrePreference")! {
                        listRow.value = "3"
                    }
                }
            }
            
            form +++ movieGenrePreference
            movieGenrePreference.hidden = Condition.function(["showType","genre"]) { form in
                if let hasGenrePreference = (form.rowBy(tag: "genre") as? SwitchRow)?.value {
                    let showType = (form.rowBy(tag: "showType") as! SwitchRow).value! ? "movie" : "tv"
                    if hasGenrePreference && showType == "movie" {
                        return false
                    }
                }
                return true
            }
            movieGenrePreference.evaluateHidden()
            movieGenrePreference.onSelectSelectableRow = { (cell, cellRow) in
                defaults.set("\(cellRow.title!)", forKey: "movieGenrePreference")
                let switchRow: SwitchRow = self.form.rowBy(tag: "genre")!
                switchRow.title = switchRow.value! ? "Genre Preference: \(defaults.string(forKey: "movieGenrePreference")!)" : "No Genre Preference"
                switchRow.reload()
                print("cell.value = \(cellRow.title!)")
            }
            
            let tvGenrePreference = SelectableSection<ListCheckRow<String>>("TV Genres", selectionType: .singleSelection(enableDeselection: false))
            for genre in defaults.stringArray(forKey: "tvGenres")! {
                tvGenrePreference <<< ListCheckRow<String>(genre) { listRow in
                    listRow.title = genre
                    listRow.selectableValue = genre
                    listRow.value = nil
                    listRow.tag = "a" + genre
                    if genre == defaults.string(forKey: "tvGenrePreference")! {
                        listRow.value = "3"
                    }
                }
            }
            
            form +++ tvGenrePreference
            tvGenrePreference.hidden = Condition.function(["showType","genre"]) { form in
                if let hasGenrePreference = (form.rowBy(tag: "genre") as? SwitchRow)?.value {
                    let showType = (form.rowBy(tag: "showType") as! SwitchRow).value! ? "movie" : "tv"
                    if hasGenrePreference && showType == "tv" {
                        return false
                    }
                }
                return true
            }
            tvGenrePreference.evaluateHidden()
            tvGenrePreference.onSelectSelectableRow = { (cell, cellRow) in
                defaults.set("\(cellRow.title!)", forKey: "tvGenrePreference")
                let switchRow: SwitchRow = self.form.rowBy(tag: "genre")!
                switchRow.title = switchRow.value! ? "Genre Preference: \(defaults.string(forKey: "tvGenrePreference")!)" : "No Genre Preference"
                switchRow.reload()
                print("cell.value = \(cellRow.title!)")
            }
        case rowLabels[2]:
            form
                +++ Section("Explore Settings")
                <<< SliderRow("exploreSearchRadius") {
                    $0.title = "Search Radius"
                    $0.steps = 50
                    $0.value = Float(defaults.string(forKey: "exploreSearchRadius")!)
                    $0.displayValueFor = {
                        defaults.set("\(Int($0 ?? 0))", forKey: "exploreSearchRadius")
                        
                        switch $0 {
                        case _ where ($0 ?? 0) == 1:
                            return "\(Int($0 ?? 0)) \(defaults.string(forKey: "units")!.dropLast())"
                        default:
                            return "\(Int($0 ?? 0)) \(defaults.string(forKey: "units")!)"
                        }
                    }
                    }.cellSetup { cell, row in
                        cell.slider.minimumValue = 1
                        cell.slider.maximumValue = 50
                }
                <<< SwitchRow("exploreUnits") { row in
                    row.value = (defaults.string(forKey: "exploreUnits")! == "miles") ? true : false
                    row.title = row.value! ? "Preferred Units: Miles" : "Preferred Units: Kilometers"
                    }.onChange { row in
                        row.title = row.value! ? "Preferred Units: Miles" : "Preferred Units: Kilometers"
                        row.updateCell()
                        if row.value! {
                            defaults.set("miles", forKey: "exploreUnits")
                        }
                        else {
                            defaults.set("kilometers", forKey: "exploreUnits")
                        }
                        self.form.rowBy(tag: "exploreSearchRadius")?.updateCell()
                }
                <<< LabelRow("locationLabel") { row in
                    row.title = "Location Type: \(defaults.string(forKey: "locationType")!)"
            }
            let explorePreference = SelectableSection<ListCheckRow<String>>("Location Types", selectionType: .singleSelection(enableDeselection: false))
            for location in defaults.stringArray(forKey: "locationsArray")! {
                explorePreference <<< ListCheckRow<String>(location) { listRow in
                    listRow.title = location
                    listRow.selectableValue = location
                    listRow.value = nil
                    listRow.tag = "c" + location
                    if location == defaults.string(forKey: "locationType")! {
                        listRow.value = "3"
                    }
                }
            }
            form +++ explorePreference
            explorePreference.onSelectSelectableRow = { (cell, cellRow) in
                defaults.set("\(cellRow.title!)", forKey: "locationType")
                for (index,location) in (defaults.stringArray(forKey: "locationsArray"))!.enumerated() {
                    if cellRow.title! == location {
                        defaults.set((defaults.stringArray(forKey: "locationsValueArray"))![index], forKey: "locationTypeValue")
                    }
                }
                let labelRow: LabelRow = self.form.rowBy(tag: "locationLabel")!
                labelRow.title = "Location Type: \(defaults.string(forKey: "locationType")!)"
                labelRow.reload()
            }
        case rowLabels[3]:
            form
                +++ Section("Drink Settings")
                <<< SwitchRow("withAlcohol") { row in
                    row.value = defaults.bool(forKey: "withAlcohol") ? true : false
                    row.title = row.value! ? "Alcoholic Drink" : "Non-alcoholic Drink"
                    }.onChange { row in
                        row.title = row.value! ? "Alcoholic Drink" : "Non-alcoholic Drink"
                        row.updateCell()
                        if row.value! {
                            defaults.set(true, forKey: "withAlcohol")
                        }
                        else {
                            defaults.set(false, forKey: "withAlcohol")
                        }
                }
                <<< LabelRow("madeWith") { row in
                    row.title = "Made with: \(defaults.string(forKey: "madeWith")!.capitalized)"
                    row.hidden = Condition.function(["withAlcohol"]) { form in
                        return (form.rowBy(tag: "withAlcohol") as? SwitchRow)!.value! ? false : true
                    }
            }
            let madeWithPref = SelectableSection<ListCheckRow<String>>("Liquor Options", selectionType: .singleSelection(enableDeselection: false))
            for drink in defaults.stringArray(forKey: "liquorOptions")! {
                madeWithPref <<< ListCheckRow<String>(drink) { listRow in
                    listRow.title = drink.capitalized
                    listRow.selectableValue = drink
                    listRow.value = nil
                    listRow.tag = "d" + drink
                    if drink == defaults.string(forKey: "madeWith")! {
                        listRow.value = "3"
                    }
                }
            }
            form +++ madeWithPref
            madeWithPref.onSelectSelectableRow = { (cell, cellRow) in
                defaults.set("\(cellRow.title!.lowercased())", forKey: "madeWith")
                let labelRow: LabelRow = self.form.rowBy(tag: "madeWith")!
                labelRow.title = "Made with: \(defaults.string(forKey: "madeWith")!.capitalized)"
                labelRow.reload()
            }
            madeWithPref.hidden = Condition.function(["withAlcohol"]) { form in
                return (form.rowBy(tag: "withAlcohol") as? SwitchRow)!.value! ? false : true
            }
            madeWithPref.evaluateHidden()
        default: ()
        }
        
        form
            +++ Section()
            <<< ButtonRow() {
                $0.title = "Next"
                $0.onCellSelection( { cell, row in
                    DispatchQueue.main.async {
                        self.showAds()
                    }
                })
        }
    }
    
    func loadAds() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-6869347155518066/1525929154")
        interstitial.delegate = self
        let request = GADRequest()
        //request.testDevices = [ kGADSimulatorID, "b4ff0166b130d69f021e40b34ffabcb9" ]
        interstitial.load(request)
    }
    
    func showAds() {
        var count = defaults.integer(forKey: "adCount")
        print(count)
        if !defaults.bool(forKey: "premium") {
            if choiceType == rowLabels[3] {
                goToNextVC() // ad plays there
            }
            else if count == 3 { // ad every 4 requests
                if interstitial.isReady {
                    defaults.set(0, forKey: "adCount")
                    interstitial.present(fromRootViewController: self)
                } else {
                    goToNextVC()
                    print("Ad wasn't ready")
                }
            }
            else {
                count = count + 1
                defaults.set(count, forKey: "adCount")
                goToNextVC()
            }
        }
        
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        goToNextVC()
    }
    
    func goToNextVC() {
        switch self.choiceType {
        case rowLabels[0]:
            self.performSegue(withIdentifier: "toPlaceRank", sender: self)
        case rowLabels[1]:
            self.performSegue(withIdentifier: "toMovieRank", sender: self)
        case rowLabels[2]:
            self.performSegue(withIdentifier: "toPlaceRank", sender: self)
        case rowLabels[3]:
            self.performSegue(withIdentifier: "toDrinkRank", sender: self)
        default: ()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlaceRank" {
            let destination = segue.destination as! PlaceRankingViewController
            destination.choiceType = choiceType
        }
        
        if segue.identifier == "toMovieRank" {
            let destination = segue.destination as! MovieRankingViewController
            destination.choiceType = choiceType
        }
        
        if segue.identifier == "toDrinkRank" {
            let destination = segue.destination as! DrinksRankingViewController
            destination.choiceType = choiceType
        }
    }

}
