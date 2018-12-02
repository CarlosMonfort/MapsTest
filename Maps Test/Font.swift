//
//  Font.swift
//  Maps Test
//
//  Created by Carlos Monfort Gómez on 02/12/2018.
//  Copyright © 2018 Carlos Monfort Gómez. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
}
