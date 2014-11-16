//
//  contextView.swift
//  CoreGraphicsSwift
//
//  Created by Nurutdinov Timur on 09/11/14.
//  Copyright (c) 2014 addleimb. All rights reserved.
//

import Foundation
import UIKit

let levels = 15
let goldenRatio = 1.61803398875
let pi = 3.14159265359

class contextView: UIView {
    
    override func drawRect(rect: CGRect) {
        var currentContext = UIGraphicsGetCurrentContext()
        CGContextSaveGState(currentContext)
        CGContextSetStrokeColorWithColor(currentContext, UIColor.brownColor().CGColor)
        CGContextSetLineWidth(currentContext, 5)
        
        let points = getPoints(currentContext)
        
        
        for i in 0..<points.count {
            var start:(CGFloat, CGFloat, Int) = points[i]
            var finish:(CGFloat, CGFloat, Int) = points[i/2]
            
            var strokeWidth = CGFloat(Double(levels - finish.2) * 0.125)
            if (finish.2 > 10) { CGContextSetStrokeColorWithColor(currentContext, UIColor.greenColor().CGColor) }
            CGContextSetLineWidth(currentContext, strokeWidth)
            CGContextMoveToPoint(currentContext, start.0, start.1)
            CGContextAddLineToPoint(currentContext, finish.0, finish.1)
            CGContextStrokePath(currentContext);
        }
        
        CGContextRestoreGState(currentContext)
    }
    
    
    func getNextTwoPoints(x0: CGFloat, y0: CGFloat, x1: CGFloat, y1: CGFloat) -> ((CGFloat, CGFloat), (CGFloat, CGFloat)) {
        
        var angle = Double(arc4random()%10) + 18
        var cr = cos(pi/180*angle)
        var sr = sin(pi/180*angle)
        
        var xr = x0 + CGFloat(Double(x1-x0) * cr - Double(y1-y0) * sr)
        var yr = y0 + CGFloat(Double(x1-x0) * sr + Double(y1-y0) * cr)
        
        var xl = x0 + CGFloat(Double(x1-x0) * cr + Double(y1-y0) * sr)
        var yl = y0 + CGFloat(Double(x1-x0) * -sr + Double(y1-y0) * cr)
        
        return ((xr,yr),(xl, yl))
        
    }
    
    
    func getPoints(context: CGContextRef) -> [(CGFloat, CGFloat, Int)] {
        var points = [(CGFloat, CGFloat, Int)]()
        var lengths = getBranchesLength(levels)
        let maxPoints = getMaxPoints(levels)
        
        let x0 = self.frame.width/2.0
        let y0 = self.frame.height
        points.append((x0,y0,0))
        
        let x1 = points[0].0
        let y1 = points[0].1 - CGFloat(lengths[0])
        points.append((x1, y1, 1))
        
        for i in 1..<maxPoints/2 {

            let (x1, y1, currentLevel) = points[i]
            let (x0, y0, prevLevel) = points[i/2]
            let nextLevel = currentLevel + 1
            
            var dx = (x1 - x0)
            var dy = (y1 - y0)
            var currentLength = sqrt(dx * dx + dy * dy)
            var xi = x1 + (dx / currentLength) * CGFloat(lengths[currentLevel])
            var yi = y1 + (dy / currentLength) * CGFloat(lengths[currentLevel])
            
            let ((xr, yr), (xl,yl)) = getNextTwoPoints(x1, y0: y1, x1: xi, y1:yi)
            points.append((xr, yr, nextLevel))
            points.append((xl, yl, nextLevel))
        }

    
        return points
    }
    
    
    func getMaxPoints(levels: Int) -> Int {
        var counter = 1;
        for i in 0...levels {
            counter *= 2
        }
        return counter
    }
    
    func getBranchesLength(number: Int) -> [Int] {
        var branchLengths = [Int]()
        let base = 160
        
        var prevBase = base
        for i in 0...number {
            branchLengths.append(prevBase)
            prevBase = Int(Double(prevBase) / goldenRatio)
            if prevBase == 0 {
                prevBase = 1
            }
        }
        
        return branchLengths
    }
}

