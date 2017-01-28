//
//  TestStoryViewController.swift
//  testsql
//
//  Created by Pete Bennett on 15/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class TestStoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var doneLabel: UILabel!
    @IBAction func pressedIt(_ sender: UIButton) {
 //       let storyboard = UIStoryboard(name: "test2", bundle: nil)
 //       let vc = storyboard.instantiateViewController(withIdentifier: "nmyView") as UIViewController
 //       present(vc, animated: true, completion: nil)
        doneLabel.text = "done it"
    }
    @IBAction func unwindToSomewhereSegue (sender: UIStoryboardSegue) {
        print("returning segue")
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
