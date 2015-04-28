//
//  CEMKit.swift
//  CEMKit-Swift
//
//  Created by Cem Olcay on 05/11/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

import UIKit



// MARK: - UIBarButtonItem

func barButtonItem (imageName: String,
    action: (AnyObject)->()) -> UIBarButtonItem {
        let button = BlockButton (frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(UIImage(named: imageName), forState: .Normal)
        button.actionBlock = action
        
        return UIBarButtonItem (customView: button)
}

func barButtonItem (title: String,
    color: UIColor,
    action: (AnyObject)->()) -> UIBarButtonItem {
        let button = BlockButton (frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(color, forState: .Normal)
        button.actionBlock = action
        button.sizeToFit()
        
        return UIBarButtonItem (customView: button)
}



// MARK: - CGSize

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize (width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize (width: left.width - right.width, height: left.width - right.width)
}



// MARK: - CGPoint

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint (x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint (x: left.x - right.x, y: left.y - right.y)
}


enum AnchorPosition: CGPoint {
    case TopLeft        = "{0, 0}"
    case TopCenter      = "{0.5, 0}"
    case TopRight       = "{1, 0}"
    
    case MidLeft        = "{0, 0.5}"
    case MidCenter      = "{0.5, 0.5}"
    case MidRight       = "{1, 0.5}"
    
    case BottomLeft     = "{0, 1}"
    case BottomCenter   = "{0.5, 1}"
    case BottomRight    = "{1, 1}"
}

extension CGPoint: StringLiteralConvertible {
    
    public init(stringLiteral value: StringLiteralType) {
        self = CGPointFromString(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self = CGPointFromString(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self = CGPointFromString(value)
    }
}



// MARK: - CGFloat

func degreesToRadians (angle: CGFloat) -> CGFloat {
    return (CGFloat (M_PI) * angle) / 180.0
}


func normalizeValue (value: CGFloat,
    min: CGFloat,
    max: CGFloat) -> CGFloat {
    return (max - min) / value
}


func convertNormalizedValue (value: CGFloat,
    min: CGFloat,
    max: CGFloat) -> CGFloat {
    return ((max - min) * value) + min
}



// MARK: - Block Classes


// MARK: - BlockButton

class BlockButton: UIButton {
    
    override init (frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var actionBlock: ((sender: BlockButton) -> ())? {
        didSet {
            self.addTarget(self, action: "action:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func action (sender: BlockButton) {
        actionBlock! (sender: sender)
    }
}



// MARK: - BlockWebView

class BlockWebView: UIWebView, UIWebViewDelegate {
    
    var didStartLoad: ((NSURLRequest) -> ())?
    var didFinishLoad: ((NSURLRequest) -> ())?
    var didFailLoad: ((NSURLRequest, NSError) -> ())?
    
    var shouldStartLoadingRequest: ((NSURLRequest) -> (Bool))?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func webViewDidStartLoad(webView: UIWebView) {
        didStartLoad? (webView.request!)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        didFinishLoad? (webView.request!)
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        didFailLoad? (webView.request!, error)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let should = shouldStartLoadingRequest {
            return should (request)
        } else {
            return true
        }
    }
    
}


func nsValueForAny(anyValue:Any) -> NSObject? {
    switch(anyValue) {
    case let intValue as Int:
        return NSNumber(int: CInt(intValue))
    case let doubleValue as Double:
        return NSNumber(double: CDouble(doubleValue))
    case let stringValue as String:
        return stringValue as NSString
    case let boolValue as Bool:
        return NSNumber(bool: boolValue)
    default:
        return nil
    }
}

extension NSObject{
    public class var nameOfClass: String{
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    public var nameOfClass: String{
        return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
    }

    func listProperties() -> Dictionary<String,AnyObject>{
        var mirror=reflect(self)
        var modelDictionary = Dictionary<String,AnyObject>()
        
        for (var i=0;i<mirror.count;i++)
        {
            if (mirror[i].0 != "super")
            {
                if let nsValue = nsValueForAny(mirror[i].1.value) {
                    modelDictionary.updateValue(nsValue, forKey: mirror[i].0)
                }
            }
        }
        return modelDictionary
    }
    
}


func isEmpty<C : NSObject>(x: C) -> Bool {
    if x.isKindOfClass(NSNull) {
        return true
    }else if x.respondsToSelector(Selector("length")) && NSData().self.length == 0 {
        return true
    }else if x.respondsToSelector(Selector("count")) && NSArray().self.count == 0 {
        return true
    }
    return false
}



