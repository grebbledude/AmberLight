//
//  TargetViewController.swift
//  testsql
//
//  Created by Pete Bennett on 15/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//
import Foundation
import UIKit


class TargetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressBack(_ sender: UIButton) {
        print("returning")
  //      self.navigationController?.popViewController(animated: true)
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
