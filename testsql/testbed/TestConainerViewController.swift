//
//  TestConainerViewController.swift
//  testsql
//
//  Created by Pete Bennett on 19/11/2016.
//  Copyright © 2016 Pete Bennett. All rights reserved.
//

import UIKit

class TestConainerViewController: UIViewController, UIPageViewControllerDelegate
, UIPageViewControllerDataSource {
    private var mPageCount: Int? = 3
    private var mPages: [PagingViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var myContainer: UIView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pagingView  = viewController as! PagingViewController
        print ("after for \(pagingView.pageNum)")
        if pagingView.pageNum! <= 0 {
            return nil
        }
        return getControllerAt(pagingView.pageNum! - 1)
        
    }
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let pagingView  = viewController as! PagingViewController
        print ("before for \(pagingView.pageNum)")
        if pagingView.pageNum! + 1 >= mPageCount! {
            return nil
        }
        return getControllerAt(pagingView.pageNum! + 1)
    }
    private func setControllerAt(_ index: Int) -> PagingViewController{
        print(index)
        let page = (self.storyboard?.instantiateViewController(withIdentifier: "pageController1"))! as! PagingViewController
        page.pageNum = index
        return page
    }
    private func getControllerAt(_ index: Int) -> UIViewController{
        if index >= mPages.count {
            mPages.append(setControllerAt(index))
            let page = mPages[index] as! TestPageController
            page.passData(label: String(index))
        }
        return mPages[index]
    }
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "testPage" {
            let pageView = segue.destination as! UIPageViewController
            pageView.delegate = self
            pageView.dataSource = self
            let _ = getControllerAt(0)
            pageView.setViewControllers(mPages, direction: .forward, animated: true, completion: nil)
            print("set up pageView")
        }
    }
    @IBAction func unwindToTestSegue (sender: UIStoryboardSegue) {

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
