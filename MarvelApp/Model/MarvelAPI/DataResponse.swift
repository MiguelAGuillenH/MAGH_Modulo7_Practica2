//
//  DataResponse.swift
//  MarvelApp
//
//  Created by DISMOV on 03/05/24.
//

import Foundation

struct DataResponse<T: Codable>: Codable {
    let offset: Int
    let limit: Int
    let total: Int
    let count: Int
    let results: [T]
}
