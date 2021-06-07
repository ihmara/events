//
//  NSObjectExtensions.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
