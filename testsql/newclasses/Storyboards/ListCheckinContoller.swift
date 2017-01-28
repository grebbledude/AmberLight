//
//  ListCheckinContoller.swift
//  testsql
//
//  Created by Pete Bennett on 28/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import SQLite

class ListCheckinController: UIViewController, UITableViewDelegate, UITableViewDataSource, ExpandableHeaderDelegate, UIGestureRecognizerDelegate {
    
//    private let tableDate = [["1a", "1b"],["2a","2b","2c"]]
//    private let rowsHeaders = ["head 1","head 2"]
    private var mCheckinGroups: [CheckInController.CheckinGroup]?
    private var mExpanded: [Bool] = []
    private var mDisplayDate: Date?
    private var mPersonID: String?
    public static let DISPLAY_GROUP_PERSON = 0
    public static let DISPLAY_PERSON_HIST = 1
    private var mDisplayType = ListCheckinController.DISPLAY_GROUP_PERSON;
    private var mDBT = DBTables()
    private var mIsTl = false
    public static let CheckInSeque = "checkinSegue"
    public static let QuestionSeque = "questionSegue"
    public static let PanicSeque = "panicSegue"
    private var mCurrentGroup: CheckInController.CheckinGroup?



    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var panicButton: UIBarButtonItem!
    @IBOutlet weak var checkinButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func pressCheckin(_ sender: UIBarButtonItem) {
        if mIsTl {
            if let path = tableView!.indexPathForSelectedRow {
                let data = mCheckinGroups![path.section].children![path.row - 1]
                switchDisplay(currentDisplayType: mDisplayType, childKey: data.id!)
                
            }
            
        }
        else {
            performSegue(withIdentifier: ListCheckinController.CheckInSeque, sender: self)
    
        }
    }
    
    @IBAction func pressPanic(_ sender: UIBarButtonItem) {
        if mIsTl {
            if let path = tableView!.indexPathForSelectedRow {
 /*               let x = mCheckinGroups![path.section]
                let row = path.row - 1
                let y = x.children![row] */
                mCurrentGroup = mCheckinGroups![path.section].children![path.row - 1]
                if mCurrentGroup?.status! == CheckInController.CHECKIN_RED || mCurrentGroup?.status! == CheckInController.CHECKIN_AMBER {
                    performSegue(withIdentifier: ListCheckinController.QuestionSeque, sender: self)
                    // do question stuff.
                }

                
            }
            
        }
        else {
            performSegue(withIdentifier: ListCheckinController.PanicSeque, sender: self)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mIsTl = MyPrefs.getPrefBool(preference: MyPrefs.I_AM_TEAMLEAD)

        let date: Date = Date()
        let cal: Calendar = Calendar(identifier: .gregorian)
        
        mDisplayDate = cal.date(bySettingHour: 18, minute: 0, second: 0, of: date)!.addingTimeInterval(-3600*24)

        mPersonID = MyPrefs.getPrefString(preference: MyPrefs.PERSON_ID);

        display_group()

        tableView.delegate = self
        tableView.dataSource = self
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (mIsTl) {
            panicButton!.title = "Q's"
            checkinButton!.title = "Hist"
        }
        else {
            let startTime = CheckInController.getCalDate(date: MyPrefs.getPrefInt(preference: MyPrefs.STARTDATE))
            if startTime.compare(Date()) == .orderedDescending {  // Not yet got to start date
                panicButton.isEnabled = false
                checkinButton.isEnabled = false
            }
            else {
                let daysDiff = Int(Date().timeIntervalSince(startTime) / (24*3600))
                if daysDiff > 40 {
                    print ("number of days difference + \(daysDiff)")
                    panicButton.isEnabled = false
                    checkinButton.isEnabled = false
                }
                else {
                    let lastCheckDt = MyPrefs.getPrefInt(preference: MyPrefs.LAST_CHECKIN)
                    if lastCheckDt > 0 {
                        let lastCheck = CheckInController.getCalDate(date: lastCheckDt)
                        let lastCheckDiff = Int(Date().timeIntervalSince(lastCheck) / (24*3600))
                        if lastCheckDiff == 0 {
                            checkinButton.isEnabled = false
                        }
                    }
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                mDisplayDate = Calendar.current.date(byAdding: .day, value: -1, to: mDisplayDate!)
                display_group()
                tableView!.reloadData()
            case UISwipeGestureRecognizerDirection.left:
                mDisplayDate = Calendar.current.date(byAdding: .day, value: 1, to: mDisplayDate!)
                display_group()
                tableView!.reloadData()
            default:
                break
            }
        }
    }
    
    // MARK table functions
    func numberOfSections(in tableView: UITableView) -> Int{
        // print("got sections")
        return mCheckinGroups!.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print ("got rows - expnanded \(mExpanded[section]) \(section)")
        return mExpanded[section] ? mCheckinGroups![section].children!.count + 1 : 1
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckinHeader", for: indexPath) as! CheckInHeaderCell
            cell.headerNameLabel.text = mCheckinGroups![indexPath.section].name
            cell.headerStatusLabel.text = mCheckinGroups![indexPath.section].status
            cell.delegate = self
            cell.expanded = mExpanded[indexPath.section]
            cell.section = indexPath.section
            return cell
        }
        let rowNum = indexPath.row - 1
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckinDetail", for: indexPath) as! CheckinDetailCell
        let data = mCheckinGroups![indexPath.section].children![rowNum]
        cell.detailNameLabel.text = data.name
        cell.detailStatusLabel.text = data.status
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didSelectRowAt)
        //cell?.accessoryType = .checkmark
        if didSelectRowAt.row == 0 {
            let expanded = !mExpanded[didSelectRowAt.section]
            mExpanded[didSelectRowAt.section] = expanded
            tableView.reloadSections([didSelectRowAt.section], with: .automatic)
            
        }
        
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt: IndexPath) {
        //let cell = tableView.cellForRow(at: didDeselectRowAt)
        //cell?.accessoryType = .none
        
    }
    
    func sectionHeaderView(expanded: Bool, section: Int) {
        mExpanded [section] = expanded
        print (String(expanded) + "expanded for \(section)")
        tableView.reloadSections([section], with: .automatic)
    }
    

    
    private func display_person(key: String) {
        mCheckinGroups = []
        let checkinTable = CheckInTable.getKey(db: mDBT,id: key);
        let group = checkinTable!.group;
        titleItem!.title = checkinTable!.pseudonym!
        let personid = checkinTable!.personId;
        let checkinTables = CheckInTable.get(db: mDBT,filter: CheckInTable.PERSONID == personid!,orderby: [CheckInTable.DATE])
        let groupCheckinTables = CheckInTable.get(db: mDBT,filter: CheckInTable.GROUP == group!,orderby: [CheckInTable.DATE,CheckInTable.PERSONID])
        var currentpersonPos = checkinTables.count
        var currentGroupPos = groupCheckinTables.count
        var currentItem=0;
        /* We are now all set up to scroll backwards through both lists
        checkintables:  All checkins for this person
        group checkin tables:  All checkins by any members of the group.
        (*/
        while (currentpersonPos > 0) {  // We only stop when we reach the last entry for the person.
            
            var newGroup = CheckInController.CheckinGroup()
            currentpersonPos -= 1                               //  We started 1 more than last entry
            let currPerson = checkinTables[currentpersonPos]
            var groupMembers = 0
            currentGroupPos -= 1
            while (currentGroupPos >= 0  // stop if we reach the end
                && groupCheckinTables[currentGroupPos].date >= currPerson.date) {  // read back until we find an entry for today (or earlier)
                if groupCheckinTables[currentGroupPos].date == currPerson.date { // and count the number of entries for this day
                    groupMembers += 1;
                }
                currentGroupPos -= 1;
            }
            currentGroupPos += 1
            newGroup.name = String(currPerson.date!)
            newGroup.id = currPerson.id
            
            newGroup.status = currPerson.status
            newGroup.groupStatus = groupCheckinTables[currentGroupPos + 1].status
            newGroup.statusDate = currPerson.date
            newGroup.children = []
    /*
     At this point, group members is the total number of entries for this date, including the main group one.
     currentgrouppos is than the group entry, so to start with the group entry we start at 0 and add to currentgrouppos
     */
            for i in 0...(groupMembers - 1) {
                let otherMember = groupCheckinTables[currentGroupPos + i]
                var otherGroup = CheckInController.CheckinGroup()
                if i == 0 {
                    otherGroup.name = "Group: " + otherMember.groupName
                }
                else {
                    otherGroup.name = otherMember.pseudonym
                }
                otherGroup.id = otherMember.id
                otherGroup.status = otherMember.status
                otherGroup.groupStatus = newGroup.groupStatus
                otherGroup.statusDate = otherMember.date!
                newGroup.children?.append( otherGroup)
            }
            mCheckinGroups!.append(newGroup)
            currentItem += 1;
        }
        mExpanded = Array(repeating: false, count: (mCheckinGroups!.count))
    //Log.e("CheckInListActivity","person done "+mCheckinGroups.size());
  /*      FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.hide(getSupportFragmentManager().findFragmentById(R.id.liststatusbuttonfrag));
        ft.commit();
        setTitle (groupName); */
    }
    private func display_group() {
        mCheckinGroups = []
        let displayDate = CheckInController.getDate(date: mDisplayDate!)
        titleItem!.title = String(displayDate)
        let checkInTables = CheckInTable.get(db: mDBT, filter: CheckInTable.DATE == displayDate, orderby: [CheckInTable.GROUP, CheckInTable.PERSONID])
        var groupid: String?
    /*
     If we are a team leader, display for all.  If not, then first entry goes at the top - entry 0.
     */
        if mIsTl     {
            groupid = "Never find this"
        }
        
        else {
            groupid = MyPrefs.getPrefString(preference: MyPrefs.GROUP)
        }
        var currentItem = 0;  //  item 0 will start blank but be overwritten if not team lead
        var currGroup = "";
        var checkinGroup = CheckInController.CheckinGroup();
        var foundThisGroup = false
        if (checkInTables.count > 0) {
            for i in 0...(checkInTables.count - 1) {
                let thisItem = checkInTables[i]
                if thisItem.group != currGroup {
                    if currGroup == groupid {
                        mCheckinGroups![0] =  checkinGroup
                        foundThisGroup = true
                    } else {
                        if ((!mIsTl) || i > 0) { //  if not team lead then add a dummy entry 0
                            mCheckinGroups!.append( checkinGroup)
                            currentItem += 1
                        }
                    }
                    currGroup = thisItem.group;
                    checkinGroup = CheckInController.CheckinGroup();
                    checkinGroup.name = thisItem.groupName;
                    checkinGroup.groupStatus = thisItem.status;
                    checkinGroup.status = thisItem.status;
                    checkinGroup.id = thisItem.id;
                    checkinGroup.statusDate = Int(thisItem.date);
                    checkinGroup.children = []
                } else {
                    var child = CheckInController.CheckinGroup()
                    child.groupStatus = checkinGroup.groupStatus;
                    child.status = thisItem.status;
                    child.statusDate = Int(thisItem.date);
                    child.name = thisItem.pseudonym;
                    child.id = thisItem.id;
                    checkinGroup.children?.append(child)
    
                }
    
            }
            if currGroup == groupid {
                mCheckinGroups?[0] = checkinGroup
                foundThisGroup = true
            } else {
                mCheckinGroups?.append(checkinGroup)
            }
            if (!foundThisGroup) && !mIsTl  {
                mCheckinGroups!.remove(at: 0)
            }
        }
        mExpanded = Array(repeating: false, count: (mCheckinGroups!.count))
        if !mIsTl && (mCheckinGroups?.count)! > 0 {                  // For client, auto expnad my group.
            mExpanded[0] = true
        }

    }
    public func switchDisplay(currentDisplayType: Int, childKey:String) {
    
        if currentDisplayType == ListCheckinController.DISPLAY_GROUP_PERSON {
            display_person(key: childKey)
        }
        else {
            let checkinTable = CheckInTable.getKey(db: mDBT,id: childKey);
            mDisplayDate = CheckInController.getCalDate(date: (checkinTable?.date)!);
            display_group()
  //          mAdapter.switchDisplay((currentDisplayType - 1) * (-1), mCheckinGroups);  //  Code switches 1 to 0 and vice versa
        }
        mDisplayType = (currentDisplayType - 1) * (-1)
        tableView!.reloadData()
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == ListCheckinController.QuestionSeque {
            let target = segue.destination as! QuestionListController
            let checkin = CheckInTable.getKey(db: mDBT, id: mCurrentGroup!.id!)
            let group = GroupTable.getKey(db: mDBT, id: checkin!.group)
            let date = CheckInController.getCalDate(date: mCurrentGroup!.statusDate!)
            let dayno = CheckInController.getDayNo(date: date, startDay: (group?.startdate!)!)
            target.passData(status: "", dayNo: dayno, createMode: false, displayMode: true, displayDate: checkin!.date, personId: checkin!.personId!, delegate: self)
        }
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
    

/*
    private Calendar mDisplayDate;

    
    


}
public void doPanic(View view) {
    startActivity(new Intent(this,PanicActivity.class));
}
public void doCheckin(View view) {
    startActivity(new Intent(this, CheckInActivity.class));
}

public void doNext(View view){
    changeDate(1);
}
public void doPrev(View view){
    changeDate(-1);
}
private void changeDate(int delta) {
    mDisplayDate.add(Calendar.DAY_OF_MONTH,delta);
    display_group();
    mAdapter.notifyDataSetChanged();
}

}



}


    



    

    public View getChildView(int groupPosition, final int childPosition,
    boolean isLastChild, View convertView, ViewGroup parent) {
        final CheckInActivity.CheckinGroup child = (CheckInActivity.CheckinGroup) getChild(groupPosition, childPosition);
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.checkin_child_details, null);
        }
        TextView textView = null;
        textView = (TextView) convertView.findViewById(R.id.txtPerson);
        if (child.id.equals(mPersonID))
        textView.setText(child.name+" (Me)");
        else
        textView.setText(child.name);
        /*        textView = (TextView) convertView.findViewById(R.id.txtStatus);
         setStatus(textView, child.status);
         textView = (TextView) convertView.findViewById(R.id.txtGrStatus);
         setStatus(textView, child.groupStatus);*/
        ImageView imageView = (ImageView) convertView.findViewById(R.id.imgStatus);
        setStatus(imageView, child.status, false);
        imageView = (ImageView) convertView.findViewById(R.id.imgGrStatus);
        setStatus(imageView, child.groupStatus, true);
        
        convertView.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
        ((CheckInListActivity) mActivity).switchDisplay(mDisplayType,child.id);
        }
        });
        return convertView;
    }
    /*private void setStatus(TextView textView,String status){
     textView.setText(status);
     switch (status){
     case ("R"):textView.setBackgroundColor(Color.RED); break;
     case ("A"):textView.setBackgroundColor(Color.YELLOW); break;
     case ("Z"):textView.setBackgroundColor(Color.YELLOW); break;
     case ("G"):textView.setBackgroundColor(Color.GREEN); break;
     case (""):textView.setBackgroundColor(Color.TRANSPARENT); break;
     }
     }*/
 /*   private void setStatus(ImageView imageView,String status, Boolean isGroup){
        int resourceId;
        if (isGroup) {
            switch (status) {
            case CheckInActivity.CHECKIN_RED:
                resourceId = R.drawable.multired;
                break;
            case CheckInActivity.CHECKIN_AMBER:
                resourceId = R.drawable.multiamber;
                break;
            case CheckInActivity.CHECKIN_GREEN:
                resourceId = R.drawable.multigreen;
                break;
            case CheckInActivity.CHECKIN_MISSED:
                resourceId = R.drawable.multiz;
                break;
            default:
                imageView.setVisibility(View.INVISIBLE);
                return;
            }
        }
        else {
            switch (status){
            case CheckInActivity.CHECKIN_RED:
                resourceId = R.drawable.singlered;
                break;
            case CheckInActivity.CHECKIN_AMBER:
                resourceId = R.drawable.singleamber;
                break;
            case CheckInActivity.CHECKIN_GREEN:
                resourceId = R.drawable.singlegreen;
                break;
            case CheckInActivity.CHECKIN_MISSED:
                resourceId = R.drawable.singlez;
                break;
            default:
                imageView.setVisibility(View.INVISIBLE);
                return;
                
            }
            
        }
        imageView.setImageResource(resourceId);
    }*/
 
 
    public View getGroupView(int groupPosition, boolean isExpanded,
    View convertView, ViewGroup parent) {
        if (convertView == null) {
            if (mDisplayType == DISPLAY_PERSON_HIST)
            convertView = mInflater.inflate(R.layout.checkin_person_group, null);
            else
            convertView = mInflater.inflate(R.layout.checkin_group, null);
        }
        CheckInActivity.CheckinGroup group = (CheckInActivity.CheckinGroup) getGroup(groupPosition);
        TextView txtView = (TextView) convertView.findViewById(R.id.txtGroup);
        txtView.setText(group.name);
        ImageView imgView = (ImageView) convertView.findViewById(R.id.imgGrStatus);
        Log.e("CheckinAdapter","Group "+group.id+" status "+group.status + " name "+group.name);
        setStatus(imgView, group.groupStatus, true);
        imgView = (ImageView) convertView.findViewById(R.id.imgStatus);
        if (mDisplayType == DISPLAY_GROUP_PERSON) {
            setStatus(imgView, "", true);
        } else {
            txtView = (TextView) convertView.findViewById(R.id.txtDate);
            txtView.setText(group.statusDate);
            setStatus(imgView, group.status, false);
        }
        return convertView;
        
    }


*/
}
