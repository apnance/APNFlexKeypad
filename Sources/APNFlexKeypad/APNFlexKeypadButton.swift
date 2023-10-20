//
//  APNFlexKeypadButton.swift
//  Dev - FlexKeyPad
//
//  Created by Aaron Nance on 7/29/23.
//

import UIKit

public typealias KeyDefinition = (title: String,
                                  function: APNFlexKeypadButton.ButtonFunction,
                                  colors: (tx: UIColor, bg: UIColor, hi: UIColor),
                                  font: UIFont?,
                                  hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle?)

public class APNFlexKeypadButton: UIButton {
    
    /// Enum specifying the purpose and therefore behavior of an APNFlexKeypadButton.
    /// 
    /// # Example #
    /// ```swift
    /// .singleValue            // overwrites any stored or accumulated or previous singleValue.
    /// .accumulator            // button's cause their values to accumulate or be concatentated.
    /// .accumulatorPost        // buttons are a subset of accumulators that only accumulate their value if there is an existing value.
    /// .accumulatorReset       // buttons clear all accumulated or singleValue values.
    /// .accumulatorBackspace   // removes the last accumulated character.
    /// .custom                 // buttons take a () -> () closure to be called when the button is tapped.
    /// ```
    public enum ButtonFunction {
        
        case singleValue(String), accumulator(String), accumulatorPost(String), accumulatorReset,
             accumulatorBackspace, custom(() -> Void)
        
        /// Returns the associated String value of `.accumulator` or `.accumulatorPost`
        func accValue() -> String? {
            switch self {
                    
                case .accumulator(let acc):     return acc
                    
                case .accumulatorPost(let acc): return acc
                    
                case .singleValue(let val):     return val
                    
                default:                        return nil /*NIL*/
                    
            }
            
        }
        
    }
    
    private(set) var function: ButtonFunction!
    private(set) var positionedFrame: CGRect!
    private(set) var hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle?
    private(set) var bgColors:(normal:UIColor, highlighted:UIColor) = (.red, .green)
    private(set) var backingValue = ""
    
    init(frame:CGRect, key: KeyDefinition) {
        
        super.init(frame: frame)
        
        if let image = UIImage(named: key.title) {
            
            self.setImage(image, for: .normal)
            
        } else {
            
            setTitle(key.title, for: .normal)
            
        }
        
        positionedFrame     = frame
        function            = key.function
        backingValue        = function.accValue() ?? backingValue
        hapticStyle         = key.hapticStyle
        bgColors            = (key.colors.bg, key.colors.hi)
        
        layer.cornerRadius  = min(frame.width, frame.height) / 2.0
        
        titleLabel?.minimumScaleFactor = 0.001
        titleLabel?.adjustsFontSizeToFitWidth = true
        setTitleColor(.systemBlue, for: .normal)
        backgroundColor     = bgColors.normal
        
    }
    
    public override var isHighlighted: Bool {
        
        didSet {
            
            backgroundColor =   isHighlighted
                                ? bgColors.highlighted
                                : bgColors.normal
            
        }
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}
