//
//  MovieGenrePagerCell.swift
//  TheCinema
//
//  Created by SatGatLee on 24/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import FSPagerView

class MovieGenrePagerCell: FSPagerViewCell { //영화 장르 셀
  static let cellIdentifier: String = String(describing: MovieGenrePagerCell.self)
  lazy var backV: UIView = UIView().then {
    $0.layer.cornerRadius = 10
    $0.clipsToBounds = true
    $0.backgroundColor = MainManager.SI.bgColor
  }
  
  lazy var moviePoster: UIImageView = UIImageView()
  
  lazy var movieTitle: UILabel = UILabel().then {
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFB", size: 15)
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    layoutSetUp()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init() error")
  }
}
extension MovieGenrePagerCell {
  private func layoutSetUp() {
    contentView.addSubview(backV)
    [moviePoster, movieTitle].forEach { self.backV.addSubview($0) }
    
    constrain(backV) {
      $0.edges == $0.superview!.edges
    }
    
    constrain(moviePoster) {
      $0.left   == $0.superview!.left
      $0.right  == $0.superview!.right
      $0.top    == $0.superview!.top
      $0.bottom == $0.superview!.bottom
    }
    
    constrain(movieTitle) {
      $0.centerX == $0.superview!.centerX
      $0.top     == $0.superview!.top + 10
    }
    
  }
  
  func configPage<T>(movie: T) {
    if let genreData: MovieGenreData = movie as? MovieGenreData {
      movieTitle.text = genreData.poster == "" ? genreData.title : ""
      moviePoster.URLString(urlString: genreData.poster)
    }
      
    else if let stills: String = movie as? String {
      moviePoster.URLString(urlString: stills)
      backV.layer.cornerRadius = 0
    }
    
    //else if let
  }
  
  override func prepareForReuse() {
    movieTitle.text = ""
  }
}
