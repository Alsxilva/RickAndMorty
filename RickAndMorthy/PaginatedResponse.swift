//
//  PaginatedResponse.swift
//  RickAndMorthy
//
//  Created by Alex Silva on 27/12/24.
//

import Foundation

struct PaginatedResponse<T: Codable>: Codable {
    let info: Info
    let results: [T]
}

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
