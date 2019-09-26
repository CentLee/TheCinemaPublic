//
//  MovieStillShotTableViewCell.swift
//  TheCinema
//
//  Created by ChLee on 29/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import FSPagerView

class MovieStillShotTableViewCell: UITableViewCell { //스틸샷 셀
  static let cellIdentifier: String = String(describing: MovieStillShotTableViewCell.self)
  
  lazy var stillPager: FSPagerView = FSPagerView().then {
    $0.dataSource = self
    $0.register(MovieGenrePagerCell.self, forCellWithReuseIdentifier: MovieGenrePagerCell.cellIdentifier)
    $0.backgroundColor = .clear
    $0.transformer = FSPagerViewTransformer(type: .crossFading)
    $0.itemSize = CGSize(width: screenWidth, height: 200)
  }
  
  var stills: BehaviorRelay<[String]> = BehaviorRelay<[String]>(value: [])
  private let disposeBag: DisposeBag = DisposeBag()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    layoutSetUp()
    bind()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
extension MovieStillShotTableViewCell {
  private func layoutSetUp() {
    contentView.addSubview(stillPager)
    
    constrain(stillPager) {
      $0.edges == $0.superview!.edges
    }
  }
  
  private func bind() {
    stills.filter{!$0.isEmpty}.asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] _ in
        self?.stillPager.reloadData()
      }).disposed(by: disposeBag)
  }
}
extension MovieStillShotTableViewCell: FSPagerViewDataSource {
  func numberOfItems(in pagerView: FSPagerView) -> Int {
    return stills.value.count
  }
  
  func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: MovieGenrePagerCell.cellIdentifier, at: index) as? MovieGenrePagerCell else { return FSPagerViewCell() }
    cell.configPage(movie: stills.value[index])
    return cell
  }
}
