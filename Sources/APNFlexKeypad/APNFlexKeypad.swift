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
    private var isShown = true
    private var keyButtons = [APNFlexKeypadButton]()
    
    /// Call `build(withConfigs:)` in viewDidLoad of containing `UIViewController`
    public func build(withConfigs configs: APNFlexKeypadConfigs, completion: (() -> ())? = nil) {
        
        validate(configs)
        
        delegate = configs.delegate
        let subs = subviews
        
        for view in subs {
            
            if view.tag > 0 {
                
                let key     = configs.keyDefinitions[view.tag]!
                
                let button  = APNFlexKeypadButton(frame: view.frame,
                                                 function: key.function)
                
                button.setTitle(key.title, for: .normal)
                button.addTarget(self, action: #selector(keyPress(sender:)), for: .touchUpInside)
                
                view.removeFromSuperview()
                
                addSubview(button)
                keyButtons.append(button)
                
            }
            
        }
        
        completion?()
        
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
        
        let title = sender.title(for: .normal)!
        
        switch sender.function {
                
            case .accumulatorReset:     value = ""
                
            case .accumulatorBackspace: value = String(value.dropLast(1)) /*EXIT*/
                
            case .accumulatorZero:      value += value.count > 0 ? title : ""
                
            case .accumulator:          value += title
                
            case let .custom(function): function()
            
            case .none: break /*BREAK*/
                
        }
        
        delegate?.valueChanged(value)
        
    }
    
    public func showHide() {
        
        let centered = CGRect(x: frame.width / 2.0, y: frame.height / 2.0,
                              width:0, height:0)
            
        UIView.animate(withDuration: 0.4) {
            
            for button in self.keyButtons {
                
                button.frame = self.isShown ? centered : button.positionedFrame!
                
            }
            
        } completion: { success in
            
            self.delegate?.showHideComplete(isShown: self.isShown)
            
        }
        
        isShown = !isShown
        
    }
    
}

public protocol APNFlexKeypadDelegate : AnyObject {
    
    func valueChanged(_: String?)
    func showHideComplete(isShown: Bool)
    
}

public struct APNFlexKeypadConfigs {
    
    private(set) var keyDefinitions: [ Int: (title: String,
                                             function: APNFlexKeypadButton.ButtonFunction)]
    weak private(set) var delegate: APNFlexKeypadDelegate?
    
    public init(delegate: APNFlexKeypadDelegate,
                keys: [ Int: (title: String, function: APNFlexKeypadButton.ButtonFunction)]) {
        
        self.delegate       = delegate
        self.keyDefinitions = keys
        
    }
    
}

