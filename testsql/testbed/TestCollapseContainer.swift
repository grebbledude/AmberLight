//
//  TestCollapseContainer.swift
//  testsql
//
//  Created by Pete Bennett on 20/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class TestCollapseContainer: UIViewController, UITableViewDelegate, UITableViewDataSource, HeaderDelegate {
    
    private let tableDate = [["1a", "1b"],["2a","2b","2c"]]
    private let rowsHeaders = ["head 1","head 2"]
    var mExpanded = [false,false]

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
  //      tableView.register(UINib(nibName: "Header2CellTableViewCell", bundle: nil), forHeaderFooterViewReuseIdentifier: "Header2CellTableViewCell")

        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        // print("got sections")
        return rowsHeaders.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print ("got rows - expnanded \(mExpanded[section]) \(section)")
        return mExpanded[section] ? tableDate[section].count + 1 : 1

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //print ("getting cell")
        // Table view cells are reused and should be dequeued using a cell identifier.
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = rowsHeaders[indexPath.section]
            cell.delegate = self
            cell.expanded = mExpanded[indexPath.section]
            cell.section = indexPath.section
            return cell
        }
        let rowNum = indexPath.row - 1

        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
        cell.detailLabel.text = tableDate[indexPath.section][rowNum]
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
    
    func sectionHeaderView(_ sectionHeaderView: HeaderCell, expanded: Bool, section: Int) {
        mExpanded [section] = expanded
        print (String(expanded) + "expanded for \(section)")
        tableView.reloadSections([section], with: .automatic)
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        print ("getting header")
//        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header2Cell")
//        //cell.hheaderLabal.text = rowsHeaders[section]
//        return cell

  //  }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60.0
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
