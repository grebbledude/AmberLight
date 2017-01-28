//
//  PageNumbrViewController.swift
//  testsql
//
//  Created by Pete Bennett on 11/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit
import Foundation

private var tagAssociationKey: UInt8 = 0
/*
extension UIViewController {
    public var tag1: String! {
        get {
            return objc_getAssociatedObject(self, &tagAssociationKey) as? String
        }
        set(newValue) {
            objc_setAssociatedObject(self, &tagAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
} */
class TagViewController: UIViewController {
    public var tag: String?
}
class PagingViewController: UIViewController {
    public var pageNum: Int?
    
}

protocol ExpandableHeaderDelegate {
    func sectionHeaderView (expanded: Bool, section: Int)
}
protocol DataChangedListener {
    func dataReceived (newData: [String:String])
}
protocol DismissalDelegate : class
{
    func finishedShowing(viewController: UIViewController);
}

protocol Dismissable : class
{
    weak var dismissalDelegate : DismissalDelegate? { get set }
}

extension DismissalDelegate where Self: UIViewController
{
    func finishedShowing(viewController: UIViewController) {
        if    (((viewController as? Dismissable)?.dismissalDelegate = self) != nil)
        {
            print ("dismiss now")
            self.dismiss(animated: true, completion: nil)
            return
        }
        // should never get here
    }
}



