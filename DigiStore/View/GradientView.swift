//
//  GradientView.swift
//  DigiStore
//
//  Created by Milad Nourizade on 7/21/18.
//  Copyright © 2018 Milad Nourizade. All rights reserved.
//

import Foundation
import UIKit
class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let colorComponent:[CGFloat] = [0, 0, 0, 0.3, 0, 0, 0, 0.7]
        let locations:[CGFloat] = [0, 1]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComponent, locations: locations, count: 2)
        
        
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let maxRadius = max(x,y)
     
        let graphicContext = UIGraphicsGetCurrentContext()
        graphicContext?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: maxRadius, options: .drawsAfterEndLocation)
    }
}
