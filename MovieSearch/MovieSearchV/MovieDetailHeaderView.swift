//
//  MovieDetailHeaderV.swift
//  TheCinema
//
//  Created by ChLee on 28/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

class MovieDetailHeaderView: UIView { //헤더 섹션 뷰
  
  lazy var title: UILabel = UILabel().then {
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFB", size: 15)
  }
  
  lazy var btn: UIButton = UIButton().then {
    $0.isHidden = true
    $0.setImage(UIImage(named: "btn_compose")!, for: .normal)
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
  }
  
  convenience init(text: String) {
    self.init(frame: .zero)
    title.text = text
    backgroundColor = MainManager.SI.bgColor
    layoutSetUp()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
extension MovieDetailHeaderView {
  private func layoutSetUp() {
    [title, btn].forEach { self.addSubview($0) }
    
    constrain(title) {
      $0.centerY == $0.superview!.centerY
      $0.left    == $0.superview!.left + 10
    }
    
    constrain(btn) {
      $0.centerY  == $0.superview!.centerY
      $0.right    == $0.superview!.right - 20
    }
  }
}
