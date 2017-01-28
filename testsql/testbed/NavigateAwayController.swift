//
//  NavigateAwayController.swift
//  testsql
//
//  Created by Pete Bennett on 19/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class NavigateAwayController: UIViewController {
    
    private var mTarget = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        switch mTarget {
            case "toPage": performSegue(withIdentifier: "toPage", sender: self)
            default:break
        }
        super.viewDidAppear(animated)
    }
    @IBAction func nextButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "navTarget")

        navigationController?.pushViewController(vc!,
                                                 animated: true)
    }
    @IBAction func unwindToNavigateSegue (sender: UIStoryboardSegue) {
        mTarget = "toPage"
        
        //   print("returning segue "+sender.identifier!)
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
