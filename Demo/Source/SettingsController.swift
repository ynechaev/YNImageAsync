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
        Task {
            await setupUI()
        }
    }
    
    func setupUI() async {
//        let configuration = CacheProvider.sharedInstance.configuration
//        memorySwitch.isOn = configuration.options.contains(.memory)
//        diskSwitch.isOn = configuration.options.contains(.disk)
        guard let size = try? await CacheComposer.shared.size() else {
            return
        }
        
        memoryLabel.text = "Current memory usage: \(sizeStringFrom(size))"
        diskLabel.text = "Current cache folder usage: \(sizeStringFrom(size))"
    }
    
    func sizeStringFrom(_ size: UInt64) -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(size), countStyle: .file)
    }
    
    @IBAction func didTapDoneButton(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapLicenceButton(sender: AnyObject) {
        let url = URL(string: "https://raw.githubusercontent.com/ynechaev/YNImageAsync/master/LICENSE")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func didTapGithubButton(sender: AnyObject) {
        let url = URL(string: "https://github.com/ynechaev/YNImageAsync")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func didSwitchMemoryCache(sender: UISwitch) {
//        var options = CacheProvider.sharedInstance.configuration.options.rawValue
//        options = options ^ CacheOptions.memory.rawValue
//        CacheProvider.sharedInstance.configuration.options = CacheOptions(rawValue: options)
    }
    
    @IBAction func didSwitchDiskCache(sender: UISwitch) {
//        var options = CacheProvider.sharedInstance.configuration.options.rawValue
//        options = options ^ CacheOptions.disk.rawValue
//        CacheProvider.sharedInstance.configuration.options = CacheOptions(rawValue: options)
    }
}
