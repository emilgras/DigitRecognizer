//
//  Util.swift
//  DigitRecognizer
//
//  Created by Emil Gräs on 02/04/2017.
//  Copyright © 2017 Emil Gräs. All rights reserved.
//

import UIKit
import Spring

enum DeviceType: CGFloat {
    case iPhone4 = 480
    case iPhone5 = 568
    case iPhone6 = 667
    case iPhonePlus = 736
}

class Util {
    
    static func getDeviceType() -> DeviceType {
        return DeviceType(rawValue: UIScreen.main.bounds.height)!
    }
    
    static func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static func makeFontSizeSpecificToDeviceType(onLabel label: SpringLabel) {
        switch Util.getDeviceType() {
        case .iPhone4:
            label.font = UIFont(name: label.font.fontName, size: 58)
            break
        case .iPhone5:
            label.font = UIFont(name: label.font.fontName, size: 60)
            break
        default:
            label.font = UIFont(name: label.font.fontName, size: 72)
            break
        }
    }
    
}
