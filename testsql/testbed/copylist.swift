//
//  copylist.swift
//  testsql
//
//  Created by Pete Bennett on 07/01/2017.
//  Copyright © 2017 Pete Bennett. All rights reserved.
//


import UIKit

class copyList: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    
    
    @IBAction func pressAdd(_ sender: UIBarButtonItem) {
        mId = ""
        if mShowGroups {
            performSegue(withIdentifier: ListDataMaintenaceController.GROUP_MAINT, sender: self)
        }
        else {
            performSegue(withIdentifier: ListDataMaintenaceController.PEOPLE_MAINT, sender: self)
        }
    }
    @IBAction func pressEdit(_ sender: UIBarButtonItem) {
        if let row = mSelectedRow {
            if mShowGroups {
                mId = mGroupTables![row].id
                performSegue(withIdentifier: ListDataMaintenaceController.GROUP_MAINT, sender: self)
            }
            else {
                mId = mPersonTables![row].id
                performSegue(withIdentifier: ListDataMaintenaceController.PEOPLE_MAINT, sender: self)
            }
        }
    }
    @IBAction func pressSwitch(_ sender: UIBarButtonItem) {
        mShowGroups = !mShowGroups
        if mShowGroups {
            mPersonTables = nil
            getGroups()
        }
        else {
            mGroupTables = nil
            getPeople()
        }
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var switchButton: UIBarButtonItem!
    @IBOutlet weak var titleBar: UINavigationItem!

    private var mGroupTables: [GroupTable]?
    private var mPersonTables: [PersonTable]?
    private var mShowGroups = true
    private let mDBT = DBTables()
    private var mSelectedRow: Int?
    private var mId = ""
    
    public static let PEOPLE_RETURN = "peopleReturn"
    public static let GROUP_RETURN = "groupReturn"
    public static let GROUP_MAINT = "groupMaint"
    public static let PEOPLE_MAINT = "personMaint"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //       PersonTable.create(db: mDBT)
        //      GroupTable.create(db: mDBT)
        populateGroups()
        if mShowGroups {
            
            getGroups()
        }
        else {
            getPeople()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func getPeople() {
        mPersonTables = nil
        mPersonTables = PersonTable.getAll(db: mDBT)
        print ("Found number of people: \(mPersonTables?.count)")
        titleBar.title = "People"
        switchButton.title = "Groups"
    }
    private func getGroups() {
        mGroupTables = GroupTable.getAll(db: mDBT)
//        titleBar.title = "Groups"
//        switchButton.title = "People"
    }
    
    // MARK: Table View
    func numberOfSections(in tableView: UITableView) -> Int{
        print("got sections")
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print (" Rows in section" + String (mShowGroups ? mGroupTables!.count : mPersonTables!.count))
        
        //        return mShowGroups ? mGroupTables!.count : mPersonTables!.count
        return 90
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
        if mShowGroups {
            let cellIdentifier = "groupCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupTableViewCell
            let group = mGroupTables![indexPath.row]
            cell.id.text = group.id
            cell.name.text = group.desc
            cell.members.text = String(group.members)
            cell.status.text = group.status
            return cell
        }
        else {
            let cellIdentifier = "personCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonTableViewCell
            let person = mPersonTables![indexPath.row]
            cell.id.text = person.id
            cell.name.text = person.name
            cell.pseudonym.text = person.pseudonym
            cell.status.text = person.status
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        mSelectedRow = didSelectRowAt.row
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case ListDataMaintenaceController.GROUP_MAINT:
            let dest = segue.destination as! GroupMaintenanceController
            dest.passData(id: mId)
        case ListDataMaintenaceController.PEOPLE_MAINT:
            let dest = segue.destination as! PeopleMaintenanceController
            dest.passData(id: mId)
        default: break
        }
    }
    @IBAction func unwindToMainListSegue (sender: UIStoryboardSegue) {
        if mShowGroups {
            getGroups()
        }
        else {
            getPeople()
        }
        tableView.reloadData()
    }
    func populateGroups() {
        let group = GroupTable()
        group.id = "123"
        group.desc = "Group Name"
        group.members = 3
        group.status = "W"
        group.startdate = 20161101
        group.insert(db: mDBT)
    }
}
