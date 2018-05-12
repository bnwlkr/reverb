//
//  Stepper.swift
//  shift
//
//  Created by Ben Walker on 2018-05-12.
//  Copyright © 2018 Ben Walker. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable class Stepper: NSObject {

    var max = 10
    var min = 2
    var _value: Int = 4
    var value: Int {
        get {
            return _value
        } set {
            _value = newValue
            label.text = String(newValue)
        }
    }
    
    var incrementButton: UIButton!
    var decrementButton: UIButton!
    var label: UILabel!
    
    convenience init(incButton: UIButton, decButton: UIButton, label: UILabel) {
        self.init()
        self.incrementButton = incButton
        self.decrementButton = decButton
        self.label = label
    }
    
    // assume these can't be called if value is at edge of bound
    func increment () {
        if (value==max) {return}
        value+=1
        if (value==max) {incrementButton.alpha=0.5}
        decrementButton.alpha=1.0
    }
    
    func decrement () {
        if (value==min) {return}
        value-=1
        if (value==min) {decrementButton.alpha=0.5}
        incrementButton.alpha=1.0
    }
    
    
}
