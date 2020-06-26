//
//  Service.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import Foundation

class Service {
    
    static let shared = Service()
    
    func fetchMovieDetail(page: Int, completion: @escaping (TrendingMovies?, Error?) -> ()) {
        let urlString = "\(Constants.url)?api_key=\(Constants.api)&page=\(page)"
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(TrendingMovies.self, from: data)
                completion(result, nil)
            } catch let jsonErr {
                print("Failed to decode json", jsonErr)
                completion(nil, err)
            }
            
            if let err = err {
                print("Failed to fetch")
                completion(nil, err)
                return
            }
        }.resume()
    }
    
    func searchMovie(searchTerm: String, page: Int, completion: @escaping (TrendingMovies?, Error?) -> ()) {
        let urlString = "\(Constants.searchURL)?api_key=\(Constants.api)&query=\(searchTerm)&page=\(page)"
        guard let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(TrendingMovies.self, from: data)
                completion(result, nil)
            } catch let jsonErr {
                print("Failed to decode json", jsonErr)
                completion(nil, err)
            }
            
            if let err = err {
                print("Failed to fetch")
                completion(nil, err)
                return
            }
        }.resume()
    }
    
    func fetchGenres(completion: @escaping (Genres?, Error?) -> ()) {
        guard let url = URL(string: Constants.genresURL) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Genres.self, from: data)
                completion(result, nil)
            } catch let jsonErr {
                print("Failed to decode json", jsonErr)
                completion(nil, err)
            }
            
            if let err = err {
                print("Failed to fetch")
                completion(nil, err)
                return
            }
            
        }.resume()
    }
    
    func fetchMovieCast(movieId: Int, completion: @escaping (MovieCast?, Error?) -> ()) {
        guard let url = URL(string: "\(Constants.baseURL)\(movieId)/credits?api_key=\(Constants.api)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else {
                return
            }
            
            do {
                let result = try JSONDecoder().decode(MovieCast.self, from: data)
                completion(result, nil)
            } catch let jsonErr {
                print("Failed to decode json", jsonErr)
                completion(nil, err)
            }
            
            if let err = err {
                print("Failed to fetch")
                completion(nil, err)
                return
            }
            
        }.resume()
    }
    
}

