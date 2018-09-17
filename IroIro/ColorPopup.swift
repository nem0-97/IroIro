//
//  ColorPopup.swift
//  Navigation Controller Test
//
//  Created by Ezhik on 6/14/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit

class ColorPopup: NSObject {


    var callback : (UIColor)->()
    
    var window : UIWindow
    var view : UIView
    var colorContainer : UIView
    
    
    
    init(callback: @escaping (UIColor)->()) {
        
        
        self.callback = callback
        self.window = UIApplication.shared.keyWindow!
        let w = (window.bounds).width
        let h = (window.bounds).height
        self.view = UIView(frame: CGRect(x: 0, y: 0, width: w+h, height: w+h)) //(window?.bounds)!)
        self.colorContainer = UIView()
        
        
        super.init()
        window.addSubview(view)
        
        self.view.backgroundColor = UIColor.clear
        UIView.animate(withDuration: 1.0, animations: {
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.95)//UIColor.clear
        })
        
        /*//blurry BG - https://stackoverflow.com/questions/17041669/
    
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        //blurEffectView.alpha = 0.0
        //UIView.animate(withDuration: 0.5, animations: {
        //    blurEffectView.alpha = 1.0
        //})*/
        
        
        //dismiss button (this is easier than messing with touch detectors and such)
        let dismissButton = UIButton()
        dismissButton.addTarget(self, action: #selector(dismiss(sender:)), for: .touchUpInside)

        dismissButton.frame = view.bounds
        view.addSubview(dismissButton)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.orientationChanged(notification:)),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil
        )
        
        
        
        
        colorContainer.frame = CGRect(x: 0, y: 0, width: min(w, h, 600), height: min(w, h, 600))
        colorContainer.center = CGPoint(x: w/2, y: h/2)
        
        let colorContainerSize = colorContainer.frame.width
        let colorSize = colorContainerSize/4 - 10
        for i in 0...3 {
            for j in 0...3 {
                let current = (i*4)+j
                let square = UIButton(frame: CGRect(x: 0, y: 0, width: colorSize+100, height: colorSize+100))
                square.center = CGPoint(x: (colorContainerSize / 4) * (CGFloat(j) + 0.5), y: (colorContainerSize / 4) * (CGFloat(i) + 0.5))
                square.backgroundColor = UIColor.clear
                colorContainer.addSubview(square)
                //print(String(current) + "; i: " + String(i) + "; j: " + String(j))
                
                UIView.animate(withDuration: 0.5, delay: (0.03125 * Double(current)), animations: {
                    square.frame = CGRect(x: 0, y: 0, width: colorSize, height: colorSize)
                    square.center = CGPoint(x: (colorContainerSize / 4) * (CGFloat(j) + 0.5), y: (colorContainerSize / 4) * (CGFloat(i) + 0.5))
                    square.backgroundColor = Colors.Array[current]
                    
                })
                
                //square.addTarget(self, action: , for: <#T##UIControlEvents#>)
                
                square.tag = current
                square.addTarget(self, action: #selector(tap(sender:)), for: .touchUpInside)
                
            }
        }
        
        //colorContainer.layer.anchorPoint = CGPoint(x: colorContainer.frame.width/2, y: colorContainer.frame.height/2)
        view.addSubview(colorContainer)
        //colorContainer.backgroundColor = UIColor.red
        
        //NotificationCenter.default.addObserver({print("turn")}, selector: #selector("self.orientationChanged(notification:)"), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        //callback(Colors.Emerald)
    }
    deinit {
        //print("we're gone")
    }

    @objc func tap(sender: UIButton!) {
        let x : Int = sender.tag % 4
        let y : Int = sender.tag / 4
        
        //print("SENDER: " + String(sender.tag) + "; x: " + String(x) + "; y: " + String(y))
        for i in 0...3 {
            for j in 0...3 {
                let current = (i*4)+j
                let square = colorContainer.subviews[current]
                
                
                let oldCenter = square.center
                let colorContainerSize = colorContainer.frame.width
                let colorSize = colorContainerSize/4 - 10
                
                
                
                let distance = abs(j - x) + abs(i - y)
                
                
                //print(String(distance) + "; i: " + String(i) + "; j: " + String(j))
                
                UIView.animate(withDuration: 0.5, delay: ((0.5/6) * Double(distance)), animations: {
                    square.frame = CGRect(x: 0, y: 0, width: colorSize + 100, height: colorSize + 100)
                    square.center = oldCenter
                    //square.center = CGPoint(x: , y: (colorContainerSize / 4) * (CGFloat(i) + 0.5))
                    square.alpha = 0.0
                    //square.backgroundColor = UIColor.clear//Colors.Array[current]
                    
                })
            }
        }
        callback(sender.backgroundColor!)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.backgroundColor = UIColor.clear
        }, completion: {
            void in
            self.view.removeFromSuperview()
        })
    }
    
    @objc func dismiss(sender: UIButton!) {
        //print("dismiss")
        let colorContainerSize = colorContainer.frame.width
        let colorSize = colorContainerSize/4 - 10
        
        var current = 0
        
        for square in colorContainer.subviews.reversed() {
            let oldCenter = square.center
            UIView.animate(withDuration: 0.5, delay: (0.03125 * Double(current)), animations: {
                square.frame = CGRect(x: 0, y: 0, width: colorSize + 100, height: colorSize + 100)
                square.center = oldCenter
                //square.center = CGPoint(x: , y: (colorContainerSize / 4) * (CGFloat(i) + 0.5))
                square.alpha = 0.0
                //square.backgroundColor = UIColor.clear//Colors.Array[current]
                
            })
            current += 1
        }
        UIView.animate(withDuration: 1.0, animations: {
            self.view.backgroundColor = UIColor.clear
        }, completion: {
            void in
            self.view.removeFromSuperview()
        })
    }
    
    @objc func orientationChanged(notification: Notification) {
        
        
        // handle rotation here
        //print("rotat")
        //let view = UIApplication.shared.keyWindow?.viewWithTag(666666666)
        //let window = UIApplication.shared.keyWindow
        let w = (window.bounds).width
        let h = (window.bounds).height
        
        //print("w: " + String(describing: w) + " h: " + String(describing: h))

        //let colorContainer = view!.subviews[1]
        UIView.animate(withDuration: 0.1, animations: {
            self.colorContainer.center = CGPoint(x: w/2, y: h/2)
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
