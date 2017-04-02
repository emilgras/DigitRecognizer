//
//  Animator.swift
//  DigitRecognizer
//
//  Created by Emil Gräs on 01/04/2017.
//  Copyright © 2017 Emil Gräs. All rights reserved.
//

import UIKit
import Spring

class Animator {
    
    static func animate(View view: Springable, withAnimation animation: String, withCurve curve: String, withDuration duration: CGFloat, withDelay delay: CGFloat,  withDamping damping: CGFloat, withScale scale: CGFloat, withForce force: CGFloat, withRotation rotation: CGFloat?) {
        view.animation = animation
        view.curve = curve
        view.duration = duration
        view.delay = delay
        view.force = force
        view.rotate = (rotation == nil) ? 0 : rotation!
        view.scaleX = scale
        view.scaleY = scale
        view.damping = damping
        view.velocity = 0.7
        view.animate()
    }
    
}
