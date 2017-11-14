//
//  ViewController.swift
//  GraphingCalculator
//
//  Created by Daniel Hauagge on 9/14/16.
//  Copyright © 2016 Daniel Hauagge. All rights reserved.
//

import UIKit
//import ObjectiveC
import JavaScriptCore

class FunctionPlottingViewController: UIViewController, UITextFieldDelegate, FunctionPlottingViewDelegate {
    @IBOutlet weak var functionTextField: UITextField!
    @IBOutlet weak var functionPlottingView: FunctionPlottingView!
    

    var expressionFromSegue : String?
    var imageFromSegue : UIImage?
    var expressionIndexFromSegue : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        functionTextField.delegate = self
        functionPlottingView.delegate = self
        
        functionTextField.text = expressionFromSegue
        if let expIndexFromSegue = self.expressionIndexFromSegue {
            functionPlottingView.setNeedsDisplay()
            FunctionsDB.sharedInstance.functionImages[expIndexFromSegue] = renderPlottingView(plottingView: functionPlottingView)
        }
    }
    
    // MARK: - Text View Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        functionTextField.resignFirstResponder()
        functionPlottingView.setNeedsDisplay()
        if let expIndexFromSegue = self.expressionIndexFromSegue {
            FunctionsDB.sharedInstance.functions[expIndexFromSegue] = textField.text ?? ""
            FunctionsDB.sharedInstance.functionImages[expIndexFromSegue] = renderPlottingView(plottingView: functionPlottingView)
            //FunctionsDB.sharedInstance.functionImages[expIndexFromSegue] = FunctionPlottingViewController.renderPlottingView(plottingView: functionPlottingView)
           // FunctionsDB.sharedInstance.functionImages[expIndexFromSegue] = renderPlottingView()
        }
        return false
    }
    
    // MARK: - Function Plotting Delegate
    func functionToPlot() -> ((Double) -> Double)? {
        guard let expr = functionTextField.text else {
            return nil
        }
        if expr == "" {
            return nil
        }
        //funcTableViewController.currentEquation = expr
        let jsSource = "sin = Math.sin; cos = Math.cos; pi = Math.PI; rand = Math.random; sqrt = Math.sqrt; tan = Math.tan; tanh = Math.tanh; round = Math.round; log = Math.log; var f = function(x) { return \( expr ); }"
        
        let context = JSContext()!
        context.evaluateScript(jsSource)
        context.exceptionHandler = {(ctx: JSContext?, value: JSValue?) in
            // type of String
            let stacktrace = value?.objectForKeyedSubscript("stack")?.toString()
            // type of Number
            let lineNumber = value?.objectForKeyedSubscript("line")
            // type of Number
            let column = value?.objectForKeyedSubscript("column")
            let moreInfo = "\tin method \(stacktrace!)\nJS ERROR:\tline number: \(lineNumber!), column: \(column!)"
            print("JS ERROR: \nJS ERROR:\(value!)\nJS ERROR:\(moreInfo)")
        }
        
        let funcJS = context.objectForKeyedSubscript("f")!
        if funcJS.isUndefined {
            return nil
        }
        
        let f : ((Double) -> (Double)) = {(x: Double) in
            let ret = funcJS.call(withArguments: [x])!
            let y : Double = ret.toDouble()
            return y
        }
        
        return f
    }
    
    // MARK: - Gestures
    @IBAction func panGestureTriggered(_ sender: UIPanGestureRecognizer) {
        functionPlottingView.setNeedsDisplay()
        print(sender.state)
        
        switch sender.state {
        case .changed:
            functionPlottingView.currTranslation = sender.translation(in: functionPlottingView)
        case .ended:
            let pnt = sender.translation(in: functionPlottingView)
            functionPlottingView.accumTranslation.x += pnt.x
            functionPlottingView.accumTranslation.y += pnt.y
            functionPlottingView.currTranslation = CGPoint.zero
        default: break
        }
    }
    
    @IBAction func tapGestureTriggered(_ sender: UITapGestureRecognizer) {
        functionPlottingView.crosshairLoc = sender.location(in: functionPlottingView)
        functionPlottingView.setNeedsDisplay()
        
        functionTextField.resignFirstResponder()
        functionPlottingView.setNeedsDisplay()
    }
    
    @IBAction func longTapGestureTriggered(_ sender: UILongPressGestureRecognizer) {
        functionPlottingView.crosshairLoc = nil
        functionPlottingView.setNeedsDisplay()
    }
    
    @IBAction func pinchGestureTriggered(_ sender: UIPinchGestureRecognizer) {
        print(sender.scale)
        functionPlottingView.currScale = sender.scale
        functionPlottingView.setNeedsDisplay()
        functionPlottingView.currScaleLocation = sender.location(in: functionPlottingView)
    }
    
    
    func renderPlottingView(plottingView: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(plottingView.frame.size, true, 0.3)
        //UIGraphicsBeginImageContextWithOptions(CGSize(width: 600, height: 600), true, 0.3)
        let width = plottingView.frame.size.width * 1.01
        let height = plottingView.frame.size.height * 1.01
        plottingView.drawHierarchy(in: CGRect(origin: CGPoint(x: -1, y: -1), size: CGSize(width: width, height: height)), afterScreenUpdates: true)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail
    }
    
    /*
    func renderPlottingView() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(functionPlottingView.frame.size, true, 0.3)
        functionPlottingView.drawHierarchy(in: CGRect(origin: CGPoint(x: 1, y: 0), size: functionPlottingView.frame.size), afterScreenUpdates: true)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail
    }*/
}

