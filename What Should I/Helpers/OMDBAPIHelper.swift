//
//  APIHelper.swift
//  OMDb
//
//  Created by Saurabh Garg on 26/09/2016.
//  Copyright © 2016 Gargs. All rights reserved.
//

import UIKit

func baseURLComponents() -> URLComponents {
    var urlComponents = URLComponents()
    urlComponents.scheme = "http"
    urlComponents.host = "omdbapi.com"
    urlComponents.path = "/"
    
    return urlComponents
}

func searchURL(searchTerm: String, pageNumber: Int = 1) -> URL? {
    var components = baseURLComponents()
    let apiQueryItem = URLQueryItem(name: "apikey", value: "7ce9ed2d")
    let searchQueryItem = URLQueryItem(name: "t", value: searchTerm) // or s?
    let plotQueryItem = URLQueryItem(name: "plot", value: "full")
    let typeQueryItem = URLQueryItem(name: "r", value: "json")
    let apiVersionQueryItem = URLQueryItem(name: "v", value: "1")
    let pageNumberQueryItem = URLQueryItem(name: "page", value: String(pageNumber))
    
    components.queryItems = [apiQueryItem, searchQueryItem, plotQueryItem, typeQueryItem, apiVersionQueryItem, pageNumberQueryItem]
    return components.url
}

func search(for searchTerm: String, pageNumber: Int = 1, completionHandler: ((SearchResult?, Error?) -> Void)?) -> URLSessionDataTask? {
    let session = URLSession.shared
    
    if let searchURL = searchURL(searchTerm: searchTerm, pageNumber: pageNumber) {
        let request = URLRequest(url: searchURL)
        let downloadTask = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let results = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) {
                    let searchResults = parseSearchResult(results)
                    //debugPrint(searchResults!)
                    DispatchQueue.main.async {
                        completionHandler?(searchResults, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: "com.cerebrawl.OMDb.error", code: 301, userInfo: [NSLocalizedDescriptionKey: "JSON Parsing error"])
                        completionHandler?(nil, error)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler?(nil, error)
                }
            }
        }
        downloadTask.resume()
        return downloadTask
    }
    return nil
}


func parseSearchResult(_ resultsDictionary: Any, pageNumber: Int = 1) -> SearchResult? {
    
    var movies: [Movie]?
    if let movieResult = resultsDictionary as? NSDictionary {
        
        let response = movieResult["Response"] as! String
        
        if response == "True" {
            let title = movieResult["Title"] as! String
            let year = movieResult["Year"] as! String
            let imdbID = movieResult["imdbID"] as! String
            let type = Type(rawValue: movieResult["Type"] as! String)
            let posterURL: URL?
            if let posterURLString = movieResult["Poster"] as? String {
                posterURL = URL(string: posterURLString)
            } else {
                posterURL = nil
            }
            let cast = movieResult["Actors"] as? String
            let plot = movieResult["Plot"] as? String
            let imdbRating = movieResult["imdbRating"] as? String
            let imdbVotes = movieResult["imdbVotes"] as? String
            let rated = movieResult["Rated"] as? String
            let tomatoRating = movieResult["Metascore"] as? String
            let genres = movieResult["Genre"] as? String
            let runtime = movieResult["Runtime"] as? String
            
            let movie = Movie(title: title, year: year, imdbID: imdbID, type: type, posterURL: posterURL, posterImage: UIImagePNGRepresentation(UIImage(named: "placeholder_image")!), plot: plot, imdbRating: imdbRating, imdbVotes: imdbVotes, tomatoRating: tomatoRating, cast: cast, rated: rated, genres: genres, runtime: runtime)
            movies = movies ?? []
            movies?.append(movie)
            
            let searchResult = SearchResult(totalResultCount: 1, currentPage: pageNumber, movies: movies)
            return searchResult
            
        } else {
            return nil
        }
    }
    
    return nil
}


func posterImage(for url: URL, completionHandler: ((UIImage?) -> Void)?) -> URLSessionDataTask? {
    let session = URLSession.shared
    let downloadTask = session.dataTask(with: url) { (data, response, error) in
        if data != nil {
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    completionHandler?(image)
                }
            }
        }
    }
    downloadTask.resume()
    return downloadTask
}
