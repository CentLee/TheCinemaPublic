//
//  BackContentV.swift
//  TheCinema
//
//  Created by ChLee on 02/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

class BackContentView: UIView { //카드뷰
  @IBInspectable var cornerRadius: CGFloat = 8
  @IBInspectable var shadowcolor: UIColor? = UIColor.black
  @IBInspectable let shadowOffSetWidth : Int = 0
  @IBInspectable let shadowOffSetHeight : Int = 1
  @IBInspectable var shadowopacity: Float = 0.2
  
  override func layoutSubviews() {
    layer.cornerRadius = cornerRadius
    layer.shadowColor = shadowcolor?.cgColor
    layer.shadowOffset = CGSize(width: shadowOffSetWidth, height: shadowOffSetHeight)
    let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
    layer.shadowPath = shadowPath.cgPath
    layer.shadowOpacity = shadowopacity
  }
}
