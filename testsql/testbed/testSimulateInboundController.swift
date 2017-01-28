//
//  testSimulateInboundController.swift
//  testsql
//
//  Created by Pete Bennett on 26/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class testSimulateInboundController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    public  static let ACTION="act";
    public  static let TARGET_PERSONID="targ_p";
    public  static let TARGET_GROUP="targ_g";
    public  static let ANSWER = "ans";
    public  static let QUESTION = "quest";
    public  static let STATUS = "status";
    public  static let PSEUDONYM = "p-nym";
    public  static let TEAM_LEADER = "tl";
    public  static let TL_NAME = "tl_name";
    public  static let TL_CONTACT = "tl_contact";
    public  static let REG_CODE = "r-code";
    public  static let GROUP_ID = "gr-id";
    public  static let GROUP_NAME = "gr-name";
    public  static let STARTDATE = "strtdate";
    public  static let TEXT = "text";
    public  static let PERSON_ID = "p_id";
    public  static let PERSON_STATUS = "p_st";
    public  static let DAYNO = "dayno";
    public  static let DATE = "date";
    public  static let NUM_ENTRIES = "num_e";
    public  static let CONGREGATION = "cong";
    public  static let TIMEZONE = "tz";
    public  static let LOCKCODE = "lockc";
    public  static let KEY = "key";
    public  static let TL_PRE_ASSIGNED = "tl_pre";
    public  static let PATH = "path";
    public  static let FILENAME = "filename";
    public  static let VERSION = "version";
    
    public  static let ACT_REGISTER = "reg";
    public  static let ACT_ANSWERS = "ans"; // here are the responses to questions
    public  static let ACT_REG_INVALID = "reginv";  // invalid registration attempt
    public  static let ACT_SENDRESPONSE = "send_res";  // send response to questions
    public  static let ACT_BECOME_TEAM_LEAD = "promote";  // you are now TL
    public  static let ACT_REG_OK = "reg_ok";  // registration ok on the server.  Not waiting for TL.
    public  static let ACT_TL_ASSIGN = "tl_ass";  // Assigned to a team leader - you must contact them.
    public  static let ACT_TL_CONFIRMED = "tl_conf";  // TL has confirmed who you are. Now waiting for group.
    public  static let ACT_GROUP_ASSIGN = "gr_ass";  // you a re a member of a group
    public  static let ACT_DAILY_SUMMARY = "day_sum";  // this is the daily summary for group
    public  static let ACT_NEW_UNLOCKCODE = "new_unlock";  // a new unlock code has been sent
    public  static let ACT_CHECKIN = "checkin";  // daily checkin
    public  static let ACT_GROUP = "group";  // group has been updated on server
    public  static let ACT_GROUP_GO = "groupGo";  // group has been published by TL
    public  static let ACT_NEW_PERSON = "new_pers";  // notify TL of a new person
    public  static let ACT_PANIC = "panic";  // from person to server and to team lead
    public  static let ACT_PRAY = "pray";  // telling group members to pray
    public  static let ACT_BOUNCE = "bounce";  // for logging and testing
    public  static let ACT_TEST_SET_ACTIVE = "set_active";  // notify TL of a new person
    public  static let ACT_SETVAR = "setvar";  // debug - set a variable
    public  static let ACT_RUNSQL = "runsql";  // debug - run sql
    public  static let ACT_NEW_QUESTION_FILE = "new_question";  // new question file to download
    
    public static let keys = [
    [ACT_REG_INVALID],
    [ACT_SENDRESPONSE,DAYNO],
    [ACT_BECOME_TEAM_LEAD,PERSON_ID,CONGREGATION,TEAM_LEADER],
    [ACT_REG_OK,PSEUDONYM,PERSON_ID,CONGREGATION],
    [ACT_TL_ASSIGN,TEAM_LEADER,TL_NAME,TL_CONTACT],
    [ACT_TL_CONFIRMED],
    [ACT_GROUP_ASSIGN,GROUP_ID,TIMEZONE,STARTDATE],
    [ACT_DAILY_SUMMARY,GROUP_ID,STATUS, DATE,NUM_ENTRIES,PERSON_ID+"0",PSEUDONYM+"0",STATUS+"0"],
    [ACT_NEW_UNLOCKCODE,LOCKCODE],
    [ACT_GROUP,GROUP_ID,STARTDATE,TEXT,STATUS],
    [ACT_NEW_PERSON,PERSON_ID,PSEUDONYM,REG_CODE],
    [ACT_TEST_SET_ACTIVE],
    [ACT_DAILY_SUMMARY,GROUP_ID,GROUP_NAME, STATUS, DATE,NUM_ENTRIES,PERSON_ID+"0",PSEUDONYM+"0",STATUS+"0",PERSON_ID+"1",PSEUDONYM+"1",STATUS+"1"],
    [ACT_ANSWERS,TEAM_LEADER,DATE,DAYNO,PERSON_ID,NUM_ENTRIES,ANSWER+"0",QUESTION+"0"],
    [ACT_PANIC,PERSON_ID,TEXT],
    [ACT_PRAY,PSEUDONYM]]

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var label1: UITextField!
    @IBOutlet weak var value1: UITextField!
    @IBOutlet weak var label2: UITextField!
    @IBOutlet weak var value2: UITextField!
    @IBOutlet weak var label3: UITextField!
    @IBOutlet weak var value3: UITextField!
    @IBOutlet weak var label4: UITextField!
    @IBOutlet weak var value4: UITextField!
    @IBOutlet weak var label5: UITextField!
    @IBOutlet weak var value5: UITextField!
    @IBOutlet weak var label6: UITextField!
    @IBOutlet weak var vakue6: UITextField!
    @IBOutlet weak var label7: UITextField!
    @IBOutlet weak var value7: UITextField!
    @IBOutlet weak var label8: UITextField!
    @IBOutlet weak var value8: UITextField!
    @IBOutlet weak var label9: UITextField!
    @IBOutlet weak var value9: UITextField!
    private var labels: [UITextField] = []
    private var action: String?
    @IBAction func pressSend(_ sender: UIBarButtonItem) {
        var payload = ["a" : "b"]
        var valid = true
        for i in 0...8 {
            if labels[i].text != "" {
                if values[i].text == "" {
                    valid = false
                }
                else {
                    payload[labels[i].text!] = values[i].text
                }
            }
        }
        if valid {
            let fcm = FCMInbound()
            fcm.processData(payload: payload)
        }
    }
    
    private var values: [UITextField] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        labels = [label1,label2,label3,label4, label5, label6, label7, label8, label9]
        values = [value1,value2,value3,value4,value5,vakue6,value7,value8,value9]
        picker.dataSource = self
        picker.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponents(in: UIPickerView) -> Int{
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent: Int) -> Int {
        return testSimulateInboundController.keys.count
        
    }
    func pickerView(_: UIPickerView, didSelectRow: Int, inComponent: Int) {
        for i in 0...8 {
            labels[i].text = ""
            values[i].text = ""
        }
        let useKeys = testSimulateInboundController.keys[didSelectRow]
        action = useKeys[0]
        if useKeys.count > 1 {
            for i in 1...(useKeys.count - 1) {  // first entry is the key
                labels[i].text = useKeys[i]
            }
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return testSimulateInboundController.keys[row][0]
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
