//
//  MovieGenreCollectionViewCell.swift
//  TheCinema
//
//  Created by SatGatLee on 21/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

class MovieGenreCollectionViewCell: UICollectionViewCell { //장르 별 카테고리셀
  static let cellIdentifier: String = String(describing: MovieGenreCollectionViewCell.self)
  lazy var genreImage: UIImageView = UIImageView().then {
    $0.layer.cornerRadius = 10
    $0.clipsToBounds = true
  }
  
  lazy var genreTitle: UILabel = UILabel().then {
    $0.textAlignment = .center
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFB", size: 15)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    layoutSetUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
extension MovieGenreCollectionViewCell {
  
  private func layoutSetUp() {
    [genreImage, genreTitle].forEach { self.contentView.addSubview($0) }
    
    constrain(genreImage) {
      $0.left    == $0.superview!.left
      $0.right   == $0.superview!.right
      $0.height  == 100
      $0.top     == $0.superview!.top
    }
    
    constrain(genreTitle, genreImage) {
      $0.top     == $1.bottom + 10
      $0.centerX == $1.centerX
    }
  }
  
  func config(type: MovieGenreType) {
    genreImage.image = type.image
    genreTitle.text = type.rawValue
  }
}
