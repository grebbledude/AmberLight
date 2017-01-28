//
//  TeamLeadController.swift
//  testsql
//
//  Created by Pete Bennett on 03/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//

import UIKit

class TeamLeadController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var mTLs: [TeamLeadTable]?
    private let mDBT = DBTables()
    private var mName: String?
    private var mWaiting = false
    private var mWaitingCount = 0

    @IBAction func pressAdd(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Add New Name", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            self.mName = (alertController.textFields![0] as UITextField).text! as String
            if self.mName!.characters.count > 0 {
                RegistrationController.generateCode(type: .REG_CODE_TL, callback: self.gotCode)
                UIApplication.shared.beginIgnoringInteractionEvents()
                let deadlineTime = DispatchTime.now() + .seconds(6)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                    self.gotCode("", .REG_CODE_TIMEOUT)
                })
                self.mWaiting = true
            }

        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Name"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func pressAssign(_ sender: UIBarButtonItem) {
        let row = mWaitingCount == 0 ? 0 : picker.selectedRow(inComponent: 0)+1
        if row > 0 {
            if let tlrow = tableView.indexPathForSelectedRow?.row {
                let tl = mTLs![tlrow]
                if tl.code == "" {
                    FcmMessage.builder(action: .ACT_ASSIGN_TL)
                        .addData(key: .NUM_ENTRIES, data: row)
                        .addData(key: .TEAM_LEADER, data: tl.id)
                        .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
                        .send()
                }
            }
        }
    }
    @IBAction func pressTL(_ sender: UIBarButtonItem) {
    }
    @IBOutlet weak var numEntriesLabel: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        mTLs = TeamLeadTable.getAll(db: mDBT)
        tableView.delegate = self
        tableView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        mWaitingCount = MyPrefs.getPrefInt(preference: MyPrefs.NUM_PEOPLE)
        numEntriesLabel!.text = String(mWaitingCount)
        let time = Double(MyPrefs.getPrefFloat(preference: MyPrefs.NUM_PEOPLE_TS))
        if time > 0 {
            let date = Date(timeIntervalSinceReferenceDate: time)
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
        
            dateLabel!.text = formatter.string(from: date)
            picker.dataSource = self
            picker.delegate = self
        }
    }
    public func gotCode(_ code: String, _ rc: RegCodeType) {
        if mWaiting {
            if rc.rawValue > 0 {
                print (" Got result \(rc)")
                mWaiting = false
                let tl = TeamLeadTable()
                tl.name = mName!
                tl.code = code
                var max = 0
                for tl in mTLs! {
                    if Int(tl.id)! > max {
                        max = Int(tl.id)!
                    }
                }
                max += 1
                tl.id = String(max)
                let _ = tl.insert(db: mDBT)
                UIApplication.shared.endIgnoringInteractionEvents()
                FcmMessage.builder(action: .ACT_NEW_CODE)
                    .addData(key: .REG_CODE, data: code)
                    .addData(key: .CONGREGATION, data: MyPrefs.getPrefString(preference: MyPrefs.CONGREGATION))
                    .addData(key: .REG_TYPE, data: RegCodeType.REG_CODE_TL.rawValue)
                    .addData(key: .TEAM_LEADER, data: "none")
                    .send()
                mTLs!.append(tl)
                tableView!.reloadData()
            }
            else {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.mWaiting = false
                let alertController = UIAlertController(title: "Cannot get new code", message: "An error occured getting a new code.  Are you connected to the internet?", preferredStyle: .alert)
                

                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                    (action : UIAlertAction!) -> Void in
                    
                })
                
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else {
            print ("another result \(rc)")
        }
    }
    
    // MARK: Table stuff
    func numberOfSections(in tableView: UITableView) -> Int{
        // print("got sections")
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mTLs!.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
                // Never fails:
                return UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
            }
            return cell
        }()
        cell.textLabel?.text = mTLs![indexPath.row].name
        cell.detailTextLabel?.text = "Code: " + mTLs![indexPath.row].code
        return cell

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        // xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        // need to handle delete
        
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        
    }
// MARK: Picker stuff
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ _pickerView: UIPickerView,numberOfRowsInComponent component: Int
        ) -> Int {
        return mWaitingCount == 0 ? 1 : mWaitingCount

    }
    func pickerView(_ _pickerView: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
        return mWaitingCount == 0 ? "0" : String(row + 1)
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

class TeamLeadCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    // MARK: Properties
    @IBOutlet weak var tlNameTxt: UILabel!
    @IBOutlet weak var tlCodeTxt: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBAction func pressDelete(_ sender: UIButton) {
    }


    
}
