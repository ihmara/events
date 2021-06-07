//
//  StringExtensions.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: .main, comment: "")
    }
    
    func localizeWithFormat(arguments: CVarArg...) -> String {
       return String(format: self.localized, arguments: arguments)
    }
}
