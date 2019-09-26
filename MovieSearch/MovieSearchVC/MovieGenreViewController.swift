//
//  MovieGenreVC.swift
//  TheCinema
//
//  Created by SatGatLee on 22/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import FSPagerView

class MovieGenreViewController: UIViewController { //장르별 영화를 보여주는 페이지뷰 KMdb api 사용
  lazy var movieGenrePageView: FSPagerView = FSPagerView().then {
    $0.register(MovieGenrePagerCell.self, forCellWithReuseIdentifier: MovieGenrePagerCell.cellIdentifier)
    $0.backgroundColor = .clear
    $0.transformer = FSPagerViewTransformer(type: .linear)
    $0.itemSize = CGSize(width: screenWidth / 1.5, height: 290)
    $0.delegate = self
    $0.dataSource = self
  }
  
  lazy var backImageView: UIImageView = UIImageView()
  
  //데이터 받아와서 릴레이에 최신화 하면서 그걸 바인드 시키는 것.
  private var genreList: BehaviorRelay<[MovieGenreData]> = BehaviorRelay<[MovieGenreData]>(value: [])
  private var startCount: Int = 0
  private let viewModel: MovieGenreSearchViewModelType = MovieGenreSearchViewModel()
  private let disposeBag: DisposeBag = DisposeBag()
  private var previousIndex: Int = 0
  var genre: String = "" {
    didSet {
      self.viewModel.inputs.genreMovie(start: "0", genre: genre)
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    // Do any additional setup after loading the view.
    layoutSetUp()
    bindViewModel()
  }
}
extension MovieGenreViewController {
  private func layoutSetUp() {
    view.addSubview(backImageView)
    view.addSubview(movieGenrePageView)
    
    constrain(backImageView) {
      $0.edges == $0.superview!.edges
    }
    
    constrain(movieGenrePageView) {
      $0.left    == $0.superview!.left
      $0.right   == $0.superview!.right
      $0.height  == 300
      $0.centerY == $0.superview!.centerY
    }
  }
  
  private func bindViewModel() {
    
    viewModel.outputs.genreList.asDriver(onErrorJustReturn: MovieGenreResult(JSON: [:])!)
      .drive(onNext: { [weak self] (movieResult) in
        guard let self = self else { return }
        self.startCount += movieResult.movies.count
        self.genreList.accept(self.genreList.value + movieResult.movies)
        self.movieGenrePageView.reloadData()
      }).disposed(by: disposeBag)
  }
  
  private func backImage(image: String) {
    backImageView.URLString(urlString: image)
  }
}
extension MovieGenreViewController: FSPagerViewDataSource, FSPagerViewDelegate {
  func numberOfItems(in pagerView: FSPagerView) -> Int {
    return genreList.value.count
  }
  
  func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
    guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: MovieGenrePagerCell.cellIdentifier, at: index) as? MovieGenrePagerCell else { return FSPagerViewCell() }
    if index == 0 {
      self.backImage(image: genreList.value[0].poster)
    }
    cell.configPage(movie: genreList.value[index])
    return cell
  }
  
  func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
    if previousIndex != targetIndex && previousIndex != genreList.value.count - 1 {
      backImage(image: genreList.value[targetIndex].poster)
    }
    previousIndex = targetIndex
  }
  
  func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
    if index == genreList.value.count - 1 {
      viewModel.inputs.genreMovie(start: "\(startCount)", genre: genre)
    }
  }
  
  func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
    let vc = MovieDetailInformationViewController()
    vc.movieInformation = genreList.value[index]
    navigationController?.pushViewController(vc, animated: true)
    pagerView.deselectItem(at: index, animated: true)
  }
}
