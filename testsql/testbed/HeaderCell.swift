//
//  headerCell.swift
//  testsql
//
//  Created by Pete Bennett on 20/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell {
    
    public var section: Int?
    public var expanded = false
    public var delegate: HeaderDelegate?
    private var first = true

    @IBOutlet weak var headerLabel: UILabel!
    @IBAction func pressExpand(_ sender: Any) {
        toggleOpen()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        if first {
//            first = false
//            return
//        }
//        expanded = !expanded
//        self.delegate?.sectionHeaderView(self, expanded: expanded, section: self.section!)
        // Configure the view for the selected state
    }
    func toggleOpen() {
        expanded = !expanded
        self.delegate?.sectionHeaderView(self, expanded: expanded, section: self.section!)
   
    }



}
protocol HeaderDelegate {
    func sectionHeaderView(_ sectionHeaderView: HeaderCell, expanded: Bool, section: Int)
}
