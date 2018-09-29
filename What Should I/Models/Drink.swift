//
//  Drink.swift
//  What Should I
//
//  Created by Jiang, Tony on 2/14/18.
//  Copyright © 2018 Jiang, Tony. All rights reserved.
//

import Foundation

class Drink {
    var name: String?
    var drinkId: String?
    var directions: String?
    var story: String?
    var rating: String?
    var skill: String?
    var ingredients: [String] = [] //ingredients and amount are separated in cocktail DB
    var measurements: [String] = []
    var tastes: String?
    var tools: String?
    var videoName: String?
    var photoImage: Data?
    var thumbnailURLString: String?
}
