//
//  APNFlexKeypad.swift
//  Dev - FlexKeyPad
//
//  Created by Aaron Nance on 7/29/23.
//

import UIKit

public class APNFlexKeypad: UIView {

    // MARK: - Setup
    public private(set) var value = ""
    weak private var delegate: APNFlexKeypadDelegate?
    public private(set) var isShown = true
    private var keyButtons = [APNFlexKeypadButton]()
    
    /// Call `build(withConfigs:)` in viewDidLoad of containing `UIViewController`
    public func build(withConfigs configs: APNFlexKeypadConfigs) {
        
        validate(configs)
        
        delegate = configs.delegate
        let subs = subviews
        
        for view in subs {
            
            if view.tag > 0 {
                
                let key     = configs.keyDefinitions[view.tag]!
                
                let button  = APNFlexKeypadButton(frame: view.frame,
                                                  key: key)
                
                button.addTarget(self, action: #selector(keyPress(sender:)), for: .touchUpInside)
                button.setTitleColor(key.textColor, for: .normal)
                button.backgroundColor = key.backgroundColor
                
                view.removeFromSuperview()
                addSubview(button)
                keyButtons.append(button)
                
            }
            
        }
        
    }
    
    private func validate(_ configs: APNFlexKeypadConfigs) {
        
        var seq1    = Set<Int>(configs.keyDefinitions.keys)
        var seq2    = Set<Int>()
        var d1      = "keys"
        var d2      = "tags"
        
        for view in subviews {
            
            let tag = view.tag
            
            if tag == 0 { continue /*0 is reserved for non-key subviews of APNFlexKeypad*/ }
            
            seq2.insert(tag)
            
        }
        
        assert(!seq1.contains(0),
               """
                configs \(d1.dropLast()) values must be > 0, tags <= 0 are \
                reserved for other subviews that you do not want to be replaced \
                with keys.
                """)
        
        if (seq1 != seq2) {
            
            for _ in 0...1 {
                
                var missingKeys = [Int]()
                
                for num in seq1 {
                    
                    if seq2.contains(num) { continue }
                    missingKeys.append(num)
                    
                }
                
                assert(missingKeys.count == 0,
                       """
                        \(d1) \(missingKeys.sorted().description.dropLast().dropFirst())
                        have no matching \(d2) thus would not appear in FlexKeypad.
                        """)
                
                (seq1,seq2,d1,d2) = (seq2,seq1,d2,d1)
                
            }
            
        }
        
    }
    
    // MARK: - Interact
    /// Accessor function for `value`
    /// - Parameter value: new `String` value for `value` property.
    public func set(value: String) { self.value = value }
    
    /// Called when a button is pressed.
    /// - Parameter sender: reference to the `APNFlexKeypadButton` pressed.
    @objc private func keyPress(sender: APNFlexKeypadButton) {
        
        let backingValue = sender.backingValue
        
        switch sender.function {
                
            case .accumulatorReset:     value = ""
                
            case .accumulatorBackspace: value = String(value.dropLast(1)) /*EXIT*/
                
            case .accumulatorPost:      value += value.count > 0 ? backingValue : ""
                
            case .accumulator:          value += backingValue
                
            case .singleValue:          value = backingValue
                
            case let .custom(function): function()
            
            case .none: break /*BREAK*/
                
        }
        
        delegate?.valueChanged(value)
        
    }
    
    public func show(_ shouldShow: Bool, animated: Bool = false) {
        
        let centered = CGRect(x: frame.width / 2.0, y: frame.height / 2.0,
                              width:0, height:0)
        
        isShown = shouldShow
        
        delegate?.showHideBegin(isShown: shouldShow)
        
        if animated {
            
            UIView.animate(withDuration: 0.2) {
                
                for button in self.keyButtons {
                    
                    button.frame = !shouldShow ? centered : button.positionedFrame!
                    
                }
                
            } completion: { success in
                
                self.delegate?.showHideComplete(isShown: shouldShow)
                
            }
            
        } else {
            
            for button in keyButtons {
                    
                    button.frame = !shouldShow ? centered : button.positionedFrame!
                
            }
            
            isShown = shouldShow
            delegate?.showHideComplete(isShown: shouldShow)
            
        }
        
// TODO: Clean Up - delete
//          public func showHide(animated: Bool = false) {
//
//        let centered = CGRect(x: frame.width / 2.0, y: frame.height / 2.0,
//                              width:0, height:0)
//
//        delegate?.showHideBegin(isShown: isShown)
//
//        if animated {
//
//            UIView.animate(withDuration: 0.2) {
//
//                for button in self.keyButtons {
//
//                    button.frame = self.isShown ? centered : button.positionedFrame!
//
//                }
//
//            } completion: { success in
//
//                self.isShown = !self.isShown
//                self.delegate?.showHideComplete(isShown: self.isShown)
//
//            }
//
//        } else {
//
//            for button in keyButtons {
//
//                    button.frame = isShown ? centered : button.positionedFrame!
//
//            }
//
//            isShown = !isShown
//            delegate?.showHideComplete(isShown: self.isShown)
//
//        }
//
    }
    
}

public protocol APNFlexKeypadDelegate : AnyObject {
    
    func valueChanged(_: String?)
    func showHideComplete(isShown: Bool)
    func showHideBegin(isShown: Bool)
    
}

public struct APNFlexKeypadConfigs {
    
    private(set) var keyDefinitions: [ Int: KeyDefinition]
    
    weak private(set) var delegate: APNFlexKeypadDelegate?
    
    public init(delegate: APNFlexKeypadDelegate,
                keys: [ Int : KeyDefinition ]) {
    
        self.delegate       = delegate
        self.keyDefinitions = keys
        
    }
    
}

///// Object used to specify various properties of `APNFlexpad` rendered buttons.
//public struct APNFlexKeypadConfigs {
//    
//    /// This id
//    let id: String
//    private(set) var keyDefinitions: [ Int: KeyDefinition]
//    weak private(set) var delegate: APNFlexKeypadDelegate?
//    
//    /// Initialized a new flexpad config object.
//    /// - Parameters:
//    ///   - id: property is intended primarily to distinguish multiple flexpads being used by one client.  This id property is passed in delegate method calls and can be used in delegate's method declarations to tailor response on per-flexpad basis.
//    ///   - delegate: delegate to be alerted to changes/events.
//    ///   - keys: maps key properties to rendered keys
//    public init(id: String,
//                delegate: APNFlexKeypadDelegate,
//                keys: [ Int : KeyDefinition ]) {
//    
//        self.id             = id
//        self.delegate       = delegate
//        self.keyDefinitions = keys
//        
//    }
//    
//}
//
