//
//  File.swift
//  
//
//  Created by Aaron Nance on 8/18/23.
//

import Foundation

/// Object used to specify various properties of `APNFlexpad` rendered buttons.
public struct APNFlexKeypadConfigs {
    
    /// Used to uniquely identify the configured flexpad when the delegate is
    /// working with two or more flexpads.
    let id: String
    
    /// Specify the properties for each button.  The key value should map directly
    /// to a corresponding tag value on a placeholder UIView in IB.
    private(set) var keyDefinitions: [ Int: KeyDefinition]
    
    /// Reference to the object that will act as the configured flexpad's delegate.
    weak private(set) var delegate: APNFlexKeypadDelegate?
    
    /// Initialized a new flexpad config object.
    /// - Parameters:
    ///   - id: identifier property intended primarily to distinguish multiple flexpads
    ///   being used by delegate.  This id property is passed in delegate method
    ///   calls and can be used in delegate's method declarations to tailor
    ///   responses on per-flexpad basis.
    ///   - delegate: delegate to be alerted to changes/events.
    ///   - keys: maps key properties to rendered keys
    public init(id: String,
                delegate: APNFlexKeypadDelegate,
                keys: [ Int : KeyDefinition ]) {
        
        self.id             = id
        self.delegate       = delegate
        self.keyDefinitions = keys
        
    }
    
    
    /// Magic numbers!
    struct Defaults {
        
        struct UI {
            
            struct Animation {
                
                static let showDuration = 0.3
                static let hideDuration = 0.3
                
            }
            
        }
        
    }
    
}

