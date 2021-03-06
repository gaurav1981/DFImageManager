// Playground - noun: a place where people can play

import UIKit
import DFImageManagerKit
import XCPlayground

// WARNING: DFImageManager Swift interfaces are automatically generated by Xcode.

let manager = DFImageManager.sharedManager()

let imageURL = NSURL(string: "http://farm8.staticflickr.com/7315/16455839655_7d6deb1ebf_z_d.jpg")!

// Request fullsize image
manager.requestImageForResource(imageURL) { (image: UIImage!, [NSObject : AnyObject]!) -> Void in
    var fetchedImage = image
}

// Request scaled image
let request = DFImageRequest(resource: imageURL, targetSize: CGSize(width: 100, height: 100), contentMode: .AspectFill, options: nil)
manager.requestImageForRequest(request) { (image: UIImage!, [NSObject : AnyObject]!) -> Void in
    var fetchedImage = image
}

XCPSetExecutionShouldContinueIndefinitely()
