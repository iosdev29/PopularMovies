//
//  MovieVC.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 25.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

class MovieVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var backgroundPoster: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var directorsLabel: UILabel!
    
    @IBOutlet weak var actorsCollectionView: UICollectionView!
    @IBOutlet weak var genresCollectionView: UICollectionView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var movie: Movie!
    var genres: [String]?
    
    var cast: [(name: String, photoUrl: String, gender: Int?)]?
    
    var movieCast: MovieCast? {
        didSet {
            if movieCast != nil {
                cast = getCast(movieCast: movieCast!)
                configureCastLabels(directors: getDirectors(movieCast: movieCast!))
            }
        }
    }
    
    private var sizingCell: TagCell?
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        configureViews()
    }
    
    func configureViews() {
        configureData()
        addBlurToBackground()
        configureCollectionViews()
        configureContainerView()
        
        guard let id = movie.id else {
            return
        }
        fetchCast(movieId: id)
    }
    
    // MARK: - Configuration
    
    func configureData() {
        /// loading images
        if let strUrl = movie.poster {
            backgroundPoster.loadImageAsync(with: Constants.smallPosterURL + strUrl)
            posterImageView.loadImageAsync(with: Constants.smallPosterURL + strUrl)
        }
        /// setting text properties
        nameLabel.text = movie.name
        descriptionLabel.text = movie.description
        releaseDateLabel.text = movie.date
    }
    
    // add blur to backgroundPoster
    func addBlurToBackground() {
        if !UIAccessibility.isReduceTransparencyEnabled {
            backgroundPoster.backgroundColor = .clear
            let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            backgroundPoster.addSubview(blurEffectView)
        } else {
            view.backgroundColor = .black
        }
    }
    
    func configureContainerView() {
        posterImageView.layer.cornerRadius = 8
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let height = heightForView(text: movie.name, font: UIFont.nunitoFont(.regular, ofSize: 30), width: self.view.bounds.width - 32)
        containerViewTopConstraint.constant = height + 100
    }
    
    func configureCollectionViews() {
        /// genresCollectionView flow layout
        let flow = UICollectionViewFlowLayout()
        flow.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        genresCollectionView?.setCollectionViewLayout(flow, animated: false)
        
        /// register genresCellNib
        let genresCellNib = UINib(nibName: "TagCell", bundle: nil)
        genresCollectionView.register(genresCellNib, forCellWithReuseIdentifier: "tagCell")
        sizingCell = genresCellNib.instantiate(withOwner: nil, options: nil)[0] as? TagCell
        
        /// register actorCellNib
        let actorCellNib = UINib(nibName: "ActorCell", bundle: nil)
        actorsCollectionView.register(actorCellNib, forCellWithReuseIdentifier: "actorCell")
    }
    
    func configureCastLabels(directors: [String]) {
        DispatchQueue.main.async {
            directors.forEach { (name) in
                self.directorsLabel.text = (self.directorsLabel.text ?? "") + name + "\n"
            }
            
            self.actorsCollectionView.reloadData()
        }
    }
    
    func heightForView(text:String, font: UIFont, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    // MARK: — Data fetch
    
    func fetchCast(movieId: Int) {
        Service.shared.fetchMovieCast(movieId: movieId) { (res, err) in
            if let res = res {
                self.movieCast = res
            }
            if let err = err {
                print("Cast fetch failed", err)
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
    
    func getCast(movieCast: MovieCast) -> [(String, String, Int?)] {
        var cast = [(String, String, Int)]()
        movieCast.cast.forEach { (actor) in
            cast.append((actor.name, actor.image ?? "", actor.gender ?? -1))
        }
        return cast
    }
    
    // MARK: - Actions

    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionView

extension MovieVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.genresCollectionView {
            return genres?.count ?? 0
        } else {
            return cast?.count ?? 0
        }
    }
    
    func _configureCell(_ cell: TagCell?, for indexPath: IndexPath?) {
        cell?.myLabel.text = self.genres?[indexPath!.item]
        cell?.layer.cornerRadius = (cell?.frame.height ?? 0) / 2
        cell?.layer.masksToBounds = true
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.genresCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as? TagCell else {
                fatalError("Could not dequeue cell with identifier: TagCell")
            }
            _configureCell(cell, for: indexPath)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "actorCell", for: indexPath) as? ActorCell else {
                fatalError("Could not dequeue cell with identifier: ActorCell")
            }
            cell.actorNameLabel.text = cast?[indexPath.row].0
            if let url = cast?[indexPath.row].1, url != "" {
                cell.actorImageView.loadImageAsync(with: Constants.posterURL + url)
            } else {
                cell.actorImageView.image = cast?[indexPath.row].gender == 1 ? UIImage(named: "femaleAvatar") : UIImage(named: "maleAvatar")
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.genresCollectionView {
            _configureCell(sizingCell, for: indexPath)
            return sizingCell?.intrinsicContentSize() ?? CGSize.zero
        } else {
            return CGSize(width: 120, height: 136)
        }
    }
    
}
