# APNFlexKeypad

This package is meant to be a customizable replacement for Apple's built-in keypad for entering numeric data in a UITextField.

With this package the user defines the button display text, behavior(e.g. acts like a standard button on a keypad or triggers a custom method), and a custom layout for the buttons using placeholder UIViews in Interface Builder.

Use:

    APNFlexKeypad & APNFlexKeypadButton
    1. Add a UIView to storyboard.  Change its type to APNFlexKeypad.
    2. Add/size UIViews as subviews to the APNFlexKeypad, placing them where you want your keypad buttons to be.
    3. Set these UIViews' tags to numbers > 0.  The tag value will correspond to the APNFlexKeypadConfigs.keys key values(see below)
    4. For each tagged UIView add an entry in your configs with a matching key value.  
    5. In viewDidLoad call APNFlexKeypad.build(withConfigs:) passing your configs file.
    
    APNFlexKeypadConfigs
    1. Takes an APNFlexKeypadDelegate and a dictionary of [key:("button label", APNFlexKeypadButton.ButtonFunction)]
    2. Each key value of this dictionary must correspond to an existing UIView.tag subview in your flexpad.
    3. The string value in the tuple will be the displayed text of your button.
    4. The APNFlexKeypadButton.ButtonFunction defines the behavior of the final rendered button:
        .accumulator: creates a button that will concatenate its label value to the APNFlexKeypad's value String.  The flexpad calls APNFlexKeypadDelegate.valueChanged() on its delegate when value changes.
        .accumulatorZero: similar to .accumulator except that a zero is only concatenated on the value if it is not the first character.
        .accumulatorBackspace: removes last charact on value string or does nothing if value is an empty string.
        .accumulatorReset: sets value to empty string.
        .custom: has an associated closure of the form ()->(),  this closure will be executed whenever the user clicks this .custom button.
    5. The completion closure is called in APNFlexKeypad.built() after all placeholder UIViews have been replace.  This give the end user the chance to do clean-up adjustments to UI.
    
    Notes:
    1. Calling APNFlexKeypad.build(withConfigs:, completion:) causes your placeholder UIViews to be replaced with corresponding APNFlexKeypadButtons with the same frame as the replaced view.
    2. There must be a 1-1 correspondence between UIView.tags and Configs.keys key values.  There must be a corresponding definition in your configs.keys.
    3. Placeholder UIView tags must be > 0. UIViews with tags <= 0 are ignored allowing you to further customize your flexpad with views and UI that the framework will ignore.
        
    Sample usage:
    
             Interface Builder                                Device
             
             APNFlexKeyPad                                    
        ┌─────────────────────────┐                     ┌─────────────────────────┐
        │    UIView     UIView    │                     │    Button     Button    │
        │   ┌──────┐   ┌──────┐   │                     │   ┌──────┐   ┌──────┐   │
        │   │tag:1 │   │tag:2 │   │                     │   │   1  │   │   0  │   │
        │   └──────┘   └──────┘   │                     │   └──────┘   └──────┘   │
        │    UIView     UIView    │                     │    Button     Button    │
        │   ┌──────┐   ┌──────┐   │     --Output-->     │   ┌──────┐   ┌──────┐   │
        │   │tag:12│   │tag:29│   │                     │   │ Back │   │Reset │   │
        │   └──────┘   └──────┘   │                     │   └──────┘   └──────┘   │
        │         UIView          │                     │         Button          │
        │        ┌──────┐         │                     │        ┌──────┐         │
        │        │tag:56│         │                     │        │  =)  │         │
        │        └──────┘         │                     │        └──────┘         │
        │                         │                     │                         │
        └─────────────────────────┘                     └─────────────────────────┘
        
        Code:
        
        import APNFlexKeypad
        
        class ViewController: UIViewController {
        
            @IBOutlet weak var flexPad: APNFlexKeypad!
            
            func viewDidLoad() {
            
            flexPad.build(withConfigs: APNFlexKeypadConfigs(delegate: self,
                                                               keys: [ 1: ("1", "1", .accumulator)
                                                                       , 2: ("0", "0,", .accumulatorZero)
                                                                       , 12: ("Back", "", .accumulatorBackspace)
                                                                       , 29: ("Reset", .accumulatorReset)
                                                                       , 56: ("=)", .custom( { self.customFunc() }))
                                                                     ]),
                          completion: { self.flexPad.bringSubviewToFront(self.someOtherSubViewofFlexPad) })
                
            }
            
        }
