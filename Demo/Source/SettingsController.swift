//
//  SettingsController.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 16.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit
import YNImageAsync

class SettingsController: UIViewController {
    
    @IBOutlet weak var memorySwitch: UISwitch!
    @IBOutlet weak var diskSwitch: UISwitch!
    @IBOutlet weak var memoryLabel: UILabel!
    @IBOutlet weak var diskLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        let configuration = YNCacheProvider.sharedInstance.configuration
        memorySwitch.isOn = configuration.options.contains(.memory)
        diskSwitch.isOn = configuration.options.contains(.disk)
        memoryLabel.text = "Current memory usage: \(sizeStringFrom(int: YNCacheProvider.sharedInstance.memoryCacheSize()))"
        diskLabel.text = "Current cache folder usage: \(sizeStringFrom(int: YNCacheProvider.sharedInstance.diskCacheSize()))"
    }
    
    func sizeStringFrom(int: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: int, countStyle: .file)
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
    
    @IBAction func didSwitchMemoryCache(sender: UISwitch) {
        var options = YNCacheProvider.sharedInstance.configuration.options.rawValue
        options = options ^ YNCacheOptions.memory.rawValue
        YNCacheProvider.sharedInstance.configuration.options = YNCacheOptions(rawValue: options)
    }
    
    @IBAction func didSwitchDiskCache(sender: UISwitch) {
        var options = YNCacheProvider.sharedInstance.configuration.options.rawValue
        options = options ^ YNCacheOptions.disk.rawValue
        YNCacheProvider.sharedInstance.configuration.options = YNCacheOptions(rawValue: options)
    }
}
