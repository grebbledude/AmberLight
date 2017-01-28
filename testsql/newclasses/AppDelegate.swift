//
//  AppDelegate.swift
//  testfcm
//
//  Created by Pete Bennett on 24/12/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import UserNotifications

import Firebase
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        // [START register_for_notifications]
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]

        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .firInstanceIDTokenRefresh,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.sendDataMessageFailure),
                                               name: .FIRMessagingSendError,
                                               object: nil)
        
        if let token = FIRInstanceID.instanceID().token() {
            print (token)
        }
        let status = MyPrefs.getPrefString(preference: MyPrefs.CURRENT_STATUS)
        if status == "" {
            MyPrefs.setPref(preference: MyPrefs.CURRENT_STATUS, value: MyPrefs.STATUS_INIT)
            initialiseDB()
        }
        AppDelegate.setupNotifications()
        
  //      print ("This line in for debugging")
  //      let _ = XMLReader(fileName: "questions", db: DBTables())

        
        return true
    }
  //  handle data mand notification essages
    func processDataNotification (dataMessage: [AnyHashable: Any]){
        //  The first test should always be true
        print ("process notification")
        if UIApplication.shared.applicationState == .inactive {
            print ("was inactive")
        }
        if let aps = dataMessage["aps"] as? [AnyHashable: Any] {
            //  This next test would not be true for a striaght notification receive
            // we either will find content or it is an alert.  Technically it is possible to have both,
            // but a notification will trigger again if we click on it.
            
            if let contentAvailable = aps["content-available"] as? String {
                print ("found content \(contentAvailable)")
                if ( contentAvailable == "1" ) {
                    var fcmMessage: [String : String] = [:]
                    for (key,data) in dataMessage {
                        if let keyS = key as? String {
                            if let dataS = data as? String {
                                fcmMessage[keyS] = dataS
                            }
                        }
                    }
                    FCMInbound().processData(payload: fcmMessage)
                    // Process input here
                    if let navController = window?.rootViewController as! UINavigationController? {
                        if let dataReceiver = navController.visibleViewController as? DataChangedListener! {
                            dataReceiver.dataReceived(newData: fcmMessage)
                        }
                    }
                    return
                }
            }
            else {
                // Got a notification message whilst the application was active.  Need to do a pop up.
                if let msg = aps["alert"] as? String {
                    let alertController = UIAlertController(title: "Alert!", message: msg, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    private func initialiseDB() {
        let dbt = DBTables()
        CheckInTable.create(db: dbt)
        PersonTable.create(db: dbt)
        QuestionTable.create(db: dbt)
        ResponseTable.create(db: dbt)
        AnswerTable.create(db: dbt)
        GroupTable.create(db: dbt)
        EventTable.create(db: dbt)
        TeamLeadTable.create(db: dbt)
        
        let _ = XMLReader(fileName: "questions", db: dbt)

        // Do any additional setup after loading the view.
    }
    





    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // This seems to trigger either when the application is foreground or when the user clicks on the notification
        // if the app was in the background
        print ("local notification")
        if application.applicationState == .inactive {
            print ("was inactive")
        }
    }
    @objc func sendDataMessageFailure(_ notification: NSNotification){
        print ("got an error")
        
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("Hooray! I'm registered!")
    }
  
    // [START receive_message]
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("First option Message ID: \(messageID)")
        }
        processDataNotification(dataMessage: userInfo)
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Second option Message ID: \(messageID)")
        }
        processDataNotification(dataMessage: userInfo)
        // Print full message.
        print(userInfo)
        
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    // [END receive_message]
    // [START refresh_token]
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    // [END refresh_token]
    // [START connect_to_fcm]
    func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    // [END connect_to_fcm]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the InstanceID token.
    //    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //        print("APNs token retrieved: \(deviceToken)")
    
    // With swizzling disabled you must set the APNs token here.
    //>>>>>>>>>>>>  Trying this, as others had problems.
    //        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)  // was sandbox and commented out
    //    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        //        let tokenChars1 = UnsafeRawPointer(deviceToken.withUnsafeBytes(<#T##body: (UnsafePointer<ContentType>) throws -> ResultType##(UnsafePointer<ContentType>) throws -> ResultType#>))
        //        var tokenString = ""
        
        //        for i in 0..<deviceToken.count {
        //            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        //        }
        
        //Tricky line
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
        //        print("Device Token:", tokenString)
    }
    
    // [START connect_on_active]
    func applicationDidBecomeActive(_ application: UIApplication) {
        connectToFcm()
    }
    // [END connect_on_active]
    // [START disconnect_from_fcm]
    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }
    // [END disconnect_from_fcm]
    static func setupNotifications() {
        if (MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD)
            || MyPrefs.getPrefBool(preference: MyPrefs.I_AM_ADMIN)) {
            return    // no reminders for admins and team leads
        }
        if #available(iOS 10.0, *) {
            setupNotifications10()  // IOS 10 switches to using the UNUsernotifications
            return
        }
        
        let startDate = MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE)

        if startDate == 0 {
            return
            
        }
        var dayno = CheckInController.getDayNo(date: Date())
        if dayno == 0 {
            return  //  not started yet
        }
        if dayno > 40 {
            UIApplication.shared.cancelAllLocalNotifications()
            return
        }
        let lastCheck = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
        let currentDate = CheckInController.getDate(date: Date())
        if lastCheck == currentDate {
            dayno += 1
        }
        let baseDate = CheckInController.getCalDate(date: startDate)
        let notificationDate = Calendar.current.date(byAdding: .day, value: dayno, to: baseDate)
        
        UIApplication.shared.cancelAllLocalNotifications()
        let triggerTime = notificationDate?.timeIntervalSinceNow
        

        for (offset,key) in [0.0 : "6" , 2.0 : "8" , 4.0 : "10" , 5.0 : "11"] {
            let notification = UILocalNotification()
            notification.alertBody = "Time to checkin for amber light" // text that will be displayed in the notification
            var alarmInterval = triggerTime! + (offset * 3600.0)
            if alarmInterval < 0.0 {
                alarmInterval += 3600.0*24.0
            }
            notification.fireDate = Date(timeIntervalSinceNow: alarmInterval) // twhen notification will be fired)
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["title": "Amber Light Checkin", "UUID": key] // assign a unique identifier to the notification so that we can retrieve it later
            
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Third option Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        processDataNotification(dataMessage: userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Fourth option Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        processDataNotification(dataMessage: userInfo)
        completionHandler()
    }

    static func setupNotifications10() {
        let startDate = MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE)
        if startDate == 0 {
            return
            
        }
        
        let center = UNUserNotificationCenter.current()
        var dayno = CheckInController.getDayNo(date: Date())
        if dayno > 40 {
            center.removePendingNotificationRequests(withIdentifiers: ["6","9","10","11"])
            return
        }
        let lastCheck = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
        let currentDate = CheckInController.getDate(date: Date())
        if lastCheck == currentDate {
            dayno += 1
        }
        let baseDate = CheckInController.getCalDate(date: startDate)
        let notificationDate = Calendar.current.date(byAdding: .day, value: dayno, to: baseDate)
        let content = UNMutableNotificationContent()
        content.title = "Amber Light Checkin"
        content.body = "Time to checkin for amber light"
        content.sound = UNNotificationSound.default()
        let triggerTime = notificationDate?.timeIntervalSinceNow

        for (offset,key) in [0.0 : "6" , 2.0 : "8" , 4.0 : "10" , 5.0 : "11"] {
            var alarmInterval = triggerTime! + (offset * 3600.0)
            if alarmInterval < 0.0 {
                alarmInterval += 3600.0*24.0
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: alarmInterval, repeats: false)
            let request = UNNotificationRequest(identifier: key, content: content, trigger: trigger)
            center.add(request) { (error) in
                print(error!)
            }
        }
    }
}
// [END ios_10_message_handling]
// [START ios_10_data_message_handling]
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print ("IOS 10 option)")
        print(remoteMessage.appData)
    }
}
// [END ios_10_data_message_handling]

