//
//  RandomColorViewController.swift
//  EGPageViewController_Example
//
//  Created by ahenry on 2018/04/11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class RandomColorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: getRandomRGB() / 255.0, green: getRandomRGB() / 255.0, blue: getRandomRGB() / 255.0, alpha: 1.0)
    }

    func getRandomRGB() -> CGFloat {
        return CGFloat(arc4random_uniform(255))
    }
}
