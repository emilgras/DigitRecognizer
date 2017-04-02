//
//  RecognizerVC.swift
//  DigitRecognizer
//
//  Created by Emil Gräs on 16/03/2017.
//  Copyright © 2017 Emil Gräs. All rights reserved.
//

import UIKit
import Spring
import AudioToolbox
import NVActivityIndicatorView

class RecognizerVC: UIViewController {

    var indicator: NVActivityIndicatorView!
    var screenWidth: CGFloat!
    var lastPoint:CGPoint?
    var isSwiping:Bool!
    var isWorking:Bool!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var drawImageView: SpringImageView!
    @IBOutlet weak var shadowView: SpringView!
    @IBOutlet weak var resultLabel: SpringLabel!
    @IBOutlet weak var recognizeButton: SpringButton!
    @IBOutlet weak var recognizeButtonPropWidth: NSLayoutConstraint!
    @IBOutlet weak var clearButton: SpringButton!
    @IBOutlet weak var clearButtonPropWidth: NSLayoutConstraint!
    @IBOutlet weak var shadowViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var clearButtonCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var recognizeButtonCenterYConstraint: NSLayoutConstraint!
    
    @IBAction func recognizeButtonTapped(_ sender: Any) {
        
        guard let _ = lastPoint else {
//            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), nil)
            Animator.animate(View: shadowView, withAnimation: "shake", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
            return
        }
        
        Animator.animate(View: recognizeButton, withAnimation: "pop", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
        updateUI(WithResult: " ", andUserInteractionEnabled: false)
        indicator.startAnimating()
        
        // TODO: lav guard let istedet
        if let image = drawImageView.image {
            
            // TODO: lav guard let istedet
            if let imageData = UIImagePNGRepresentation(image) {
                
                self.isWorking = true
                // TODO: Stop indicator
                
                RequestUtils.sendRequest(withImageData: imageData, completion: { (result, error) in
                    
                    self.isWorking = false
                    DispatchQueue.main.async {
                        self.indicator.stopAnimating()
                    }
                    
                    if let error = error {
                        // TODO: Handle Error
                        print("Error: \(String(describing: error.localizedDescription))")
                        self.updateUI(WithResult: "Server Error", andUserInteractionEnabled: true)
                        return
                    }

                    guard let result = result else {
                        // TODO: Handle Error
                        print("Error: Error")
                        self.updateUI(WithResult: "Error", andUserInteractionEnabled: true)
                        return
                    }
                    
                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), nil)
                    self.updateUI(WithResult: "\(result)", andUserInteractionEnabled: true)
                    
                })
                
            }
        }
    }
    
    fileprivate func updateUI(WithResult result: String, andUserInteractionEnabled enabled: Bool) {
        DispatchQueue.main.async {
            Animator.animate(View: self.resultLabel, withAnimation: "morph", withCurve: "spring", withDuration: 1.5, withDelay: 0.0, withDamping: 0.5, withScale: 1.0, withForce: 1.0, withRotation: nil)
            self.recognizeButton.isUserInteractionEnabled = enabled
            self.clearButton.isUserInteractionEnabled = enabled
            self.drawImageView.isUserInteractionEnabled = enabled
            self.resultLabel.text = result
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        Animator.animate(View: clearButton, withAnimation: "pop", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
        self.lastPoint = nil
        self.drawImageView.image = nil
        self.clearButton.titleLabel?.text = "Clear"
        self.resultLabel.text = "?"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        indicator.type = NVActivityIndicatorType.ballRotateChase
        indicator.color = UIColor(hex: "262626")
        indicator.padding = 8.0
        self.containerView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        // TODO: Take constants and put them somewhere else
        
        // centerX & centerY constraints
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self.containerView, attribute: .centerX, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self.resultLabel, attribute:.centerY, multiplier: 1, constant: 0))
        // wisth & height constraints
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: 90))
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 90))
        
        self.isWorking = false
        self.screenWidth = UIScreen.main.bounds.width
        addCornerRadius(toComponent: clearButton, withValue: ((self.screenWidth * 0.85 * clearButtonPropWidth.multiplier) / 2), masksToBounds: false)
        addCornerRadius(toComponent: recognizeButton, withValue: ((self.screenWidth * 0.85 * recognizeButtonPropWidth.multiplier) / 2), masksToBounds: false)
        addCornerRadius(toComponent: shadowView, withValue: 6.0, masksToBounds: false)
        addCornerRadius(toComponent: drawImageView, withValue: 6.0, masksToBounds: true)
        addShadow(toComponent: shadowView)
        addShadow(toComponent: recognizeButton)
        addShadow(toComponent: clearButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStartPosition()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func addCornerRadius(toComponent component: UIView, withValue value: CGFloat, masksToBounds masks: Bool) {
        component.layer.cornerRadius = value
        component.layer.masksToBounds = masks
    }
    
    fileprivate func addShadow(toComponent component: UIView) {
        component.layer.shadowColor = UIColor.lightGray.cgColor
        component.layer.shadowOpacity = 0.6
        component.layer.shadowOffset = CGSize(width: 0, height: 5)
        component.layer.shadowRadius = 7
    }
    
    // MARK: Intro Animation
    fileprivate func setStartPosition() {
        self.shadowViewCenterXConstraint.constant = -screenWidth
        self.clearButtonCenterYConstraint.constant = screenWidth
        self.recognizeButtonCenterYConstraint.constant = screenWidth
    }
    
    fileprivate func startAnimating() {
        self.shadowViewCenterXConstraint.constant = 0
        UIView.animate(withDuration: 0.7, delay: 1.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.clearButtonCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.7, delay: 1.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.recognizeButtonCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.6, delay: 1.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        Animator.animate(View: self.resultLabel, withAnimation: "zoomIn", withCurve: "spring", withDuration: 0.7, withDelay: 1.8, withDamping: 0.7, withScale: 1.8, withForce: 2.5, withRotation: nil)

    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isWorking {
            isSwiping = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self.drawImageView)
            }
        }
    }
    
    func drawLines(fromPoint:CGPoint,toPoint:CGPoint) {
        if !isWorking {
            UIGraphicsBeginImageContext(self.drawImageView.frame.size)
            drawImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.drawImageView.frame.width, height: self.drawImageView.frame.height))
            let context = UIGraphicsGetCurrentContext()
            
            context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
            //tool.center = toPoint
            
            context?.setBlendMode(CGBlendMode.normal)
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(12)
            context?.setStrokeColor(UIColor(hex: "262626").cgColor)
            
            context?.strokePath()
            
            drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isWorking {
            isSwiping = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: self.drawImageView)
                drawLines(fromPoint: lastPoint!, toPoint: currentPoint)
                
                lastPoint = currentPoint
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isSwiping {
            // TODO: lastPoint is not safely unwrapped
            drawLines(fromPoint: lastPoint!, toPoint: lastPoint!)
        }
    }

}

