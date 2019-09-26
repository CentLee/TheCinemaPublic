//
//  MovieSearchVC.swift
//  TheCinema
//
//  Created by SatGatLee on 21/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

class MovieSearchViewController: UIViewController { //장르별 검색 및 단일 검색
  
  lazy var movieSearchView: MovieSerachView = MovieSerachView().then {
    $0.backgroundColor = MainManager.SI.bgColor
  }
  
  private let viewModel: MovieGenreSearchViewModelType = MovieGenreSearchViewModel()
  private let disposeBag: DisposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MainManager.SI.bgColor
    title = "검색"
    layoutSetUp()
    bind()
    MainManager.SI.navigationAppearance(navi: navigationController)
  }
}
extension MovieSearchViewController {
  private func layoutSetUp() {
    view.addSubview(movieSearchView)
    
    constrain(movieSearchView) {
      $0.edges == $0.superview!.safeAreaLayoutGuide.edges
    }
  }
  
  private func bind() {
    movieSearchView.genreCollection.dataSource = nil
    
    Observable.just(MovieGenreType.arrays).asDriver(onErrorJustReturn: [])
      .drive(movieSearchView.genreCollection.rx.items(cellIdentifier: MovieGenreCollectionViewCell.cellIdentifier, cellType: MovieGenreCollectionViewCell.self)) { (row, viewModel, userCell) in
        userCell.config(type: MovieGenreType.arrays[row])
        //userCell.config(dic: self.genre[row])
      }.disposed(by: disposeBag)
    
    movieSearchView.genreCollection.rx.itemSelected
      .asDriver(onErrorJustReturn: IndexPath(row: 0, section: 0))
      .drive(onNext: { [weak self] (indexPath) in
        guard let self = self else { return }
        let vc = MovieGenreViewController()
        vc.genre = MovieGenreType.arrays[indexPath.row].rawValue
        self.navigationController?.pushViewController(vc, animated: true)
        self.viewModel.inputs.genreClick(genre: MovieGenreType.arrays[indexPath.row].rawValue)
      }).disposed(by: disposeBag)
    
    movieSearchView.searchPanel.searchField.rx.controlEvent(.editingDidBegin).asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        let vc = MovieDetailSearchViewController()
        self?.navigationController?.pushViewController(vc, animated: true)
        self?.movieSearchView.searchPanel.searchField.resignFirstResponder()
        vc.searchPanel.searchField.becomeFirstResponder()
      }).disposed(by: disposeBag)
  }
}

