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
            await configureView()
        }
    }
    
    func configureView() async {
        let options = await CacheComposer.shared.options
        memorySwitch.isOn = options.contains(.memory)
        diskSwitch.isOn = options.contains(.disk)
        
        if let memorySize = try? await CacheComposer.shared.memorySize() {
            memoryLabel.text = "Current memory usage: \(sizeStringFrom(memorySize))"
        }
        
        if let diskSize = try? await CacheComposer.shared.diskSize() {
            diskLabel.text = "Current cache folder usage: \(sizeStringFrom(diskSize))"
        }
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
        Task {
            await flipOption(.memory)
        }
    }
    
    @IBAction func didSwitchDiskCache(sender: UISwitch) {
        Task {
            await flipOption(.disk)
        }
    }
    
    @IBAction func didTapClear(sender: UIButton) {
        Task {
            sender.isEnabled = false
            do {
                try await CacheComposer.shared.clear()
            } catch {
                print("Error clearing cache: \(error)")
            }
            sender.isEnabled = true
            await configureView()
        }
    }
    
    private func flipOption(_ option: CacheOptions.Element) async {
        var options = await CacheComposer.shared.options.rawValue
        options = options ^ option.rawValue
        await CacheComposer.shared.updateOptions(CacheOptions(rawValue: options))
        await configureView()
    }
}
