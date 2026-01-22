//
//  NetworkError.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case serverError(Int)
    case noInternetConnection
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let error):
            return error.localizedDescription
        case .serverError(let code):
            return "Server error: \(code)"
        case .noInternetConnection:
            return "No internet connection. Please check your network."
        }
    }
}
