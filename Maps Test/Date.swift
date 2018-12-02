//
//  Date.swift
//  Maps Test
//
//  Created by Carlos Monfort Gómez on 02/12/2018.
//  Copyright © 2018 Carlos Monfort Gómez. All rights reserved.
//

import Foundation

extension Date {
    
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
