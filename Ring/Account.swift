//
//  Account.swift
//  KeyRing
//
//  Created by Pablo on 28/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import UIKit

class Account: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    // MARK: Properties
    var name: String
    var xpub: String
    var derivationIndex: Int
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("accounts")
    
    // MARK: Property Keys
    struct PropertyKey {
        static let name = "name"
        static let xpub = "xpub"
        static let derivationIndex = "derivationIndex"
    }
    
    // MARK: Initialization
    init(name: String, xpub: String, derivationIndex: Int) {
        self.name = name
        self.xpub = xpub
        self.derivationIndex = derivationIndex
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(of: NSString.self, forKey: PropertyKey.name)! as String
        let xpub = aDecoder.decodeObject(of: NSString.self, forKey: PropertyKey.xpub)! as String
        let derivationIndex = aDecoder.decodeInteger(forKey: PropertyKey.derivationIndex) as Int
        self.init(name: name, xpub: xpub, derivationIndex: derivationIndex)
    }
    
    //MARK: NSSecureCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(xpub, forKey: PropertyKey.xpub)
        aCoder.encode(derivationIndex, forKey: PropertyKey.derivationIndex)
    }
}
