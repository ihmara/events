//
//  TestExtensions.swift
//  Events
//
//  Created by Igor Hmara on 6/3/21.
//  Copyright © 2021 Soft. All rights reserved.
//

import XCTest

extension XCTestCase {
    func waitForResponse(startTask: (@escaping(Error?) -> Void) -> Void,
                         timeout: TimeInterval = 10,
                         file: StaticString = #file,
                         line: UInt = #line) {
        let expect = expectation(description: "request completed")
        let completion: (Error?) -> Void = { error in
            guard let error = error else {
                return expect.fulfill()
            }
            
            XCTFail("Unexpected error received \(error.localizedDescription)", file: file, line: line)
            expect.fulfill()
        }
        startTask(completion)
        wait(for: [expect], timeout: timeout)
    }
}
