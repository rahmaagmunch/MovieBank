//
//  Video.swift
//  MovieBank
//
//  Created by Rahma Agustina on 22/01/26.
//

import Foundation

struct VideoResponse: Codable {
    let results: [Video]
}

struct Video: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}
