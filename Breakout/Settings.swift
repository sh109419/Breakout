//
//  Settings.swift
//  Breakout
//
//  Created by hyf on 17/10/24.
//  Copyright © 2017年 hyf. All rights reserved.
//

import Foundation

class Settings {
    
    static let sharedInstance = Settings()
    
    enum PaddleSize: Int {
        case small
        case normal
        case big
    }
    
    private struct Constants {
        static let ballSpeed = "BallSpeed"
        static let numberOfBricks = "NumberOfBricks"
        static let paddleSize = "paddleSize"
        struct Defaults {
            static let ballSpeed = NSNumber(value: 400 as Float)
            static let numberOfBricks = NSNumber(value: 15 as Int32)
            static let paddleSize = PaddleSize.normal
        }
    }
    
    var ballSpeed: Float {
        get {
            if let ballSpeed = UserDefaults.standard.value(forKey: Constants.ballSpeed) as? NSNumber {
                return ballSpeed.floatValue
            } else {
                return Constants.Defaults.ballSpeed.floatValue
            }
        }
        set {
            UserDefaults.standard.setValue(NSNumber(value: newValue as Float), forKey: Constants.ballSpeed)
        }
    }
    
    var numberOfBricks: NSInteger {
        get {
            if let numberOfBricks = UserDefaults.standard.value(forKey: Constants.numberOfBricks) as? NSNumber {
                return numberOfBricks.intValue
            } else {
                return Constants.Defaults.numberOfBricks.intValue
            }
        }
        set {
            UserDefaults.standard.setValue(NSNumber(value: newValue as Int), forKey: Constants.numberOfBricks)
        }
    }
    
    var paddleSize: PaddleSize {
        get {
            if let paddleSize = UserDefaults.standard.value(forKey: Constants.paddleSize) as? NSNumber {
                return Settings.PaddleSize(rawValue: paddleSize.intValue)!
            } else {
                return Constants.Defaults.paddleSize
            }
        }
        set {
            UserDefaults.standard.setValue(NSNumber(value: newValue.rawValue as Int), forKey: Constants.paddleSize)
        }
    }
}
