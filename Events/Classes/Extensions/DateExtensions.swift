//
//  DateExtensions.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

extension Date {
    static func with(iso8601POSIXFormatedDate dateString: String) -> Date? {
        return DateFormatter.iso8601POSIXFormatter.date(from: dateString)
    }
    
    func dateFormatter(locale: Locale =  Locale.current) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale  = locale
        return formatter
    }
    
    func string(dateFormat: String, locale: Locale = Locale.current) -> String {
        let dateFormatter = self.dateFormatter(locale: locale)
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    var dateAndTime: String {
        return string(dateFormat: "E, dd MMM yyyy H:mm")
    }
    
    func add(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self) ?? Date()
    }
}
