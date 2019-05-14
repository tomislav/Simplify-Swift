//
//  ViewController.swift
//  Simplify-Swift
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

import UIKit
import Simplify_Swift

class ViewController: UIViewController {
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var toleranceSlider: UISlider!
    @IBOutlet var hqSwitch: UISwitch!
    @IBOutlet var polylineView: PolylineView!
    fileprivate var points: [CGPoint] = []

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let testDataPath = Bundle.main.path(forResource: "test-data", ofType: "json")
        let testData = try? Data(contentsOf: URL(fileURLWithPath: testDataPath!), options: [])
        let testDataObj: AnyObject? = try! JSONSerialization.jsonObject(with: testData!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject?
        
        if let testDataObj = testDataObj as? NSArray {
            for idx in 0 ..< testDataObj.count {
                if let itemDict = testDataObj[idx] as? NSDictionary {
                    if let x = itemDict["x"] as? NSNumber, let y = itemDict["y"] as? NSNumber {
                        points.append( CGPoint( x: CGFloat(x.floatValue), y: CGFloat(y.floatValue)) )
                    }
                }
            }
            refreshPolylineView()
        }
    }
    
    @IBAction func didChangeHQParameter(_ sender: UISwitch) {
        refreshPolylineView()
    }
    
    @IBAction func didChangeValue(_ sender: UISlider) {
        refreshPolylineView()
    }
    
    func refreshPolylineView() {
        let tolerance = Float(toleranceSlider!.value)
        let highQuality = hqSwitch.isOn

        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let startTime = DispatchTime.now()
            let simplified = Simplify.simplify(self.points, tolerance: tolerance, highQuality: highQuality)
            let endTime = DispatchTime.now()
            
            let duration = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000.0
            let timesLess = Float(self.points.count) / (Float(simplified.count))
            
            DispatchQueue.main.async {
                self.polylineView.points = simplified
                self.polylineView.setNeedsDisplay()
                
                let string = NSMutableAttributedString()
                string
                    .bold(String(format: "%d", self.points.count))
                    .normal(" points, simplified with tolerance: ")
                    .bold(String(format: "%.2f", self.toleranceSlider!.value))
                    .normal(" px\n")
                    .normal("After simplification: ")
                    .bold(String(format: "%d", self.polylineView!.points!.count))
                    .normal(" points (~")
                    .bold(String(format: "%.0f", timesLess))
                    .normal(" times less)\n")
                    .normal("Performed in ")
                    .bold(String(format: "%.2f", duration))
                    .normal(" ms")
                
                self.textLabel!.attributedText = string
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.bold)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}
