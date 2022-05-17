import UIKit
import Orion
import BatteryBuddyC

var batteryIconView:UIImageView = UIImageView()
var batteryChargerView:UIImageView = UIImageView()
var LSBatteryIconView:UIImageView = UIImageView()
var LSBatteryChargerView:UIImageView = UIImageView()
var isCharging = Bool()
var isLowPowerModeActive = ProcessInfo.processInfo.isLowPowerModeEnabled

class BatteryViewHook: ClassHook<UIView> {
    
    static let targetName = "_UIBatteryView"
    
    func _shouldShowBolt() -> Bool { // hide charging bolt
        
        return false
        
    }
    
    func fillColor() -> UIColor { // get color and lower the opacity of the battery icon fill color
        
        return orig.fillColor().withAlphaComponent(0.25)
        
    }
    
    func chargePercent() -> CGFloat { // update face corresponding the battery percentage
        
        let percentage = orig.chargePercent()
        let actualPercentage = percentage * 100
        
        if actualPercentage <= 20 && !isCharging {
            batteryIconView.image = UIImage(contentsOfFile:"/Library/BatteryBuddy/sad.png")
        } else if actualPercentage <= 49 && !isCharging {
            batteryIconView.image = UIImage(contentsOfFile:"/Library/BatteryBuddy/neutral.png")
        } else if actualPercentage > 49 && !isCharging {
            batteryIconView.image = UIImage(contentsOfFile:"/Library/BatteryBuddy/happy.png")
        } else if isCharging {
            batteryIconView.image = UIImage(contentsOfFile:"/Library/BatteryBuddy/happy.png")
        }
        
        updateIconColor()
        
        return percentage
        
    }
    
    func chargingState() -> Int { // refresh icons when charging state changed
        
        let state = orig.chargingState()
        
        if state == 1 {
            isCharging = true
        } else {
            isCharging = false
        }
        
        refreshIcon()
        
        return state
        
    }
    
    func _updateFillLayer() { // update the icon
        
        orig._updateFillLayer()
        
        chargingState()
        
    }
    
    // orion:new
    func refreshIcon() { // refresh status bar icons
        
        // remove existing images
        batteryIconView = UIImageView()
        batteryChargerView = UIImageView()
        for subview in target.subviews {
            subview.removeFromSuperview()
        }
        
        // face
        if batteryIconView != nil {
            batteryIconView.frame = target.bounds
            batteryIconView.contentMode = .scaleAspectFill
            batteryIconView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if !batteryIconView.isDescendant(of:target) {
                target.addSubview(batteryIconView)
            }
        }
        
        // charger
        if batteryChargerView != nil && isCharging {
            batteryChargerView.frame = target.bounds
            batteryChargerView.contentMode = .scaleAspectFill
            batteryChargerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            batteryChargerView.image = UIImage(contentsOfFile:"/Library/BatteryBuddy/charger.png")
            if !batteryChargerView.isDescendant(of:target) {
                target.addSubview(batteryChargerView)
            }
        }
        
        chargePercent()
        
    }
    
    // orion:new
    func updateIconColor() {  // add lockscreen battery icons
        
        batteryIconView.image = batteryIconView.image?.withRenderingMode(.alwaysTemplate)
        batteryChargerView.image = batteryChargerView.image?.withRenderingMode(.alwaysTemplate)
        if !isLowPowerModeActive {
            batteryIconView.tintColor = UIColor.label
            batteryChargerView.tintColor = UIColor.label
        } else {
            batteryIconView.tintColor = UIColor.black
            batteryChargerView.tintColor = UIColor.black
        }
        
    }
    
}

class LockscreenBatteryViewHook: ClassHook<UIView> { // add lockscreen battery icons
    
    static let targetName = "CSBatteryFillView"
    
    func didMoveToWindow() {
        
        orig.didMoveToWindow()
        
        target.superview?.clipsToBounds = false
        
        LSBatteryIconView = UIImageView()
        LSBatteryChargerView = UIImageView()
        
        // face
        if LSBatteryIconView != nil {
            LSBatteryIconView.frame = target.bounds
            LSBatteryIconView.contentMode = .scaleAspectFill
            LSBatteryIconView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            LSBatteryIconView.image = UIImage(contentsOfFile:"/Library/BatteryBuddy/happyLS.png")
        }
        LSBatteryIconView.image = LSBatteryIconView.image?.withRenderingMode(.alwaysTemplate)
        LSBatteryIconView.tintColor = UIColor.white
        if !LSBatteryIconView.isDescendant(of:target.superview!) {
            target.superview!.addSubview(LSBatteryIconView)
        }
        
        // charger
        if LSBatteryChargerView != nil {
            LSBatteryChargerView.frame = CGRect(x: target.bounds.origin.x - 25, y: target.bounds.origin.y, width: target.bounds.size.width, height: target.bounds.size.height)
            LSBatteryChargerView.contentMode = .scaleAspectFill
            LSBatteryChargerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            LSBatteryChargerView.image = UIImage(contentsOfFile:"/Library/BatteryBuddy/chargerLS.png")
        }
        LSBatteryIconView.image = LSBatteryIconView.image?.withRenderingMode(.alwaysTemplate)
        LSBatteryIconView.tintColor = UIColor.white
        if !LSBatteryIconView.isDescendant(of:target.superview!) {
            target.superview!.addSubview(LSBatteryIconView)
        }
        
    }
    
}
