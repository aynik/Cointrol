//
//  ViewController.swift
//  KeyRing
//
//  Created by Pablo on 28/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import UIKit
import BitcoinKit

enum Tags: Int {
    case XPub = 0, DerivationPath, DerivationStart
}

class AccountViewController: UIViewController, UINavigationControllerDelegate {
    // MARK: Properties
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextView: UITextViewPlaceholder!
    @IBOutlet weak var xpubTextView: UITextViewPlaceholder!
    @IBOutlet weak var derivationStartTextView: UITextViewPlaceholder!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    public var account: Account!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        attachCallbacks()
        if let account = account {
            loadAccount(account)
        }
        updateSaveButtonState()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard validateData(alsoName: true) else { return }
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        let name = nameTextView.text!
        let xpub = xpubTextView.text!
        let derivationStart = derivationStartTextView.text!
        let derivationIndex = Int(derivationStart)!
        account = Account(name: name, xpub: xpub, derivationIndex: derivationIndex)
    }
    
    // MARK: Private Methods
    private func updateSaveButtonState() {
        saveButton.isEnabled = validateData(alsoName: true)
    }
    
    private func attachCallbacks() {
        nameTextView.onChange = textViewDidChange
        xpubTextView.onChange = textViewDidChange
        derivationStartTextView.onChange = textViewDidChange
    }
    
    private func loadAccount(_ account: Account) {
        nameTextView.text = account.name
        navigationItem.title = account.name
        xpubTextView.text = account.xpub
        derivationStartTextView.text = String(account.derivationIndex)
        updateAddressLabel()
    }
    
    private func validateName() -> Bool {
        let name = nameTextView.text
        if name!.isEmpty {
            return false
        }
        return true
    }
    
    private func validateXpub() -> Bool {
        let xpub = xpubTextView.text!
        if xpub.isEmpty {
            return false
        }
        let xpubBytes = Base58.decode(xpub) ?? Data([])
        if (xpubBytes.count < 78) {
            return false
        }
        return true
    }
    
    private func validateDerivationStart() -> Bool {
        let derivationStart = derivationStartTextView.text!
        let derivationStartInt = UInt32(derivationStart)
        if derivationStart.isEmpty || derivationStartInt == nil {
            return false
        }
        return true
    }
    
    private func validateData(alsoName: Bool) -> Bool {
        if (alsoName) {
            guard validateName() else { return false }
        }
        guard validateXpub() else { return false }
        guard validateDerivationStart() else { return false }
        return true
    }
    
    private func updateAddressLabel() {
        if !validateData(alsoName: false) {
            saveButton.isEnabled = false
            return
        }
        let xpub = xpubTextView.text!
        let derivationStart = derivationStartTextView.text!
        let derivationIndex = UInt32(derivationStart)
        let decodedData = Base58.decode(xpub)!
        do {
            let depth = decodedData[4]
            let fingerprint = decodedData.subdata(in: 0..<9).withUnsafeBytes {
                (pointer: UnsafePointer<UInt32>) -> UInt32 in
                return pointer.pointee
            }
            let childIndex = decodedData.subdata(in: 9..<13).withUnsafeBytes {
                (pointer: UnsafePointer<UInt32>) -> UInt32 in
                return pointer.pointee
            }
            let chainCode = decodedData.subdata(in: 13..<45)
            let secret = decodedData.subdata(in: 45..<78)
            let hdPublicKey = HDPublicKey(raw: secret, chainCode: chainCode, network: .mainnetBTC, depth: depth, fingerprint: fingerprint, childIndex: childIndex)
            let segwitAddress = try hdPublicKey.derived(at: derivationIndex!).publicKey().toBech32()
            addressTextView.text = segwitAddress.address
            qrCodeImageView.image = segwitAddress.qrImage()
            if validateName() {
                saveButton.isEnabled = true
            }
        } catch {
            print("Error info: \(error)")
            saveButton.isEnabled = false
        }
    }
    
    // MARK: Callback Handlers
    private func textViewDidChange(_ textView: UITextView) {
        if (textView === nameTextView) {
            if validateName() {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        } else {
            updateAddressLabel()
        }
    }
}

