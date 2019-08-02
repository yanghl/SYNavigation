//
//  SYAnimationTools.swift
//  sjwz_swift_Example
//
//  Created by che on 2019/7/16.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class SYAnimation: NSObject {
    //缩放
    static func scaleAnimation (layer:CALayer,from:CGFloat,to:CGFloat,duration:Float,remove:Bool,repeats:Float) {
        let scaleA = CABasicAnimation.init(keyPath: "transform.scale")
        scaleA.fromValue = from
        scaleA.toValue = to
        scaleA.duration = CFTimeInterval(duration)
        scaleA.repeatCount = repeats
        scaleA.isRemovedOnCompletion = remove
        layer.add(scaleA, forKey: "transform_scale")
    }    
}
