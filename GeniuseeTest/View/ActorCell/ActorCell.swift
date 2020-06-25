//
//  ActorCell.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 26.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

class ActorCell: UICollectionViewCell {

    @IBOutlet weak var actorImageView: UIImageView!
    @IBOutlet weak var actorNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        configureCell()
    }

    func configureCell() {
        actorImageView.layer.cornerRadius = actorImageView.bounds.height / 2
    }
    
}
