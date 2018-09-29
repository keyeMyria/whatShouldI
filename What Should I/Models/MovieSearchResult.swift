//
//  SearchResult.swift
//  OMDb
//
//  Created by Saurabh Garg on 26/09/2016.
//  Copyright © 2016 Gargs. All rights reserved.
//

import Foundation

enum Type: String {
    case movie
    case series
    case short
    case game
    
    func iconLabel() -> String {
        switch self {
        case .movie:
            return "📽"
        case .series:
            return "📺"
        case .short:
            return "🎞"
        case .game:
            return "🕹"
        }
    }
}

struct SearchResult {
    var totalResultCount: Int
    var currentResultCount: Int {
        get {
            return movies?.count ?? 0
        }
    }
    var currentPage: Int
    var movies: [Movie]?
    
    mutating func append(_ searchResults: SearchResult) {
        if let newMovies = searchResults.movies, newMovies.count > 0 {
            movies = movies ?? []
            movies!.append(contentsOf: newMovies)
            currentPage = currentPage + 1
        }
    }
}

struct Movie {
    var title: String
    var year: String
    var imdbID: String
    var type: Type?
    var posterURL: URL?
    var posterImage: Data?
    var plot: String?
    var imdbRating: String?
    var imdbVotes: String?
    var tomatoRating: String?
    var cast: String?
    var rated: String?
    var genres: String?
    var runtime: String?
}

