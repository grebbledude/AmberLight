//
//  testsqlTests.swift
//  testsqlTests
//
//  Created by Pete Bennett on 30/10/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import XCTest
@testable import testsql
import SQLite
import FirebaseCore


class testsqlTests: XCTestCase {
    
    

 /*   func testCreate() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        testTable.create(db: db)
        
    }
    func testInsert(){
        let path = NSSearchPathForDirectoriesInDomains(
         .documentDirectory, .userDomainMask, true
         ).first!
         
         let db = try! Connection("\(path)/db.sqlite3")
        let tt = testTable()
        tt.age = 5
        tt.id = "pete2"
        tt.email = "pete@somewhere"
        print(tt.insert(db: db))
        tt.id = "pete3"
        tt.email = "pete@somewhere"
        print(tt.insert(db: db))
    }
    func testGetAll(){
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        let tt = testTable.getAll(db: db)
        print (tt[0].id)
        print (tt[1].id)
        
    }
    func testGet () {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        let tt = testTable.get(db: db,
                               filter: (testTable.ID != "1") && testTable.EMAIL != "x")
        print (tt[0].id)
        print (tt[1].id)
    }
    func testGetOrder () {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        let db = try! Connection("\(path)/db.sqlite3")
        let tt = testTable.get(db: db,
                               filter: (testTable.ID != "1") && testTable.EMAIL != "x",
            orderby: [testTable.ID.desc])
        print (tt[0].id)
        print (tt[1].id)
    }
    func testXML() {
        let file = "/Users/petebennett/Documents/questions3.xml"
        let _ = ReadQuestions(file: file)
    } */
    func testPrefs() {
        MyPrefs.setPref(preference: "test", value:  "testvalue")
        print(MyPrefs.getPrefString(preference: "test"))
        MyPrefs.setPref(preference: "test1", valueInt:  3)
        print(MyPrefs.getPrefInt(preference: "test1"))
        MyPrefs.setPref(preference: "test2", valueBool: true)
        print(MyPrefs.getPrefBool(preference: "test2"))    }
    func testCal() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = Calendar.current.timeZone
        let x =  dateFormatter.date(from: String(dateInt*1000000)+"180000")!
        print(x)
    }
    
}
