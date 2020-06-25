//
//  ViewController.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

enum State {
    case trending
    case search
}

class TrendingMoviesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Local variables
    
    var pageMovies = 1
    var lastPageMovies = 1
    
    var pageSearch = 1
    var lastPageSearch = 1
    
    var searchTerm = ""
    
    var selectedMovieIndexPath: IndexPath?
    var allGenres: [Genre]?
    
    var state: State = .trending {
        didSet {
            switch state {
            case .search:
                result = searchedMovies
            case .trending:
                result = movies
            }
        }
    }
    
    let cellHeight : CGFloat = 160
    
    var movies: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.result = self.movies
            }
        }
    }
    
    var searchedMovies: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.result = self.searchedMovies
            }
        }
    }
    
    var result: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "MovieCell", bundle: nil), forCellReuseIdentifier: "movieCell")
        fetchMovies(page: pageMovies)
        fetchGenres()
    }
    
    
    // MARK: — Data fetch
    fileprivate func fetchMovies(page: Int) {
        Service.shared.fetchMovieDetail(page: page) { (res, err) in
            if let res = res {
                self.movies += res.results
                self.lastPageMovies = res.lastPage
                self.pageMovies = res.page
            }
            if let err = err {
                print("Trending movies fetch failed", err)
            }
        }
    }
    
    fileprivate func searchMovies(searchTerm: String, page: Int) {
        Service.shared.searchMovie(searchTerm: searchTerm, page: page) { (res, err) in
            if let res = res {
                self.searchedMovies += res.results
                self.lastPageSearch = res.lastPage
                self.pageSearch = res.page
            }
            if let err = err {
                print("Search movies fetch failed", err)
            }
        }
    }
    
    fileprivate func fetchGenres() {
        Service.shared.fetchGenres() { (res, err) in
            if let res = res {
                self.allGenres = res.genres
            }
            if let err = err {
                print("Genres fetch failed", err)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToMovie" {
            let destView = segue.destination as! MovieVC
            if let indexPath = selectedMovieIndexPath {
                destView.movie = result[indexPath.row]
                if let genres = result[indexPath.row].genres {
                    destView.genres = getGenresForMovie(genresId: genres)
                }
            }
        }
    }
    
    func getGenresForMovie(genresId: [Int]) -> [String]? {
        var genres = [String]()
        
        if let safeAllGenres = allGenres {
            safeAllGenres.forEach({ (genre) in
                if genresId.contains(genre.id ?? 0) {
                    genres.append(genre.name ?? "No genres")
                }
            })
        }
        return genres
    }
    
}

extension TrendingMoviesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        if result.count > 0 {
            if let strUrl = result[indexPath.row].poster {
                cell.posterImageView.loadImageAsync(with: Constants.smallPosterURL + strUrl)
            }
            
            cell.titleLabel.text = result[indexPath.row].name
            cell.descriptionLabel.text = result[indexPath.row].description
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // if UITableView reached bottom load movies from next page
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // loading content from the next page
        let isLastPage = state == .trending ? pageMovies != lastPageMovies : pageSearch != lastPageSearch
        if indexPath.row + 1 == result.count && (isLastPage || !result.isEmpty) {
            switch state {
            case .trending:
                if pageMovies != lastPageMovies && !result.isEmpty {
                    fetchMovies(page: pageMovies + 1)
                }
            case .search:
                if pageSearch < lastPageSearch && !result.isEmpty {
                    searchMovies(searchTerm: searchTerm, page: pageSearch + 1)
                }
            }
        }
        
        // animate appearing cells
        if let lastIndexPath = tableView.indexPathsForVisibleRows?.last {
            if lastIndexPath.row <= indexPath.row {
                cell.alpha = 0
                UIView.animate(withDuration: 0.2) {
                    cell.alpha = 1.0
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMovieIndexPath = indexPath
        self.performSegue(withIdentifier: "goToMovie", sender: self)
    }
    
    // snap to cell after scrolling
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard var scrollingToIP = tableView.indexPathForRow(at: CGPoint(x: 0, y: targetContentOffset.pointee.y)) else {
            return
        }
        var scrollingToRect = tableView.rectForRow(at: scrollingToIP)
        let roundingRow = Int(((targetContentOffset.pointee.y - scrollingToRect.origin.y) / scrollingToRect.size.height).rounded())
        scrollingToIP.row += roundingRow
        scrollingToRect = tableView.rectForRow(at: scrollingToIP)
        targetContentOffset.pointee.y = scrollingToRect.origin.y
    }
    
}


extension TrendingMoviesVC: UISearchBarDelegate {
    
    // dismiss the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        perform(#selector(hideKeyboardWithSearchBar), with: searchBar, afterDelay: 0)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            perform(#selector(hideKeyboardWithSearchBar), with: searchBar, afterDelay: 0)
            state = .trending
        } else {
            state = .search
            let searchTextModify = searchText.replacingOccurrences(of: " ", with: "+")
            searchTerm = searchTextModify
            pageSearch = 1
            searchedMovies.removeAll()
            searchMovies(searchTerm: searchTextModify, page: pageSearch)
        }
    }
    
    @objc public func hideKeyboardWithSearchBar() {
        searchBar.resignFirstResponder()
    }
    
}
