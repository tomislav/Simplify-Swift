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

class ViewController: UIViewController {
    private struct ExamplePoint: Decodable {
        let x: CGFloat
        let y: CGFloat
    }

    @IBOutlet var textLabel: UILabel!
    @IBOutlet var toleranceSlider: UISlider!
    @IBOutlet var hqSwitch: UISwitch!
    @IBOutlet var polylineView: PolylineView!
    private var points: [CGPoint] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadTestData()
        refreshPolylineView()
    }
    
    @IBAction func didChangeHQParameter(_ sender: UISwitch) {
        refreshPolylineView()
    }
    
    @IBAction func didChangeValue(_ sender: UISlider) {
        refreshPolylineView()
    }
    
    private func loadTestData() {
        guard let testDataURL = Bundle.main.url(forResource: "test-data", withExtension: "json"),
              let data = try? Data(contentsOf: testDataURL),
              let decodedPoints = try? JSONDecoder().decode([ExamplePoint].self, from: data) else {
            points = []
            return
        }

        points = decodedPoints.map { CGPoint(x: $0.x, y: $0.y) }
    }

    func refreshPolylineView() {
        let tolerance = Double(toleranceSlider.value)
        let highQuality = hqSwitch.isOn
        let sourcePoints = points

        DispatchQueue.global(qos: .userInitiated).async {
            let startTime = DispatchTime.now()
            let simplified = Simplify.simplify(sourcePoints, tolerance: tolerance, highQuality: highQuality)
            let endTime = DispatchTime.now()
            
            let duration = Double(endTime.uptimeNanoseconds - startTime.uptimeNanoseconds) / 1000000.0
            let timesLess = simplified.isEmpty ? 0 : Float(sourcePoints.count) / Float(simplified.count)
            
            DispatchQueue.main.async {
                self.polylineView.points = simplified
                
                let string = NSMutableAttributedString()
                string
                    .bold(String(format: "%d", sourcePoints.count))
                    .normal(" points, simplified with tolerance: ")
                    .bold(String(format: "%.2f", self.toleranceSlider.value))
                    .normal(" px\n")
                    .normal("After simplification: ")
                    .bold(String(format: "%d", simplified.count))
                    .normal(" points (~")
                    .bold(String(format: "%.0f", timesLess))
                    .normal(" times less)\n")
                    .normal("Performed in ")
                    .bold(String(format: "%.2f", duration))
                    .normal(" ms")
                self.textLabel.attributedText = string
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
