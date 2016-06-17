//
//  TraktManager.swift
//  TraktUtility
//
//  Created by Sanjeev Upreti on 03/06/16.
//  Copyright © 2016 Sanjeev Upreti. All rights reserved.
//

// MARK: - Class Imports
import Foundation
import Alamofire
import AlamofireImage

// MARK: - JSONDictionary
public typealias JSONDictionary = [String: AnyObject] 

// MARK: - trakt Client-Id
private let TRAKT_CLIENT_ID = "ad005b8c117cdeee58a1bdb7089ea31386cd489b21e14b19818c91511f12a086"

// MARK: - WebService Constants
let BASE_URL = "https://api-v2launch.trakt.tv"
let POPULAR_MOVIES_END_POINT = "/movies/popular"
let SEARCH_END_POINT = "/search"


// MARK: - WebService methods are added as extension on UIViewController
class TraktManager {
    
    // MARK: - Singleton setup
    static let sharedTraktManager = TraktManager()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
    // reference for current search request
    var searchRequest: Alamofire.Request?
    
    /// Method to get request headers.
    func requestHeaders() -> [String: String] {
        return [
            "content-type": "application/json",
            "trakt-api-version": "2",
            "trakt-api-key": TRAKT_CLIENT_ID,
        ]
    }
    
    /// WebService to fetch popular movies.
    func fetchPopularMovies(forPage page: Int?,
                                    limit:Int?,
                                    failure: (String?) -> Void,
                                    completion: ([TraktMovie]?) -> Void) {
        
        guard let page = page else {
            print("page parameter found nil in fetchPopularMovies")
            return
        }
        guard let limit = limit else {
            print("limit parameter found nil in fetchPopularMovies")
            return
        }
        
        let requestUrl = BASE_URL + POPULAR_MOVIES_END_POINT
        let requestParameters = ["page": String(page),
                                 "limit": String(limit)]
        
        Alamofire.request(
            .GET,
            requestUrl,
            parameters:requestParameters,
            encoding: .URL,
            headers:self.requestHeaders())
            .validate()
            .responseJSON {
                (response) -> Void in
                
                guard response.result.isSuccess else {
                    print("Error while fetching popular movies: \(response.result.error)")
                    // call failure handler
                    failure(response.result.error?.localizedDescription)
                    return
                }
                
                guard let movieDictionaries = response.result.value as? [JSONDictionary] else {
                    print("Malformed data received from fetchPopularMovies web service")
                    failure("Malformed data received from fetchPopularMovies web service")
                    return
                }
                
                // iterate through received movieDictionaries and create array of movie objects
                var movies = [TraktMovie]()
                for movieJSON in movieDictionaries {
                    movies.append(TraktMovie(movieJSON: movieJSON))
                }
                
                // call completion handler
                completion(movies)
        }
    }
    
    
    
    /// WebService to search movies.
    func searchMoviesForQuery(query: NSString?,
                                forPage page: Int?,
                                    limit:Int?,
                                    failure: (String?) -> Void,
                                    completion: ([TraktSearchedMovieResult]?) -> Void) {
        guard let query = query else {
            print("query parameter found nil in searchMoviesForQuery")
            return
        }

        guard let page = page else {
            print("page parameter found nil in searchMoviesForQuery")
            return
        }
        guard let limit = limit else {
            print("limit parameter found nil in searchMoviesForQuery")
            return
        }
        
        // cancel old request
        searchRequest?.cancel()
        
        let requestUrl = BASE_URL + SEARCH_END_POINT
        let requestParameters = ["query":query,
                                 "type":"movie",
                                 "page": String(page),
                                 "limit": String(limit)]
        searchRequest = Alamofire.request(
            .GET,
            requestUrl,
            parameters:requestParameters,
            encoding: .URL,
            headers:self.requestHeaders())
        
        searchRequest?.validate()
            .responseJSON {
                (response) -> Void in
                guard response.result.isSuccess else {
                    if response.result.error?.code == NSURLErrorCancelled {
                        return
                    }

                    print("Error while searching movies: \(response.result.error)")
                    // call failure handler
                    failure(response.result.error?.localizedDescription)
                    return
                }
                
                guard let movieDictionaries = response.result.value as? [JSONDictionary] else {
                    print("Malformed data received from searchMoviesForQuery web service")
                    failure("Malformed data received from searchMoviesForQuery web service")
                    return
                }
                
                // iterate through received movieDictionaries and create array of movie objects
                var searchedResults = [TraktSearchedMovieResult]()
                for searchedMovieResult in movieDictionaries {
                    searchedResults.append(TraktSearchedMovieResult(searchedMovieResult: searchedMovieResult))
                }
                
                // call completion handler
                completion(searchedResults)
        }
    }
}
