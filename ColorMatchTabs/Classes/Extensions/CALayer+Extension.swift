//
//  CALayer+Extension.swift
//  ColorMatchTabs
//
//  Created by Silvia Santos on 25/01/18.
//  Copyright © 2018 Yalantis. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
  
  func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
    
    let border = CALayer()
    
    switch edge {
    case UIRectEdge.top:
      border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
    case UIRectEdge.bottom:
      border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
    case UIRectEdge.left:
      border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
    case UIRectEdge.right:
      border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
    default:
      //For Center Line
      border.frame = CGRect(x: self.frame.width/2 - thickness, y: 0, width: thickness, height: self.frame.height)
    }
    
    border.backgroundColor = color.cgColor
    self.addSublayer(border)
  }
}

