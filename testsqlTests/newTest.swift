//
//  newTest.swift
//  testsql
//
//  Created by Pete Bennett on 11/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import XCTest


class newTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func getCalDate (date dateInt: Int) -> Date {
        // from an integer to a date object
        //TODO - check this should not set it to 18:00 and subtract dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = Calendar.current.timeZone
        return dateFormatter.date(from: String(dateInt)+"180000")!
    }
    func testCal() {
        let x = getCalDate(date: 20170111)
        print(x)
    }
    
}
