//
//  GenerateCodeController.swift
//  testsql
//
//  Created by Pete Bennett on 03/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GenerateCodeController: UIViewController {
    private var mWaiting = false
    @IBOutlet weak var outLabel: UILabel!

    @IBAction func pressCheck(_ sender: UIButton) {
        UIApplication.shared.beginIgnoringInteractionEvents()
//        checkCode(code: "XXXXXY", callback: gotCheckResult)
        let deadlineTime = DispatchTime.now() + .seconds(6)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
//            self.gotCheckResult(.REG_CODE_TIMEOUT)
 //       })
        mWaiting = true
    }
    @IBAction func pressButton(_ sender: UIButton) {
        RegistrationController.generateCode(type:.REG_CODE_TL, callback: gotCode)
      //  RegistrationController.generateCode(type: RegistrationController.REG_CODE_ADMIN, callback: self.gotCode)
    }
    public func gotCode(_ code: String, _ rc: RegCodeType) {
        outLabel!.text = code
        print ("Got a code")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func gotCheckResult(_ type: Int) {
        if mWaiting {
            print (" Got result \(type)")
            mWaiting = false
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        else {
            print ("another result \(type)")
        }
        
    }
    func checkCode(code: String, callback: @escaping (_ code: RegCodeType) -> Void) {
       let FIRDBRef = FIRDatabase.database().reference(withPath: FcmMessage.FirebaseDBKey)
    FIRDBRef.child(code).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary? {

                callback(RegCodeType(rawValue: value![RegistrationController.FIRType] as! Int)!) // Code already exists and tried 5 times
            }
            else {
                callback(.REG_CODE_NOT_FOUND)
            }
            // let type = valueDict?[RegistrationController.FIRType] as? String ?? ""
            // ..
        }) { (error) in
            print(error.localizedDescription)
            callback(.REG_CODE_ERROR)
        }
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
