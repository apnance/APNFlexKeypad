//
//  APNFlexKeypadButton.swift
//  Dev - FlexKeyPad
//
//  Created by Aaron Nance on 7/29/23.
//

import UIKit

public class APNFlexKeypadButton: UIButton {
    
    public enum ButtonFunction { case accumulator, accumulatorZero, accumulatorReset,
                                      accumulatorBackspace, custom(() -> Void) }
    
    var function: ButtonFunction!
    var positionedFrame: CGRect!
    
    init(frame:CGRect, function: ButtonFunction) {
        
        super.init(frame: frame)
        
        positionedFrame     = frame
        self.function       = function
        let minDim          = min(frame.width, frame.height)
        
        layer.cornerRadius  = minDim / 2.0
        backgroundColor     = .red
        
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.001
        
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// TODO: Clean Up - APNTaggedView needs to be moved to the project referencing the APNFlexKeypad package.
@IBDesignable public class APNTaggedView: UIView {
    
    public override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        
        let label                       = UILabel(frame: bounds)
        label.text                      = tag.description
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor        = 0.1
        label.textAlignment             = .center
        label.textColor                 = .white
        
        backgroundColor = .red
        
        layer.cornerRadius = frame.width / 2.0
        
        clipsToBounds = true
        
        addSubview(label)
        
    }
    
}
