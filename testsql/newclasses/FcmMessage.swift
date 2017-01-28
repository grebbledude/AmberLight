//
//  FcmMessage.swift
//  testsql
//
//  Created by Pete Bennett on 18/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import Foundation
import FirebaseMessaging

class FcmMessage {
    private var mMessage: [String : String]!
    private var mMsgNo: Int?
    private static var mAction: String?

    public static let FirebaseDBKey = "AmberLightTest"
 /*   public  static let ACTION="act"
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
    public  static let TLKEY = "tlkey";
    public static let REG_TYPE = "regtype"
    
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
    public  static let ACT_BECOME_ADMIN = "promadmin";  // you are now TL
    public  static let ACT_NEW_CODE = "newcode";  // new question file to download  */
    
    init() {
        mMessage = [:]
        //mMsgNo = unique number
        //mMessage.setMessageId(String(mMsgNo))
    }
    public static func builder (action: FcmMessageAction) -> FcmMessage {
        mAction = action.rawValue
        return FcmMessage().addData(key: .ACTION, data: action.rawValue)
        
    }
    public func addData (key: FcmMessageKey, data: String) -> FcmMessage {
        mMessage[key.rawValue] = data
        return self
    }
    public func addData (key: FcmMessageKey, data: String, suffix: String) -> FcmMessage {
        mMessage[key.rawValue + suffix] = data
        return self
    }
    public func addData (key: FcmMessageKey, data: Int) -> FcmMessage {
        return addData(key: key, data: String(data))
    }
    public func addData (key: FcmMessageKey, data: Bool) -> FcmMessage {
        return addData(key: key, data: String(data))
    }
    public func send() {
        var msg = MyPrefs.getPrefInt(preference: MyPrefs.MSGNO)
        msg += 1
        MyPrefs.setPref(preference: MyPrefs.MSGNO, value: msg)
        let msgNo = String(msg)
        print ("sending message " + msgNo )
        FIRMessaging.messaging().sendMessage(mMessage!,
                                             to: "93765281376069036739@gcm.googleapis.com",
                                             withMessageID: msgNo,
                                             timeToLive: 24*60*60*3)
    }
}
enum FcmMessageAction: String {
    case ACT_REGISTER = "reg";
    case ACT_ANSWERS = "ans"; // here are the responses to questions
    case ACT_REG_INVALID = "reginv";  // invalid registration attempt
    case ACT_SENDRESPONSE = "send_res";  // send response to questions
    case ACT_BECOME_TEAM_LEAD = "promote";  // you are now TL
    case ACT_REG_OK = "reg_ok";  // registration ok on the server.  Not waiting for TL.
    case ACT_TL_ASSIGN = "tl_ass";  // Assigned to a team leader - you must contact them.
    case ACT_TL_CONFIRMED = "tl_conf";  // TL has confirmed who you are. Now waiting for group.
    case ACT_GROUP_ASSIGN = "gr_ass";  // you a re a member of a group
    case ACT_DAILY_SUMMARY = "day_sum";  // this is the daily summary for group
    case ACT_NEW_UNLOCKCODE = "new_unlock";  // a new unlock code has been sent
    case ACT_CHECKIN = "checkin";  // daily checkin
    case ACT_GROUP = "group";  // group has been updated on server
    case ACT_GROUP_GO = "groupGo";  // group has been published by TL
    case ACT_NEW_PERSON = "new_pers";  // notify TL of a new person
    case ACT_PANIC = "panic";  // from person to server and to team lead
    case ACT_PRAY = "pray";  // telling group members to pray
    case ACT_BOUNCE = "bounce";  // for logging and testing
    case ACT_TEST_SET_ACTIVE = "set_active";  // notify TL of a new person
    case ACT_SETVAR = "setvar";  // debug - set a variable
    case ACT_RUNSQL = "runsql";  // debug - run sql
    case ACT_NEW_QUESTION_FILE = "new_question";  // new question file to download
    case ACT_BECOME_ADMIN = "promadmin";  // you are now TL
    case ACT_NEW_CODE = "newcode";  // new question file to download
    case ACT_ASSIGN_TL = "assTL" // request to assign team leads
    case ACT_FOUND_TL = "foundTL" // Tel admin team lead registered
    case ACT_GET_COUNT = "getCount"  // Get count of outstanding people
    case ACT_RESPOND_COUNT = "respCount" // server responds with number of outstanding people
}
enum FcmMessageKey: String {
    case ACTION = "act"
    case TARGET_PERSONID = "targ_p";
    case TARGET_GROUP = "targ_g";
    case ANSWER = "ans";
    case QUESTION = "quest";
    case STATUS = "status";
    case PSEUDONYM = "p-nym";
    case TEAM_LEADER = "tl";
    case TL_NAME = "tl_name";
    case TL_CONTACT = "tl_contact";
    case REG_CODE = "r-code";
    case GROUP_ID = "gr-id";
    case GROUP_NAME = "gr-name";
    case STARTDATE = "strtdate";
    case TEXT = "text";
    case PERSON_ID = "p_id";
    case PERSON_STATUS = "p_st";
    case DAYNO = "dayno";
    case DATE = "date";
    case NUM_ENTRIES = "num_e";
    case CONGREGATION = "cong";
    case TIMEZONE = "tz";
    case LOCKCODE = "lockc";
    case KEY = "key";
    case TL_PRE_ASSIGNED = "tl_pre";
    case PATH = "path";
    case FILENAME = "filename";
    case VERSION = "version";
    case TLKEY = "tlkey";
    case REG_TYPE = "regtype"
}
