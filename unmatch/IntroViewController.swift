//
//  IntroViewController.swift
//  unmatch
//

import UIKit
import BWWalkthrough

class IntroViewController: BWWalkthroughViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        let introVC1 = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController1")
        let introVC2 = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController2")
        let introVC3 = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController3")
        let introVC4 = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController4")
        
        self.add(viewController: introVC1!)
        self.add(viewController: introVC2!)
        self.add(viewController: introVC3!)
        self.add(viewController: introVC4!)
    }
}

extension IntroViewController: BWWalkthroughViewControllerDelegate {
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        if pageNumber == self.numberOfPages - 1 {
            self.closeButton?.setTitle("DONE", for: .normal)
        } else {
            self.closeButton?.setTitle("SKIP", for: .normal)
        }
    }
    
    func walkthroughCloseButtonPressed() {
        UserDefaults.standard.set(true, forKey: "HasBeenLaunched")
        var viewController = self.storyboard?.instantiateViewController(withIdentifier: "LandingNavVC")
        if Instance.appDel.accessToken.count > 0 {
            viewController = self.storyboard?.instantiateViewController(withIdentifier: "TabVCID")
        }
        guard let window = Instance.appDel.window else {
            return
        }
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 1, options: .transitionFlipFromLeft, animations: {}, completion: nil)
    }
}
