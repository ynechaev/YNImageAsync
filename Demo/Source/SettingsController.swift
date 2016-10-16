//
//  SettingsController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 16.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapDoneButton(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapLicenceButton(sender: AnyObject) {
        let url = URL(string: "https://raw.githubusercontent.com/RebornSoul/YNImageAsync/master/LICENSE")!
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func didTapGithubButton(sender: AnyObject) {
        let url = URL(string: "https://github.com/RebornSoul/YNImageAsync")!
        UIApplication.shared.openURL(url)
    }
}
