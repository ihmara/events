//
//  DateFormatterExtensions.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var iso8601POSIXFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }
}
