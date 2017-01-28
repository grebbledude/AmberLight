//
//  Test6ViewController.swift
//  testsql
//
//  Created by Pete Bennett on 20/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class Test6ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pressButton(_ sender: UIButton) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "justLabel")
        navigationController?.setViewControllers([vc], animated: true)
        guard navigationController?.popViewController(animated: true) != nil else { //modal
            print("Not a navigation Controller")
            dismiss(animated: true, completion: nil)
            return
        }
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
