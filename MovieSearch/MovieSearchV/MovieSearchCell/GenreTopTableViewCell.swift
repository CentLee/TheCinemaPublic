//
//  GenreTopTableViewCell.swift
//  TheCinema
//
//  Created by ChLee on 06/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

class GenreTopTableViewCell: UITableViewCell {
  static let cellIdentifier: String = String(describing: GenreTopTableViewCell.self)
  
  lazy var genreBackV: BackContentView = BackContentView().then {
    $0.layer.masksToBounds = false
    $0.backgroundColor = MainManager.SI.tableColor
  }
  
  lazy var genrePoster: UIImageView = UIImageView().then {
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
  }
  
  lazy var genreTitle: UILabel = UILabel().then {
    $0.lineBreakMode = .byTruncatingTail
    $0.numberOfLines = 0
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFB", size: 15)
  }

  lazy var genreCount: UILabel = UILabel().then {
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFR", size: 15)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    layoutSetUp()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
extension GenreTopTableViewCell {
  private func layoutSetUp() {
    contentView.addSubview(genreBackV)
    [genrePoster, genreTitle, genreCount].forEach { self.genreBackV.addSubview($0) }
    
    constrain(genreBackV) {
      $0.top    == $0.superview!.top + 10
      $0.left   == $0.superview!.left + 10
      $0.right  == $0.superview!.right - 10
      $0.bottom == $0.superview!.bottom - 10
    }
    
    constrain(genrePoster) {
      $0.top    == $0.superview!.top + 5
      $0.left   == $0.superview!.left + 5
      $0.bottom == $0.superview!.bottom - 5
      $0.width  == 100
    }
    
    constrain(genreTitle, genrePoster) {
      $0.top      == $1.top + 10
      $0.left     == $1.right + 10
      $0.right    == $0.superview!.right - 5
    }
    
    constrain(genreCount, genrePoster) {
      $0.left   == $1.right + 10
      $0.bottom == $1.bottom - 10
    }
    layoutIfNeeded()
  }
  
  func config(info: GenreTotalData) {
    genrePoster.image = MovieGenreType(rawValue: info.genreName)?.image
    genreTitle.text = info.genreName
    genreCount.text = "총 조회 수 : \(info.genreCount)"
  }
}

