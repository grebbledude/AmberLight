//
//  CheckInController.swift
//  testsql
//
//  Created by Pete Bennett on 17/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class CheckInController: UIViewController {
    public static let QUESTION = "checkQuestions"
    public static let CHECKIN_RED = "R"
    public static let CHECKIN_AMBER = "A"
    public static let CHECKIN_GREEN = "G"
    public static let CHECKIN_INIT = ""
    public static let CHECKIN_MISSED = "Z"
    public static let QUESTION_CHECKIN = "questionCheckin"
    
    private var mStatus: String?
    private let mDBT = DBTables()
    private var mTarget: String = ""
    private static let TARGET_DONE = "done"
    private static let FINISH = "finish"

    @IBAction func pressGreen(_ sender: UIButton) {
        CheckInController.sendCheckinMessage(status: CheckInController.CHECKIN_GREEN, dbt: mDBT)
        checkinComplete()
    }
    @IBAction func pressAmber(_ sender: UIButton) {
        startQuestions(status: CheckInController.CHECKIN_AMBER)
    }
    @IBAction func pressRed(_ sender: UIButton) {
        startQuestions(status: CheckInController.CHECKIN_RED)
    }
    @IBAction func unwindToCheckInSegue (sender: UIStoryboardSegue) {
        if sender.identifier == CheckInController.QUESTION_CHECKIN {
//            mTarget = RegistrationController.QUESTION_SEGUE
            print ("got returning for question")
            
        }
        print("returning segue "+sender.identifier!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        print (mTarget + " in view did appear")
        switch mTarget {
        case CheckInController.TARGET_DONE:
            checkinComplete()
/*            mTarget = CheckInController.FINISH
        case CheckInController.FINISH:
            let _ = self.navigationController?.popViewController(animated: true) */
        default: break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func checkinComplete() {
        let alertController = UIAlertController(title: "Checkin Complete", message: "Great job!  See you tomorrow!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertController: UIAlertAction!) in
            print(" popping?")
            let _ = self.navigationController?.popViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
    private func startQuestions(status: String) {
        mStatus = status
        mTarget = CheckInController.TARGET_DONE
        performSegue(withIdentifier: CheckInController.QUESTION, sender: self)
    }
    // MARK: static functions

    public static func getDayNo(date: Date) -> Int{
//        let startDate = MyPrefs.getPrefFloat(preference: MyPrefs.STARTDATE)  Trying this instead
        let startDate = MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE)
        return getDayNo(date: date, startDay: startDate)
    }
    public static func getDayNo (date: Date, startDay startDateInt: Int ) ->Int{
        if startDateInt == 0 {
            return 0
        }
        var comps = DateComponents()
        comps.day = startDateInt % 100
        comps.month = (startDateInt % 10000)  / 100
        comps.year = startDateInt / 10000
        comps.hour = 18
        comps.minute = 0
        comps.second = 0
        let startDate = Calendar.current.date(from: comps)
        let interval = date.timeIntervalSince(startDate!)
        let days = Int(interval / (60*60*24))
        return days < 0 ? 0 : days + 1
        
    }

    public static func getDate (date: Date) ->Int {
        let cal = Calendar.current
        let hour =  cal.component(.hour, from: date)
        var newDate = cal.date(bySettingHour: 18, minute: 0, second: 0,  of: date)!
        if hour < 18 {
            newDate = cal.date(byAdding: .day, value: -1, to: newDate)!
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.timeZone = cal.timeZone
        let dateString = dateFormatter.string(from: newDate)
        return Int(dateString)!
    }
    public static func  formatDate(date dateInt: Int) -> String {
        // from an int to a usable date format string
        let date = getCalDate(date: dateInt)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = Calendar.current.timeZone
        return dateFormatter.string(from: date)
    }
    public static func  formatDate(timeStamp: Double) -> String {
        // from an int to a usable date format string
        let date = Date(timeIntervalSinceReferenceDate: timeStamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = Calendar.current.timeZone
        return dateFormatter.string(from: date)
    }
    public static func getCalDate (date dateInt: Int) -> Date {
        // from an integer to a date object
        //TODO - check this should not set it to 18:00 and subtract dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.timeZone = Calendar.current.timeZone
        return dateFormatter.date(from: String(dateInt)+"180000")!
    }
    public static func sendCheckinMessage(status: String, dbt: DBTables) {
        //TODO - something seriously missing here!!!
        let personid = MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID)
        let groupid = MyPrefs.getPrefString(preference: MyPrefs.GROUP)
        let teamLead = MyPrefs.getPrefString(preference: MyPrefs.TL)
        let pseudonym = MyPrefs.getPrefString(preference: MyPrefs.PSEUDONYM)
        let dayno = CheckInController.getDayNo(date: Date())
        let response_date = CheckInController.getDate(date: Date())
        FcmMessage.builder(action: .ACT_CHECKIN)
            .addData(key: .DATE, data: response_date)
            .addData(key: .DAYNO, data: dayno)
            .addData(key: .STATUS, data: status)
            .addData(key: .PERSON_ID, data: personid)
            .addData(key: .GROUP_ID, data: groupid)
            .addData(key: .PSEUDONYM, data: pseudonym)
            .addData(key: .TEAM_LEADER, data: teamLead)
            .send()
        if status != CheckInController.CHECKIN_GREEN {
            QuestionListController.sendResponse(dayno: dayno, dbt: dbt)
        }

        MyPrefs.setPref(preference: MyPrefs.LAST_CHECKIN, value: CheckInController.getDate(date: Date()))
        AppDelegate.setupNotifications()
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            switch id {
            case CheckInController.QUESTION:
                let dest = segue.destination as! QuestionListController
                let dayno = CheckInController.getDayNo(date: Date())
                print (" Found dayno of \(dayno)")
                dest.passData( status: mStatus!, dayNo: dayno, createMode: true, displayMode: false, displayDate: 0, personId: "", delegate: self)
            default: break
            }
        }
    }
    public func returnResult(save: Bool) {
        if save {
            mTarget = CheckInController.TARGET_DONE
            print("am returning")
        }
        else {
            mTarget = ""
        }
    }
    public struct CheckinGroup{
        var name: String?
        var id: String?
        var status: String?
        var statusDate: Int?
        var groupStatus: String?
        var children: [CheckinGroup]?
    }
    

}
