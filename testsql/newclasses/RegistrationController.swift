//
//  RegistrationController.swift
//  testsql
//
//  Created by Pete Bennett on 17/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import FirebaseDatabase


class RegistrationController: UIViewController, DismissalDelegate {
    private static let QUESTION_SEGUE = "regToQuestion"
    private static let LOCK_SEGUE = "regToLock"
    private static let HOLDER_SEGUE = "holderSegue"
    

    private static let SEGUES = [LOCK_SEGUE,QUESTION_SEGUE,LOCK_SEGUE,HOLDER_SEGUE]
    private static let TITLES = ["Create lock code", "Answer questions", "Re-enter lock Code", "Registration complete", "Registration complete"]
    private static let TEXT = ["This lock code will be required in future to unlock this app"
                            , "Answer the questions to set a baseline"
                            , "Re-enter the lock code to complete registration"
                            , "You will be assigned a tesm leader. and a start date  Watch for notifications"
                            , "The system will confirm your code soon and enable extended functionality"]
    
/*    public static let REG_CODE_TIMEOUT = -2
    public static let REG_CODE_ERROR = -1
    public static let REG_CODE_NOT_FOUND = 0
    public static let REG_CODE_TL = 1
    public static let REG_CODE_ADMIN = 2
    public static let REG_CODE_CLIENT = 3
    public static let REG_CODE_CHURCH = 4 */
    weak var actionToEnable : UIAlertAction?
    weak var nameText : UITextField?
    weak var contactText : UITextField?
    private var mFIRDBRef: FIRDatabaseReference?
    private var mWaiting = false
    private var mType = RegCodeType.REG_CODE_NOT_FOUND
    private var mStatus = 0
    private var mName = ""
    private var mContact = ""
    
    public static let STATUS_LOCK1 = 1
    public static let STATUS_QUESTION = 2
    public static let STATUS_LOCK2 = 3
    
    public static let FIRType = "type"

    private var mSwitch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        mFIRDBRef = FIRDatabase.database().reference(withPath: FcmMessage.FirebaseDBKey)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mSwitch {
            self.mStatus += 1
            if mStatus == 1 && (mType == .REG_CODE_TL || mType == .REG_CODE_ADMIN) {
                mStatus = 4
            }
            if mStatus >= 3 {
                let message = FcmMessage.builder(action: .ACT_REGISTER)
                    .addData(key: FcmMessageKey.REG_CODE, data: self.regCode!.text!)
                if mType == .REG_CODE_TL {
                    let _ = message.addData(key: .TL_NAME, data: mName)
                        .addData(key: .TL_CONTACT, data: mContact)
                }
                message.send()
                self.mFIRDBRef?.child(self.regCode.text!).removeValue()
                self.mFIRDBRef = nil

            }
            let alertController = UIAlertController(title: RegistrationController.TITLES[mStatus], message: RegistrationController.TEXT[mStatus], preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                (action : UIAlertAction!) -> Void in

                // self.mSwitch = false
                if self.mStatus >= 3 {
                    self.navigationController!.popViewController(animated: true)
                }
                else {
  //                  if self.mStatus != 2 {
                    self.performSegue(withIdentifier: RegistrationController.SEGUES[self.mStatus], sender: self)
                    }
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }

    }

    public func gotCode(type: RegCodeType) {
        if mWaiting {
            mWaiting = false
            UIApplication.shared.endIgnoringInteractionEvents()
            switch type {
            case .REG_CODE_TIMEOUT: doError()
            case .REG_CODE_ERROR: doError()
            case .REG_CODE_NOT_FOUND:
                let alertController = UIAlertController(title: "Invalid Code", message: "Please check the code you have entered", preferredStyle: .alert)
            
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                })
            
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            case .REG_CODE_TL:
                self.mType = type
                let alert = UIAlertController(title: "Enter contact", message: "Enter name and phone number", preferredStyle: .alert)
                
                //2. Add the text field. You can configure it however you need.
                alert.addTextField(configurationHandler: {(textField: UITextField) in
                    textField.placeholder = "Name"
                    self.nameText = textField
                    textField.addTarget(self, action: #selector(self.textChanged(_ :)), for: .editingChanged)
                })

                alert.addTextField(configurationHandler: {(textField: UITextField) in
                    textField.placeholder = "Contact"
                    self.contactText = textField
                    textField.addTarget(self, action: #selector(self.textChanged(_ :)), for: .editingChanged)
                })
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                let action = (UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    self.mName = alert!.textFields![0].text! // Force unwrapping because we know it exists.
                    self.mContact = alert!.textFields![1].text!
                    MyPrefs.setPref(preference: MyPrefs.TL_NAME, value: self.mName)  // We now have user's name and coontact
                    MyPrefs.setPref(preference: MyPrefs.TL_CONTACT, value: self.mContact)     // save them away for the future                  
                    
                    MyPrefs.setPref(preference: MyPrefs.LOCKCODE, value: "")  // and get the lock code.  Reset to blanks first
                    self.mStatus = 0
                    self.performSegue(withIdentifier: RegistrationController.LOCK_SEGUE, sender: self)
                }))
                alert.addAction(action)
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
            default:
                self.mType = type
                MyPrefs.setPref(preference: MyPrefs.LOCKCODE, value: "")
                mStatus = 0
                performSegue(withIdentifier: RegistrationController.LOCK_SEGUE, sender: self)
                
            }

        }
    }
    func textChanged(_ sender:UITextField) {
        if let name = self.nameText?.text {
            if let contact = self.contactText?.text {
                self.actionToEnable?.isEnabled = (name != ""  && contact == "" )
                return
                
            }
        }
        self.actionToEnable?.isEnabled = false
    }
    public func doError() {
        let alertController = UIAlertController(title: "Cannot check Code", message: "An error occured checking code.  Are you connected to the internet?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
// MARK: outlets and actions
    
    @IBOutlet weak var regCode: UITextField!
    @IBAction func pressValidate(_ sender: UIButton) {
        print(regCode.text!)
        regCode.text = regCode.text?.uppercased()
        if regCode.text!.characters.count > 9 {
            let alertController = UIAlertController(title: "Invalid code", message: "Registration code must be up to 9 characters long?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        else {
            UIApplication.shared.beginIgnoringInteractionEvents()
            mWaiting = true
            let deadlineTime = DispatchTime.now() + .seconds(6)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                self.gotCode(type: .REG_CODE_TIMEOUT)
            })
            self.mFIRDBRef!.child(self.regCode.text!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let valueDict = snapshot.value as? NSDictionary
                let type = RegCodeType(rawValue: valueDict?[RegistrationController.FIRType] as? Int ?? 0)
                // Type is either  TL  Client or Admin
                self.gotCode(type: type!)
                
                // ...
            }) { (error) in
                print(error.localizedDescription)
                self.gotCode(type: .REG_CODE_ERROR)
                return
            }
        }
    }

 
    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? Dismissable
        {
            vc.dismissalDelegate = self
        }
        if segue.identifier == RegistrationController.QUESTION_SEGUE {
            let target = segue.destination as! QuestionListController
            target.passData(status: "", dayNo: 0, createMode: true, displayMode: false, displayDate: 0, personId: "")
        }
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        mSwitch = true
        super.dismiss(animated: flag, completion: completion)
    }
    // MARK: Code generation
    static public func generateCode(type: RegCodeType, callback: @escaping (_ code: String, _ rc: RegCodeType) -> Void) {
        generateCode(type: type, iteration: 1, callback: callback)
    }
    /*
     The first character is numeric - 1-7 for client, 8 for TL and 9 for admin
     Then a number and 2 alphanumeric, then either numeric or alphabetic (for a client)
    */
    static public func generateCode(type: RegCodeType, iteration: Int, callback: @escaping (_ code: String, _ rc: RegCodeType) -> Void) {
        let FIRDBRef = FIRDatabase.database().reference(withPath: FcmMessage.FirebaseDBKey)

        let random = Int(arc4random_uniform(9*31*31))
        var typeChars = ""
        var firstchar = 0
        switch type {
        case .REG_CODE_CLIENT:
            typeChars = MyPrefs.getPrefString(preference: MyPrefs.TL_KEY)
            firstchar = random % 7
        case .REG_CODE_TL:
            let typeSeed = Int(arc4random_uniform(80)+100)
            typeChars = getChar(typeSeed / 9) + getChar(typeSeed % 9)
            firstchar = 8
        case .REG_CODE_ADMIN:
            let typeSeed = Int(arc4random_uniform(89)+100)
            typeChars = getChar(typeSeed / 9) + getChar(typeSeed % 9)
            firstchar = 9
        default:
            print("something gone wrong in generating code")
            return
        }
        var regcode: [String] = []

        regcode.append(getChar(firstchar))
        regcode.append(getChar(random % 10))
        regcode.append(getChar(random / (31*31)))
        regcode.append(getChar((random % 31) / 10))
        let newCode = regcode[0] + regcode[1] + regcode[2] + regcode[3] + typeChars
        FIRDBRef.child(newCode).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let _ = snapshot.value as? NSDictionary? {
                if iteration < 5 {
                    print ("Got duplicate code")
                    generateCode(type: type, iteration: iteration + 1, callback: callback)
                }
                else {
                    callback("", .REG_CODE_ERROR) // Code already exists and tried 5 times
                }
                
            }
            else {
                FIRDBRef.child(newCode).setValue([RegistrationController.FIRType: type.rawValue])
                callback(newCode,type)
            }
            // let type = valueDict?[RegistrationController.FIRType] as? String ?? ""
                // ..
        }) { (error) in
            print(error.localizedDescription)
            callback("",.REG_CODE_ERROR)
        }
    }
    
    
    private static func getChar (_ key: Int) -> String{
        let  str = "123456789ABCDEFGHJKMNPQRSTUVWXYZ"
        let index = str.index(str.startIndex, offsetBy: key)
        return String(str[index])
        
        
    }


}
enum RegCodeType: Int {
    case REG_CODE_TIMEOUT = -2
    case REG_CODE_ERROR = -1
    case REG_CODE_NOT_FOUND = 0
    case REG_CODE_TL = 1
    case REG_CODE_ADMIN = 2
    case REG_CODE_CLIENT = 3
    case REG_CODE_CHURCH = 4
}
