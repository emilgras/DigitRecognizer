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

    // MARK: - Instance Variables
    
    fileprivate var indicator: NVActivityIndicatorView!
    fileprivate var api: RequestManager!
    fileprivate var lastPoint:CGPoint?
    fileprivate var processing:Bool!
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var drawImageView: SpringImageView!
    @IBOutlet weak var shadowView: SpringView!
    @IBOutlet weak var resultLabel: SpringLabel!
    @IBOutlet weak var recognizeButton: SpringButton!
    @IBOutlet weak var clearButton: SpringButton!
    @IBOutlet weak var recognizeButtonPropHeight: NSLayoutConstraint!
    @IBOutlet weak var clearButtonPropHeight: NSLayoutConstraint!
    @IBOutlet weak var shadowViewCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var clearButtonCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var recognizeButtonCenterYConstraint: NSLayoutConstraint!

    // MARK: - IB Actions
    
    @IBAction func recognizeButtonTapped(_ sender: Any) {
        guard let _ = lastPoint else {
            Animator.animate(View: shadowView, withAnimation: "shake", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
            return
        }
        Animator.animate(View: recognizeButton, withAnimation: "pop", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
        updateUI(WithResult: " ", andUserInteractionEnabled: false)
        guard let image = drawImageView.image else {
            self.updateUI(WithResult: "Oops! Error", andUserInteractionEnabled: true)
            Animator.animate(View: shadowView, withAnimation: "shake", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
            return
        }
        guard let imageData = UIImagePNGRepresentation(image) else {
            self.updateUI(WithResult: "Oops! Error", andUserInteractionEnabled: true)
            Animator.animate(View: shadowView, withAnimation: "shake", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
            return
        }
        
        processing = true
        indicator.startAnimating()
        
        api.sendRequest(withImageData: imageData) { (result, error) in
            self.processing = false
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            if let error = error {
                // TODO: Handle Server or Connection Error
                print("Error: \(String(describing: error.localizedDescription))")
                self.updateUI(WithResult: "Oops! Server Error", andUserInteractionEnabled: true)
                return
            }
            guard let result = result else {
                // TODO: Handle Server or Connection Error
                print("Error: Server Error")
                self.updateUI(WithResult: "Oops! Server Error", andUserInteractionEnabled: true)
                return
            }
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate), nil)
            self.updateUI(WithResult: "\(result)", andUserInteractionEnabled: true)
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        Animator.animate(View: clearButton, withAnimation: "pop", withCurve: "spring", withDuration: 0.8, withDelay: 0.0, withDamping: 0.7, withScale: 1.0, withForce: 0.5, withRotation: nil)
        self.lastPoint = nil
        self.drawImageView.image = nil
        self.resultLabel.text = "?"
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initIndicatorView()
        initInstanceVariables()
        updateAppearanceForViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareAnimations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Initializer Methods
    
    fileprivate func initIndicatorView() {
        indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        indicator.type = NVActivityIndicatorType.ballRotateChase
        indicator.color = UIColor(hex: "262626")
        self.containerView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        // centerX & centerY constraints
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self.containerView, attribute: .centerX, multiplier: 1, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self.resultLabel, attribute:.centerY, multiplier: 1, constant: 0))
        // wisth & height constraints
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,multiplier: 1, constant: Util.getDeviceType().rawValue * 0.13))
        containerView.addConstraint(NSLayoutConstraint(item: indicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: Util.getDeviceType().rawValue * 0.13))
    }
    
    fileprivate func initInstanceVariables() {
        self.api = RequestManager()
        self.processing = false
    }
    
    fileprivate func updateAppearanceForViews() {
        Util.makeFontSizeSpecificToDeviceType(onLabel: resultLabel)
        addCornerRadius(toComponent: clearButton, withValue: ((Util.getDeviceType().rawValue * clearButtonPropHeight.multiplier) / 2), masksToBounds: false)
        addCornerRadius(toComponent: recognizeButton, withValue: ((Util.getDeviceType().rawValue * recognizeButtonPropHeight.multiplier) / 2), masksToBounds: false)
        addCornerRadius(toComponent: shadowView, withValue: 6.0, masksToBounds: false)
        addCornerRadius(toComponent: drawImageView, withValue: 6.0, masksToBounds: true)
        addShadow(toComponent: shadowView)
        addShadow(toComponent: recognizeButton)
        addShadow(toComponent: clearButton)
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
    
    // MARK: - Animation Methods
    
    fileprivate func prepareAnimations() {
        self.shadowViewCenterXConstraint.constant = -Util.getScreenWidth()
        self.clearButtonCenterYConstraint.constant = Util.getScreenWidth()
        self.recognizeButtonCenterYConstraint.constant = Util.getScreenWidth()
    }
    
    fileprivate func startAnimations() {
        self.shadowViewCenterXConstraint.constant = 0
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.clearButtonCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.7, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        self.recognizeButtonCenterYConstraint.constant = 0
        UIView.animate(withDuration: 0.7, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        Animator.animate(View: self.resultLabel, withAnimation: "zoomIn", withCurve: "spring", withDuration: 0.7, withDelay: 0.5, withDamping: 0.6, withScale: 1.8, withForce: 2.0, withRotation: nil)
    }
    
    // MARK: - Other Helper Methods
    
    fileprivate func updateUI(WithResult result: String, andUserInteractionEnabled enabled: Bool) {
        DispatchQueue.main.async {
            Animator.animate(View: self.resultLabel, withAnimation: "morph", withCurve: "spring", withDuration: 1.5, withDelay: 0.0, withDamping: 0.5, withScale: 1.0, withForce: 1.0, withRotation: nil)
            self.recognizeButton.isUserInteractionEnabled = enabled
            self.clearButton.isUserInteractionEnabled = enabled
            self.drawImageView.isUserInteractionEnabled = enabled
            self.resultLabel.text = result
        }
    }
    
    // MARK: - Gesture Methods

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !processing {
            if let touch = touches.first {
                lastPoint = touch.location(in: self.drawImageView)
            }
        }
    }
    
    fileprivate func drawLines(fromPoint:CGPoint,toPoint:CGPoint) {
        UIGraphicsBeginImageContext(self.drawImageView.frame.size)
        drawImageView.image?.draw(in: CGRect(x: 0, y: 0, width: self.drawImageView.frame.width, height: self.drawImageView.frame.height))
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(12)
        context?.setStrokeColor(UIColor(hex: "262626").cgColor)
        context?.strokePath()
        drawImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let currentPoint = touches.first?.location(in: self.drawImageView) else { return }
        if !processing {
            drawLines(fromPoint: lastPoint!, toPoint: currentPoint)
        }
        lastPoint = currentPoint
    }


}

