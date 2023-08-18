//
//  File.swift
//  
//
//  Created by Aaron Nance on 8/18/23.
//

import Foundation

/// Object used to specify various properties of `APNFlexpad` rendered buttons.
public struct APNFlexKeypadConfigs {
    
    /// This id
    let id: String
    private(set) var keyDefinitions: [ Int: KeyDefinition]
    weak private(set) var delegate: APNFlexKeypadDelegate?
    
    /// Initialized a new flexpad config object.
    /// - Parameters:
    ///   - id: property is intended primarily to distinguish multiple flexpads being used by one client.  This id property is passed in delegate method calls and can be used in delegate's method declarations to tailor response on per-flexpad basis.
    ///   - delegate: delegate to be alerted to changes/events.
    ///   - keys: maps key properties to rendered keys
    public init(id: String,
                delegate: APNFlexKeypadDelegate,
                keys: [ Int : KeyDefinition ]) {
    
        self.id             = id
        self.delegate       = delegate
        self.keyDefinitions = keys
        
    }
    
}

