//
//  MovieCell.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configureView() {
        posterImageView.layer.cornerRadius = 4
        containerView.layer.cornerRadius = 8
        containerView.layer.applySketchShadow(color: #colorLiteral(red: 0.8196078431, green: 0.8509803922, blue: 0.9019607843, alpha: 1), alpha: 1, x: 9, y: 9, blur: 10, spread: 0)
    }
    
}

