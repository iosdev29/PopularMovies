//
//  PopularMovieResult.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

// MARK: - Trending Movies
struct TrendingMovies: Codable {
    let page: Int
    let lastPage: Int
    let results: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case page
        case lastPage = "total_pages"
        case results
    }
}

// MARK: - Movie
struct Movie: Codable {
    let name: String
    let description: String
    let poster: String?
    let date: String?
    let genres: [Int]?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case name = "title"
        case description = "overview"
        case poster = "poster_path"
        case date = "release_date"
        case genres = "genre_ids"
        case id = "id"
    }
}

// MARK: - Genres
struct Genres: Codable {
    let genres: [Genre]?
    
    enum CodingKeys: String, CodingKey {
        case genres = "genres"
    }
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
}

// MARK: - MovieCast
struct MovieCast: Codable {
    let cast: [Cast]
    let crew: [Crew]
}

// MARK: - Cast
struct Cast: Codable {
    let name: String
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case image = "profile_path"
    }
}

// MARK: - Crew
struct Crew: Codable {
    let job, name: String

    enum CodingKeys: String, CodingKey {
        case job, name
    }
}
