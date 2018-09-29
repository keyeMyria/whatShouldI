//
//  Helper.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/3/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Eureka
import TMDBSwift

let defaults = UserDefaults.standard

let rowLabels = ["Eat","Watch","Explore","Drink"]//,"Play","Read"]

let aqua = UIColor(red: 175/255.0, green: 220/255.0, blue: 236/255.0, alpha: 1.0)

//let apiADDbkey = "a676605b108948d2aeca7b21baade00d"
//let apiADDbsecret = "48b10df6b3bc49c68428fbf3126c8efa"

class Env {
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension UIViewController {
    func makeNavTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
    }
    
    func customizeButton(button: UIButton!) {
        button.setBackgroundImage(nil, for: .normal)
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = button.frame.height/2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func shake(object: AnyObject!) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: (object?.center.x)! - 10, y: object.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: object.center.x + 10, y: object.center.y))
        object.layer.add(animation, forKey: "position")
    }
    
    func alert(message: NSString, title: NSString) {
        let alert = UIAlertController(title: title as String, message: message as String, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func formatDistance(distance: Double) -> String {
        let preferredUnits = defaults.string(forKey: "units")!
        let newDistance = (preferredUnits == "kilometers") ? distance : distance * 0.621371
        let abbreviatedUnits = preferredUnits == "kilometers" ? "km" : "mi"
        
        return "\(String(format:"%.1f", newDistance)) \(abbreviatedUnits)"
    }
    
    func compareImage(data: Data, image: UIImage) -> Bool {
        let imageData = UIImagePNGRepresentation(image)
        if data == imageData {
            return true
        }
        return false
    }
    
    func loadSettings() {
        // For Ads
        if defaults.string(forKey: "adCount") == nil {
            defaults.set(0, forKey: "adCount")
        }
        
        // Eat
        if defaults.string(forKey: "openOnly") == nil {
            defaults.set(true, forKey: "openOnly")
        }
        
        if defaults.string(forKey: "foodService") == nil {
            defaults.set("3", forKey: "foodService")
        }
        
        if defaults.string(forKey: "units") == nil {
            defaults.set("miles", forKey: "units")
        }
        
        if defaults.string(forKey: "searchRadius") == nil {
            defaults.set("2", forKey: "searchRadius")
        }
        
        // Movie
        if defaults.string(forKey: "database") == nil {
            defaults.set("IMDB", forKey: "database")
        }
        
        if defaults.string(forKey: "IMDBrating") == nil {
            defaults.set("6", forKey: "IMDBrating")
        }
        
        if defaults.string(forKey: "RTrating") == nil {
            defaults.set("60", forKey: "RTrating")
        }
        
        if defaults.string(forKey: "showYear") == nil {
            defaults.set("1930", forKey: "showYear")
        }
        
        if defaults.string(forKey: "showType") == nil {
            defaults.set("movie", forKey: "showType")
        }
        
        if defaults.string(forKey: "genrePreference") == nil {
            defaults.set(false, forKey: "genrePreference")
        }
        
        if defaults.string(forKey: "tvGenrePreference") == nil {
            defaults.set("Sci-Fi & Fantasy", forKey: "tvGenrePreference")
        }
        
        if defaults.string(forKey: "movieGenrePreference") == nil {
            defaults.set("Science Fiction", forKey: "movieGenrePreference")
        }
        
        if defaults.string(forKey: "movieGenres") == nil {
            var showGenres = [String]()
            GenresMDB.genres(listType: .movie, language: "en") {
                apiReturn, genres in
                if let genres = genres {
                    genres.forEach {
                        showGenres.append($0.name!)
                    }
                }
                defaults.set(showGenres, forKey: "movieGenres")
            }
        }
        
        if defaults.string(forKey: "tvGenres") == nil {
            var showGenres = [String]()
            GenresMDB.genres(listType: .tv, language: "en") {
                apiReturn, genres in
                if let genres = genres {
                    genres.forEach {
                        showGenres.append($0.name!)
                    }
                }
                defaults.set(showGenres, forKey: "tvGenres")
            }
        }
        
        // Explore
        if defaults.string(forKey: "exploreSearchRadius") == nil {
            defaults.set("20", forKey: "exploreSearchRadius")
        }
        
        if defaults.string(forKey: "exploreUnits") == nil {
            defaults.set("miles", forKey: "exploreUnits")
        }
        
        if defaults.stringArray(forKey: "locationsArray") == nil {
            let locations = ["Aquarium","Art Gallery","Campground","Cemetery","Gym","Museum","Night Club","Park","Zoo"]
            let locationsValue = ["aquarium","art_gallery","campground","cemetery","gym","museum","night_club","park","zoo"]
            defaults.set(locations, forKey: "locationsArray")
            defaults.set(locationsValue, forKey: "locationsValueArray")
        }
        
        if defaults.string(forKey: "locationType") == nil {
            defaults.set("Park", forKey: "locationType")
        }
        
        if defaults.string(forKey: "locationTypeValue") == nil {
            defaults.set("park", forKey: "locationTypeValue")
        }
        
        // Drink
        if defaults.string(forKey: "drinkRating") == nil {
            defaults.set(3, forKey: "drinkRating")
        }
        
        if defaults.string(forKey: "withAlcohol") == nil {
            defaults.set(true, forKey: "withAlcohol")
        }
        
        if defaults.string(forKey: "liquorOptions") == nil {
            let drinkTypes = ["no preference","brandy","gin","rum","tequila","whiskey","vodka"]
            defaults.set(drinkTypes, forKey: "liquorOptions")
        }
        
        if defaults.string(forKey: "madeWith") == nil {
            defaults.set("no preference", forKey: "madeWith")
        }
    }
}


extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
    
}

extension Array where Element: Hashable {
    var occurrences: [Element:Int] {
        return reduce(into: [:]) { $0[$1, default: 0] += 1 }
    }
    func occurrences(of element: Element) -> Int {
        return occurrences[element] ?? 0
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String, font: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: font)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String, font: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: font)]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        
        return self
    }
    
    @discardableResult func italics(_ text: String, font: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.italicSystemFont(ofSize: font)]
        let italicsString = NSAttributedString(string: text, attributes: attrs)
        append(italicsString)
        
        return self
    }
    
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        var newImage: UIImage
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = false
            let renderer = UIGraphicsImageRenderer(size: newSize, format: renderFormat)
            newImage = renderer.image { (context) in
                self.draw(in: rect)
            }
        }
        else {
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.draw(in: rect)
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
