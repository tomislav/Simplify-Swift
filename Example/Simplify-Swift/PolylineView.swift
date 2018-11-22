//
//  PolylineView.swift
//  Simplify-Swift_Example
//
//  Copyright (c) 2018 Tomislav Filipcic <tf@7sols.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import UIKit

class PolylineView: UIView {
    var points: [CGPoint]?
    
    override func draw(_ rect: CGRect) {
        guard points != nil else {
            return
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(1.0)
        
        let minX = points!.first!.x
        var minY = points!.first!.y
        
        for i in 1 ..< points!.count {
            let p = points![i]
            if p.y < minY {
                minY = p.y
            }
        }
        
        for i in 0 ..< (points!.count-1) {
            let p = points![i]
            let p1 = points![i+1]
            context?.move(to: CGPoint(x: p.x-minX, y: p.y-minY))
            context?.addLine(to: CGPoint(x: p1.x-minX, y: p1.y-minY))
            context?.strokePath()
        }
        context?.drawPath(using: CGPathDrawingMode.stroke);
    }
}
