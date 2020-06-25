//
//  MovieVC.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 25.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

class MovieVC: UIViewController {
    
    @IBOutlet weak var backgroundPoster: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    
    var movie: Movie!
    var genres: [String]?
    var directors: [String]?
    var cast: [String]?
    
    var movieCast: MovieCast? {
        didSet(newValue) {
            if movieCast != nil {
                getCast(movieCast: movieCast!)
                getDirectors(movieCast: movieCast!)
            }
        }
    }
    
    var blurEffectView : UIVisualEffectView!
    
    private var sizingCell: TagCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    func configureViews() {
        if let strUrl = movie.poster {
            backgroundPoster.loadImageAsync(with: Constants.smallPosterURL + strUrl)
            posterImageView.loadImageAsync(with: Constants.smallPosterURL + strUrl)
        }
        
        nameLabel.text = movie.name
        descriptionLabel.text = movie.description
        releaseDateLabel.text = movie.date
        
        // add blur to backgroundPoster
        if !UIAccessibility.isReduceTransparencyEnabled {
            backgroundPoster.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            backgroundPoster.addSubview(blurEffectView)
        } else {
            view.backgroundColor = .black
        }
        
        posterImageView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 16
        
        let height = heightForView(text: movie.name, font: UIFont.nunitoFont(.regular, ofSize: 30), width: self.view.bounds.width - 32)
        containerViewTopConstraint.constant = height + 100
        
        // flow layout
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        collectionView?.setCollectionViewLayout(flow, animated: false)
        
        
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: "tagCell")
        sizingCell = cellNib.instantiate(withOwner: nil, options: nil)[0] as? TagCell
        
        guard let id = movie.id else {
            return
        }
        
        fetchCast(movieId: id)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchCast(movieId: Int) {
        Service.shared.fetchMovieCast(movieId: movieId) { (res, err) in
            if let res = res {
                self.movieCast = res
            }
            if let err = err {
                print("Search movies fetch failed", err)
            }
        }
    }
    
    func getDirectors(movieCast: MovieCast) -> [String] {
        var directors = [String]()
        movieCast.crew.forEach { (person) in
            if person.job == "Director" {
                directors.append(person.name)
            }
        }
        return directors
    }
    
    func getCast(movieCast: MovieCast) {
        
    }
    
}

// MARK: - UICollectionView

extension MovieVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres?.count ?? 0
    }
    
    func _configureCell(_ cell: TagCell?, for indexPath: IndexPath?) {
        cell?.myLabel.text = self.genres?[indexPath!.item]
        cell?.layer.cornerRadius = (cell?.frame.height ?? 0) / 2
        cell?.layer.masksToBounds = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagCell
        
        _configureCell(cell, for: indexPath)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        _configureCell(sizingCell, for: indexPath)
        
        return sizingCell?.intrinsicContentSize() ?? CGSize.zero
    }
    
}
