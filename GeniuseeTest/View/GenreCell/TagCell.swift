//
//  TagCell.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var myLabel: UILabel!
    
    private var margin = CGSize(width: 0, height: 0)
    
    // cell size calculation
    func intrinsicContentSize() -> CGSize {
        var size = myLabel.intrinsicContentSize
        if margin.equalTo(CGSize.zero) {
            for constraint in constraints {
               if constraint.firstAttribute == .leading || constraint.firstAttribute == .trailing {
                    margin.width += constraint.constant + 4
                }
            }
        }
        size.width += margin.width + 4
        
        return CGSize(width: size.width, height: 20)
    }

}
