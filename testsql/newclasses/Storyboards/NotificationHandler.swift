//
//  NotificationHandler.swift
//  testsql
//
//  Created by Pete Bennett on 13/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationHandler {
    static public let DAY = 24 * 3600.0
    public static func setTimer() {
        let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        if (status == MyPrefs.STATUS_ACTIVE  || status == MyPrefs.STATUS_GR_ASSIGN) {
            let startDate = MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE)
            var timeMs = CheckInController.getCalDate(date: startDate).timeIntervalSinceReferenceDate
            let currentTimeMS = Date().timeIntervalSinceReferenceDate
            if timeMs > currentTimeMS {
                let days = Int(min(2,(currentTimeMS - timeMs)/NotificationHandler.DAY))
                timeMs = timeMs - Double(days) * DAY
                scheduleNotification(key: "Soon", title: "Amber Light", body: "First checkin in \(days) days time", at: Date(timeIntervalSinceReferenceDate: timeMs))
            }
            else {
                var days = Int(min(2,(currentTimeMS - timeMs)/NotificationHandler.DAY))
                var hours = Int( (currentTimeMS - timeMs) / 3600) % 24
                let lastCheckinDate = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
                let lastCheck = CheckInController.getCalDate(date: lastCheckinDate).timeIntervalSinceReferenceDate
                var type = "Checkin"
                if (Date().timeIntervalSinceReferenceDate - lastCheck > 12 * 3600.0 || days == 0) {  // next reminder tomorrow
                    if days < 40 {
                        hours = 0
                        days += 1
                    }
                    else {
                        return
                    }
                }
                else {
                    if days < 40  || (days == 40 && hours < 9) {
                        if (hours < 9 && days < 40) {
                            switch hours {
                            case 0-1:   hours = 2
                            case 3:     hours = 4
                            case 4:     hours = 5
                            default:    hours = 9
                                        type = "missed"
                            }
                        }
                        else {
                            hours = 0
                            days += 1
                        }
                    }
                    else {
                        cancelAllNotifications()
                        return
                    }
                    
                }
                timeMs += Double(24 * days) + Double(hours)
                let body = type == "missed" ? " Checkin missed": "Time to check in"
                let title = "Amber Light"
                scheduleNotification(key: "Checkin", title: title, body: body, at: Date(timeIntervalSinceReferenceDate: timeMs))
            }
        
        }
    }
    private static func scheduleNotification (key: String, title: String, body: String, at date: Date) {
        if #available(iOS 10.0, *) {
            scheduleIOS10Notification(key: key, title: title,  body: body, at: date)
        } else {
            // Fallback on earlier versions
            scheduledIOS9Notification(key: key, title: title, body: body, at: date)
        }
    }

    
    
    @available(iOS 10.0, *)
    private static func scheduleIOS10Notification(key: String, title: String, body: String, at date: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [key])
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
       
 //       content.title = NSString.localizedUserNotificationString(forKey: "Hello!", arguments: nil)
 //       content.body = NSString.localizedUserNotificationString(forKey: "Hello_message_body", arguments: nil)
        content.sound = UNNotificationSound.default() // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: key, content: content, trigger: trigger) // Schedule the notification.

        center.add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    private static func scheduledIOS9Notification(key: String,  title: String, body: String, at date: Date) {
        let application = UIApplication.shared
        if let notifications = application.scheduledLocalNotifications {
            for not in notifications {
                if String(describing: not.userInfo!["key"]!) == key {
                    application.cancelLocalNotification(not)
                }
            }
        }
        let notification = UILocalNotification()
        notification.alertTitle = title
        notification.alertBody = body
 //       notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = date
        notification.userInfo = ["key": key] // assign a unique identifier to the notification so that we can retrieve it later
        application.scheduleLocalNotification(notification)
    }
    public static func cancelAllNotifications () {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
            // Fallback on earlier versions
        }
        
    }

}
