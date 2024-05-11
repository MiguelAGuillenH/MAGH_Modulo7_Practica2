//
//  Character.swift
//  MarvelApp
//
//  Created by MAGH on 03/05/24.
//

import Foundation

struct Character: Codable {
    let id: Int
    let name: String
    let description: String
    let modified: String
    let thumbnail: Image
    let urls: [URLWebSite]
    let comics: ResourceList<ComicItem>
    let stories: ResourceList<StoryItem>
    let events: ResourceList<EventItem>
    let series: ResourceList<SeriesItem>
}
