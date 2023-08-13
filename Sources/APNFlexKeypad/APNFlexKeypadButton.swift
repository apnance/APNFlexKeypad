//
//  APNFlexKeypadButton.swift
//  Dev - FlexKeyPad
//
//  Created by Aaron Nance on 7/29/23.
//

import UIKit

public typealias KeyDefinition = (title: String,
                                  function: APNFlexKeypadButton.ButtonFunction,
                                  textColor: UIColor,
                                  backgroundColor: UIColor)

public class APNFlexKeypadButton: UIButton {
    
    public enum ButtonFunction {
        
        case accumulator(String), accumulatorPost(String), accumulatorReset,
             accumulatorBackspace, custom(() -> Void)
        
        /// Returns the associated String value of `.accumulator` or `.accumulatorPost`
        func accValue() -> String? {
            switch self {
                    
                case .accumulator(let acc): return acc
                    
                case .accumulatorPost(let acc): return acc
                    
                default: return nil /*NIL*/
                    
            }
        }
        
    }
    
    var function: ButtonFunction!
    var positionedFrame: CGRect!
    
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
        
        layer.cornerRadius  = min(frame.width, frame.height) / 2.0
        
        titleLabel?.font = UIFont(name: "Futura-Bold", size: 20.0)
        titleLabel?.minimumScaleFactor = 0.001
        titleLabel?.adjustsFontSizeToFitWidth = true
        setTitleColor(.systemBlue, for: .normal)
        backgroundColor     = .white
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

/// Renders the UIView's tag value inside itself in Interface Builder.  Useful as placholder views for flexpad buttons.
//@IBDesignable public class TaggedView: UIView {
//    
//    public override func prepareForInterfaceBuilder() {
//        
//        super.prepareForInterfaceBuilder()
//        
//        let label                       = UILabel(frame: bounds)
//        label.text                      = tag.description
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor        = 0.1
//        label.textAlignment             = .center
//        label.textColor                 = .white
//        
//        backgroundColor = .red
//        
//        layer.cornerRadius = frame.width / 2.0
//        
//        clipsToBounds = true
//        
//        addSubview(label)
//        
//    }
//    
//}
