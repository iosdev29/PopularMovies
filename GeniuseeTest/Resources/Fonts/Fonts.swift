//
//  Fonts.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

extension UIFont {
    
    enum Nunito: String {
        case regular = "Nunito-Regular"
        case light = "Nunito-ExtraLight"
    }
    
    static func nunitoFont(_ style: Nunito, ofSize: CGFloat) -> UIFont {
        let font = UIFont(name: style.rawValue, size: ofSize)
        return font ?? UIFont.systemFont(ofSize: ofSize)
    }
    
}
