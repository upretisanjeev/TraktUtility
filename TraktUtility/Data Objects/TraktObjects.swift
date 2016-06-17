//
//  TraktObjects.swift
//  TraktUtility
//
//  Created by Sanjeev Upreti on 03/06/16.
//  Copyright © 2016 Sanjeev Upreti. All rights reserved.
//

// MARK: - Class Imports
import Foundation


// MARK: - ID for a movie
struct MovieID {
    // MARK: - properties
    let trakt: Int?
    let slug: String?
    let imdb: String?
    let tmdb: Int?
    
    /// initialize the ids for a movie.
    init(idJSON: JSONDictionary) {
        trakt   = idJSON["trakt"] as? Int
        slug    = idJSON["slug"] as? String
        imdb    = idJSON["imdb"] as? String
        tmdb    = idJSON["tmdb"] as? Int
    }
}

// MARK: - TraktImageUrls for a movie
struct TraktImageUrls {
    // MARK: - properties
    let poster: TraktImageUrl?
    let fanart: TraktImageUrl?
    
    /// initialize the image urls for a movie.
    init(imageUrlJSON: JSONDictionary) {
        if let posterJSON = imageUrlJSON["poster"] as? JSONDictionary {
            poster = TraktImageUrl(imageUrl: posterJSON)
        }
        else {
            poster = nil
        }
        if let fanartJSON = imageUrlJSON["fanart"] as? JSONDictionary {
            fanart = TraktImageUrl(imageUrl: fanartJSON)
        }
        else {
            fanart = nil
        }
    }
}

// MARK: - TraktImageUrl for a movie
struct TraktImageUrl {
    // MARK: - properties
    let full: NSURL?
    let medium: NSURL?
    let thumb: NSURL?
    
    /// initialize the image urls for a movie.
    init(imageUrl: JSONDictionary) {
        full = NSURL(string: imageUrl["full"] as? String ?? "") ?? nil
        medium = NSURL(string: imageUrl["medium"] as? String ?? "") ?? nil
        thumb = NSURL(string: imageUrl["thumb"] as? String ?? "") ?? nil
    }
}

// MARK: - struct Movie encapsulates basic information of a movie
struct TraktMovie {
    
    // MARK: - properties
    let title: String?
    let year: Int?
    let overview: String?
    let ids: MovieID?
    let imageUrls: TraktImageUrls?

    /// initializes the movie properties
    init(movieJSON:JSONDictionary) {
        title = movieJSON["title"] as? String
        year = movieJSON["year"] as? Int
        overview = movieJSON["overview"] as? String
        if let idJSON = movieJSON["ids"] as? JSONDictionary {
            ids = MovieID(idJSON: idJSON)
        }
        else {
            ids = nil
        }
        if let imageUrlJSON = movieJSON["images"] as? JSONDictionary {
            imageUrls = TraktImageUrls(imageUrlJSON: imageUrlJSON)
        }
        else {
            imageUrls = nil
        }
    }
    
    func traktUrl() -> NSURL? {
        guard let slug = self.ids?.slug else {
            return nil;
        }
        return NSURL(string: "https://trakt.tv/movies/" + slug) ?? nil
    }
    
    func imdbUrl() -> NSURL? {
        guard let imdb = self.ids?.imdb else {
            return nil;
        }
        return NSURL(string: "http://www.imdb.com/title/" + imdb) ?? nil
    }

    func tmdbUrl() -> NSURL? {
        guard let tmdb = self.ids?.tmdb else {
            return nil;
        }
        return NSURL(string: "https://www.themoviedb.org/movie/" + String(tmdb)) ?? nil
    }

}

// MARK: - TraktSearchedMovieResult encapsulates information of a  searched movie result
struct TraktSearchedMovieResult {
    // MARK: - properties
    let score: Double?
    let movie: TraktMovie?
    
    /// initializes the searched-movie-result properties
    init(searchedMovieResult:JSONDictionary) {
        score = searchedMovieResult["score"] as? Double
        if let movieJSON = searchedMovieResult["movie"] as? JSONDictionary  {
            movie = TraktMovie(movieJSON: movieJSON)
        }
        else{
            movie = nil
        }
    }

}
