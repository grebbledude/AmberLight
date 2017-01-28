//
//  IntialiseTablesController.swift
//  testsql
//
//  Created by Pete Bennett on 01/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class IntialiseTablesController: UIViewController {
    private let mDBT = DBTables()
    override func viewDidLoad() {
        super.viewDidLoad()
        let dbt = mDBT
        testData()
        testData1()
        CheckInTable.create(db: dbt)
        PersonTable.create(db: dbt)
        QuestionTable.create(db: dbt)
        ResponseTable.create(db: dbt)
        AnswerTable.create(db: dbt)
        GroupTable.create(db: dbt)
        EventTable.create(db: dbt)
        populate_Checkin(db: dbt)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func populate_Checkin(db dbt: DBTables) {
        var tab = CheckInTable()
        tab.id = "checkin1"
        tab.group = "group"
        tab.groupName = "group name"
        tab.personId = "id1"
        tab.pseudonym = "captain jack"
        tab.status = "R"
        tab.date = 20161130
        tab.insert(db: dbt)
        tab.id = "c21"
        tab.personId = "id2"
        tab.pseudonym = "emperor"
        tab.insert(db: dbt)
    }
    private func testData () {
        let question = QuestionTable()
        question.amberAlert = false
        question.id = "Q1"
        question.multi = true
        question.redAlert = true
        question.initQuestion = true
        question.text = "First question"
        question.insert(db: mDBT)
        question.id = "Q0002"
        question.text = "Second question"
        question.multi = false
        question.insert(db: mDBT)
    }
    private func testData1 () {
        let answer = AnswerTable()
        answer.id = "Q2A001a"
        answer.questionid = "Q0002"
        answer.text = "First text single"
        answer.insert(db: mDBT)
        answer.id = "Q2A002a"
        answer.text = "test 2 - a bit longer so we can see what happens"
        answer.insert(db: mDBT)
        answer.id = "Q2A00ea"
        answer.text = "test 3 - and an even longer and a bit longer so we can see what happens"
        answer.insert(db: mDBT)
        answer.id = "Q2A004a"
        answer.text = "test 4 - this is a really long bitof text so that we can really get to grips with it and a bit longer so we can see what happens"
        answer.insert(db: mDBT)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
