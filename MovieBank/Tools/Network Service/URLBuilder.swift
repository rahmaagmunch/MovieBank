//
//  URLBuilder.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import Foundation

protocol URLBuilderProtocol {
    func buildMoviesURL(page: Int) -> URL?
    func buildMovieDetailsURL(id: Int) -> URL?
    func buildReviewsURL(movieId: Int) -> URL?
    func buildVideosURL(movieId: Int) -> URL?
}

class URLBuilder: URLBuilderProtocol {
    private let baseURL: String
    private let apiKey: String
    
    init(baseURL: String = APIConstants.baseURL,
         apiKey: String = APIConstants.apiKey) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }
    
    func buildMoviesURL(page: Int) -> URL? {
        return buildURL(path: "/movie/popular", queryItems: [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: "\(page)")
        ])
    }
    
    func buildMovieDetailsURL(id: Int) -> URL? {
        return buildURL(path: "/movie/\(id)", queryItems: [
            URLQueryItem(name: "api_key", value: apiKey)
        ])
    }
    
    func buildReviewsURL(movieId: Int) -> URL? {
        return buildURL(path: "/movie/\(movieId)/reviews", queryItems: [
            URLQueryItem(name: "api_key", value: apiKey)
        ])
    }
    
    func buildVideosURL(movieId: Int) -> URL? {
        return buildURL(path: "/movie/\(movieId)/videos", queryItems: [
            URLQueryItem(name: "api_key", value: apiKey)
        ])
    }
        
    private func buildURL(path: String, queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(string: baseURL + path) else {
            return nil
        }
        components.queryItems = queryItems
        return components.url
    }
}
