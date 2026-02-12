//
//  Simplify.swift
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
import CoreLocation
import CoreGraphics

public protocol SimplifyValue {
    var xValue: Double { get }
    var yValue: Double { get }
}

private func equalsPoints<T: SimplifyValue>(l: T, r: T) -> Bool {
    return l.xValue == r.xValue && l.yValue == r.yValue
}

extension CGPoint: SimplifyValue {
    
    public var xValue: Double {
        return Double(x)
    }
    
    public var yValue: Double {
        return Double(y)
    }
}

extension CLLocationCoordinate2D: SimplifyValue {
    
    public var xValue: Double {
        return latitude
    }
    
    public var yValue: Double {
        return longitude
    }
}

open class Simplify {
    /**
     Calculate square distance
     
     - parameter pointA: from point
     - parameter pointB: to point
     
     - returns: square distance between two points
     */
    private class func getSquareDistance<T:SimplifyValue>(_ pointA: T,_ pointB: T) -> Double {
        return (pointA.xValue - pointB.xValue) * (pointA.xValue - pointB.xValue) + (pointA.yValue - pointB.yValue) * (pointA.yValue - pointB.yValue)
    }
    
    /**
     Calculate square distance from a point to a segment
     
     - parameter point: from point
     - parameter seg1: segment first point
     - parameter seg2: segment last point

     - returns: square distance between point to a segment
     */
    private class func getSquareSegmentDistance<T:SimplifyValue>(point p: T, seg1 s1: T, seg2 s2: T) -> Double {
        
        var x = s1.xValue
        var y = s1.yValue
        var dx = s2.xValue - x
        var dy = s2.yValue - y
        
        if dx != 0 || dy != 0 {
            let t = ((p.xValue - x) * dx + (p.yValue - y) * dy) / ((dx * dx) + (dy * dy))
            if t > 1 {
                x = s2.xValue
                y = s2.yValue
            } else if t > 0 {
                x += dx * t
                y += dy * t
            }
        }
        
        dx = p.xValue - x
        dy = p.yValue - y
        
        return (dx * dx) + (dy * dy)
    }
    
    /**
     Simplify an array of points using the Ramer-Douglas-Peucker algorithm
     
     - parameter points:      An array of points
     - parameter tolerance:   Affects the amount of simplification (in the same metric as the point coordinates)
     
     - returns: Returns an array of simplified points
     */
    private class func simplifyDouglasPeucker<T:SimplifyValue>(_ points: [T], squaredTolerance: Double) -> [T] {
        if points.count <= 2 {
            return points
        }

        let lastPoint = points.count - 1
        var keep = Array(repeating: false, count: points.count)
        keep[0] = true
        keep[lastPoint] = true

        var stack: [(first: Int, last: Int)] = [(0, lastPoint)]
        while let (first, last) = stack.popLast() {
            if last - first <= 1 {
                continue
            }

            var maxSquareDistance = squaredTolerance
            var index = 0

            for i in first + 1 ..< last {
                let squareDistance = getSquareSegmentDistance(point: points[i], seg1: points[first], seg2: points[last])
                if squareDistance > maxSquareDistance {
                    index = i
                    maxSquareDistance = squareDistance
                }
            }

            if maxSquareDistance > squaredTolerance {
                keep[index] = true
                if index - first > 1 {
                    stack.append((first, index))
                }
                if last - index > 1 {
                    stack.append((index, last))
                }
            }
        }

        var result: [T] = []
        result.reserveCapacity(points.count)
        for (index, shouldKeepPoint) in keep.enumerated() where shouldKeepPoint {
            result.append(points[index])
        }

        return result
    }
    
    /**
     Simplify an array of points using the Radial Distance algorithm
     
     - parameter points:      An array of points
     - parameter tolerance:   Affects the amount of simplification (in the same metric as the point coordinates)
     
     - returns: Returns an array of simplified points
     */
    private class func simplifyRadialDistance<T:SimplifyValue>(_ points: [T], squaredTolerance: Double) -> [T] {
        if points.count <= 2 {
            return points
        }
        
        var prevPoint = points[0]
        var newPoints: [T] = [prevPoint]
        var point = points[1]
        
        for idx in 1 ..< points.count {
            point = points[idx]
            let distance = getSquareDistance(point, prevPoint)
            if distance > squaredTolerance {
                newPoints.append(point)
                prevPoint = point
            }
        }
        
        if !equalsPoints(l: prevPoint, r: point) {
            newPoints.append(point)
        }
        
        return newPoints
    }
    
    /**
     Returns an array of simplified points
     
     - parameter points:      An array of points
     - parameter tolerance:   Affects the amount of simplification (in the same metric as the point coordinates)
     - parameter highQuality: Excludes distance-based preprocessing step which leads to highest quality simplification but runs ~10-20 times slower
     
     - returns: Returns an array of simplified points
     */
    
    open class func simplify<T:SimplifyValue>(_ points: [T], tolerance: Double = 1, highQuality: Bool = false) -> [T] {
        if points.count <= 2 {
            return points
        }

        let squareTolerance = tolerance * tolerance
        var result: [T] = (highQuality ? points : simplifyRadialDistance(points, squaredTolerance: squareTolerance))
        result = simplifyDouglasPeucker(result, squaredTolerance: squareTolerance)
        return result
    }

    @available(*, deprecated, message: "Use simplify(_:tolerance:highQuality:) with a non-optional Double tolerance.")
    open class func simplify<T:SimplifyValue>(_ points: [T], tolerance: Float?, highQuality: Bool = false) -> [T] {
        return simplify(points, tolerance: tolerance.map(Double.init) ?? 1, highQuality: highQuality)
    }
}
