//
//  MovieSearchPanelV.swift
//  TheCinema
//
//  Created by ChLee on 30/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

class MovieSearchPanelView: UIView {
  lazy var searchIcn: UIImageView = UIImageView().then {
    $0.image = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
    $0.tintColor = MainManager.SI.textColor
  }
  
  lazy var searchField: UITextField = UITextField().then {
    $0.borderStyle = .none
    $0.backgroundColor = .clear
    $0.placeholder = "영화 이름을 검색해주세요"
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFR", size: 15)
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    layoutSetUp()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init() error")
  }
}
extension MovieSearchPanelView {
  private func layoutSetUp() {
    [searchIcn, searchField].forEach { self.addSubview($0) }
    
    constrain(searchIcn) {
      $0.width   == 16
      $0.height  == $0.width
      $0.centerY == $0.superview!.centerY
      $0.left    == $0.superview!.left + 10
    }
    
    constrain(searchField, searchIcn) {
      $0.left    == $1.right + 10
      $0.centerY == $0.superview!.centerY
      $0.right   == $0.superview!.right
    }
  }
}
