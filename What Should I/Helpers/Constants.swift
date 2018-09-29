//
//  Constants.swift
//  Places
//
//  Created by Karthi Ponnusamy on 1/4/17.
//  Copyright © 2017 Karthi Ponnusamy. All rights reserved.
//

import Foundation
struct Constants {
    static let PLACES_API_KEY = "AIzaSyDqDHCYKkSGWsCkSwwKOYtSWj6e4dcS944"
    static let PLACES_SEARCH_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=%@&types=%@&name=%@&key=%@"
    static let PLACES_DETAIL_URL = "https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=%@"
    static let PLACES_PHOTO_URL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&key=%@"
    static let PLACES_AUTO_COMPLETE_URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%@,%@&radius=%@&types=establishment&key=%@"
    static let SELECTED_TYPE = "restaurant";
}
