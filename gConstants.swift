//
//  gConstants.swift
//  TheCinema
//
//  Created by SatGatLee on 21/07/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

var screenWidth: CGFloat = UIScreen.main.bounds.width
var screenHeight: CGFloat = UIScreen.main.bounds.height

public func iPrint(_ objects:Any... , filename:String = #file,_ line:Int = #line, _ funcname:String = #function){ //debuging Print
  #if DEBUG
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "HH:mm:ss:SSS"
  let file = URL(string:filename)?.lastPathComponent.components(separatedBy: ".").first ?? ""
  print("💦info 🦋\(dateFormatter.string(from:Date())) 🌞\(file) 🍎line:\(line) 🌹\(funcname)🔥",terminator:"")
  for object in objects{
    print(object, terminator:"")
  }
  print("\n")
  #endif
}
