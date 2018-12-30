//
//  InterfaceController.swift
//  KeyRing WatchKit Extension
//
//  Created by Pablo on 28/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    // MARK: Properties
    @IBOutlet weak var addressLabel: WKInterfaceLabel!
    
    var account: Account!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        unarchiveAccount()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    private func unarchiveAccount() {
        do {
            let data = try Data(contentsOf: Account.ArchiveURL)
            print("Data to load: \(data)")
            let account = try NSKeyedUnarchiver.unarchivedObject(ofClass: Account.self, from: data)
            print("Successfully loaded \(account!.xpub) \(account!.derivationIndex)")
            loadAccount(account: account!)
        } catch {
            print("Error info: \(error)")
        }
    }
    
    private func loadAccount(account: Account) {
        self.account = account
    }

}
