//
//  Review.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import Foundation

struct ReviewResponse: Codable {
    let results: [Review]
}

struct Review: Codable {
    let id: String
    let author: String
    let content: String
    let createdAt: String
    let authorDetails: AuthorDetails?
    
    enum CodingKeys: String, CodingKey {
        case id, author, content
        case createdAt = "created_at"
        case authorDetails = "author_details"
    }
}

struct AuthorDetails: Codable {
    let name: String?
    let username: String?
    let avatarPath: String?
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case name
        case username
        case avatarPath = "avatar_path"
        case rating
    }
    
    var avatarURL: URL? {
        guard let path = avatarPath else { return nil }
        return URL(string: APIConstants.imageBaseURL + path)
    }
}

