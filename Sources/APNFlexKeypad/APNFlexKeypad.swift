//
//  APNFlexKeypad.swift
//  Dev - FlexKeyPad
//
//  Created by Aaron Nance on 7/29/23.
//

import UIKit

/// Entry point is build(withConfigs: buttonStyler:))
public class APNFlexKeypad: UIView {
    
    // MARK: - Setup
    weak private var delegate: APNFlexKeypadDelegate?
    public private(set) var id      = "Unspecified"
    public private(set) var value   = ""
    public private(set) var isShown = true
    private var keyButtons          = [APNFlexKeypadButton]()
    
    /// Call `build(withConfigs:)` in viewDidLoad of containing `UIViewController`
    /// - Parameters:
    ///   - configs: `APNFlexKeypadConfig` object that specifies how to build each key in the keypad.
    ///   - buttonStyler: `(UIView) -> ()` closure to call on each button for styling purposes
    public func build(withConfigs configs: APNFlexKeypadConfigs,
                      buttonStyler: ((UIView) -> ())? = nil) {
        
        validate(configs)
        
        id = configs.id
        
        delegate = configs.delegate
        let subs = subviews
        
        for view in subs {
            
            if view.tag > 0 {
                
                let key     = configs.keyDefinitions[view.tag]!
                
                let button  = APNFlexKeypadButton(frame: view.frame,
                                                  key: key)
                
                button.addTarget(self, 
                                 action: #selector(keyPress(sender:)),
                                 for: .touchUpInside)
                button.setTitleColor(key.textColor, for: .normal)
                buttonStyler?(button)
                
                view.removeFromSuperview()
                addSubview(button)
                keyButtons.append(button)
                
            }
            
        }
        
    }
    
    /// Reconciles tags that should have buttons against button definitions in configs.
    /// - Parameter configs: config object controlling rendered button properties.
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
    
    // MARK: - Interaction
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
        
        haptic(for: sender)
        
        delegate?.valueChanged(value, forID: id)
        
    }
    
    /// Sets `backgroundColor` to `normal` for all `keyButtons` except `keyButton` with index of `buttonNum`
    ///
    /// - note: this  is useful for creating custom radio button controls and other custom control types.
    public func highlight(buttonNum: Int) {
        
        DispatchQueue.main.async {
            
            for (num, button) in self.keyButtons.enumerated() {
                
                button.backgroundColor  =   (num == buttonNum)
                                            ? button.bgColors.highlighted
                                            : button.bgColors.normal
                
            }
            
        }
        
    }
    
    /// Shows or hides just the buttons of the keypad.
    public func hideButtons(_ shouldHide: Bool) {
        
        keyButtons.forEach { $0.isHidden = shouldHide }
        
    }
    
    /// Shows or hides flexpad with or without animation.
    /// - Parameters:
    ///   - shouldShow: flag specifying whether to show or hide control.
    ///   - animated: flag determining whether control is shown/hidden with animtion.
    public func show(_ shouldShow: Bool, animated: Bool = false) {
        
        isShown = shouldShow
        delegate?.showHideBegin(forID: id, isShown: shouldShow)
        
        if animated {
            
            UIView.animate(withDuration: (shouldShow
                                          ? APNFlexKeypadConfigs.Defaults.UI.Animation.showDuration
                                          : APNFlexKeypadConfigs.Defaults.UI.Animation.hideDuration)) {
                
                self.alpha = shouldShow ? 1.0 : 0.0
                
                for button in self.keyButtons {
                    
                    let centered = CGPoint(x: (self.frame.width / 2.0)  - (button.frame.width / 2.0),
                                           y: (self.frame.height / 2.0) - (button.frame.height / 2.0))
                    
                    button.frame = !shouldShow ? CGRect(origin: centered, size: button.positionedFrame.size) : button.positionedFrame!
                    button.alpha = shouldShow ? 1.0 : 0.0
                    
                }
                
            } completion: { success in
                
                self.delegate?.showHideComplete(forID: self.id, isShown: shouldShow, animated: true)
                
            }
            
        } else {
            
            for button in keyButtons {
                
                let centered = CGPoint(x: (frame.width / 2.0)  - (button.frame.width / 2.0),
                                       y: (frame.height / 2.0) - (button.frame.height / 2.0))
                
                button.frame = !shouldShow ? CGRect(origin: centered, size: button.positionedFrame.size) : button.positionedFrame!
                button.alpha = shouldShow ? 1.0 : 0.0
                
            }
            
            alpha   = isShown ? 1.0 : 0.0
            delegate?.showHideComplete(forID: id, isShown: shouldShow, animated: false)
            
        }
        
    }
    
    /// Triggers a haptic response with default style of .light
    /// - note: This is captured version of APNUTils.Globals.haptic()
    private func haptic(for button: APNFlexKeypadButton) {
        
        if let hapticStyle = button.hapticStyle {
            UIImpactFeedbackGenerator(style: hapticStyle).impactOccurred()
        }
    }
    
}

/// Delegate
public protocol APNFlexKeypadDelegate : AnyObject {
    
    /// Method called on delegate when the flexpad's underlying value changes.
    /// - Parameters:
    ///   - _: new `String` value of underlying `value` property.
    ///   - forID: id of the flexpad calling this method. Useful if flexpad's delegate has two or more flexpads.
    func valueChanged(_: String?, forID: String)
    
    /// Called before the flexpad begins to show or hide itself.
    /// - Parameters:
    ///   - forID: id of the flexpad calling this method. Useful if flexpad's delegate has two or more flexpads.
    ///   - isShown: flag indicating whether the flexpad is being shown(true) or hidden(false).
    func showHideBegin(forID: String, isShown: Bool)
    
    /// Called after flexpad has finished showing/hiding  itself.
    /// - Parameters:
    ///   - forID: id of the flexpad calling this method. Useful if flexpad's delegate has two or more flexpads.
    ///   - isShown: flag indicating whether the flexpad was shown(true) or hidden(false).
    ///   - animated: flag indicating if the control was shown/hidden in an animated fashion.
    func showHideComplete(forID: String, isShown: Bool, animated: Bool)
    
}
