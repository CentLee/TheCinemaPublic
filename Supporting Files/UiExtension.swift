//
//  UiExtension.swift
//  TheCinema
//
//  Created by SatGatLee on 08/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

extension UIButton {
  func URLString(urlString: String, state: UIControl.State) {
    guard urlString != "" else {
      setImage(UIImage(named: "profileEdit"), for: .normal)
      return
    }
    let url = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let img_url = URL(string: url) else { return }
    
    let resource = ImageResource(downloadURL: img_url, cacheKey: url)
    kf.setImage(with: resource, for: state)
  }
}
extension UIImageView {
  func URLString(urlString: String) {
    guard urlString != "" else {
      self.image = UIImage(named: "movieEmpty")
      return
    }
    let url = String(urlString.split(separator: "|")[0]).trimmingCharacters(in: .whitespacesAndNewlines)
    guard let img_url = URL(string: url) else { return }
    
    let resource = ImageResource(downloadURL: img_url, cacheKey: url)
    
    kf.setImage(with: resource)
  }
}
extension UIColor {
  convenience init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted)
    var int = UInt32()
    Scanner(string: hex).scanHexInt32(&int)
    let a, r, g, b: UInt32
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}
