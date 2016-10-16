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
        let options = YNImageCacheProvider.sharedInstance.cacheOptions
        memorySwitch.isOn = options.contains(.memory)
        diskSwitch.isOn = options.contains(.disk)
        memoryLabel.text = "Current memory usage: \(sizeStringFrom(int: YNImageCacheProvider.sharedInstance.memoryCacheSize()))"
        diskLabel.text = "Current cache folder usage: \(sizeStringFrom(int: YNImageCacheProvider.sharedInstance.diskCacheSize()))"
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
        var options = YNImageCacheProvider.sharedInstance.cacheOptions.rawValue
        options = options ^ YNCacheOptions.memory.rawValue
        YNImageCacheProvider.sharedInstance.cacheOptions = YNCacheOptions(rawValue: options)
    }
    
    @IBAction func didSwitchDiskCache(sender: UISwitch) {
        var options = YNImageCacheProvider.sharedInstance.cacheOptions.rawValue
        options = options ^ YNCacheOptions.disk.rawValue
        YNImageCacheProvider.sharedInstance.cacheOptions = YNCacheOptions(rawValue: options)
    }
}
