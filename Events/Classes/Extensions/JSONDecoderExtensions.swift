//
//  JSONDecoderExtensions.swift
//  Events
//
//  Created by Igor Hmara on 6/2/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import Foundation

extension JSONDecoder {
    static var `default`: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = customDateDecodingStrategy
        return decoder
    }()
    
    private static var customDateDecodingStrategy: JSONDecoder.DateDecodingStrategy = {
        return .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = Date.with(iso8601POSIXFormatedDate: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported date format: %@".localizeWithFormat(arguments: dateString))
        })
    }()
}
