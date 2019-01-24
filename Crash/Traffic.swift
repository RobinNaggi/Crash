//
//  File.swift
//  Crash
//
//  Created by Robin Naggi on 1/19/19.
//  Copyright © 2019 Robin Naggi. All rights reserved.
//

import Foundation
import UIKit

struct ColliderType {
    static let CAR_COLLIDER: UInt32 = 0
    static let Item_COLLIDER: UInt32 = 1
    static let Item_COLLIDER_1: UInt32 = 2
}
class Traffic: NSObject {
    
    func randonCarTraffic(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {
        
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
        
    }
}

class Setting {
    static let sharedInstance = Setting()
    
    private init(){
        
    }
    
    
    var highScore = 63
}
