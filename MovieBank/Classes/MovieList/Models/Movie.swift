//
//  Movie.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import Foundation

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let genreIDs: [Int]

    let adult: Bool
    let video: Bool

    let popularity: Double
    let voteAverage: Double
    let voteCount: Int
    let originalLanguage: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case adult
        case video
        case popularity
        case voteCount = "vote_count"
        case voteAverage = "vote_average"
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case genreIDs = "genre_ids"
    }
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: APIConstants.imageBaseURL + path)
    }
}

