//
//  MovieDetailSearchVC.swift
//  TheCinema
//
//  Created by ChLee on 30/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import FSPagerView

class MovieDetailSearchViewController: UIViewController { //단일 검색 후 리스트 보여주는 뷰. Naver Search Api 사용
  
  lazy var searchPanel: MovieSearchPanelView = MovieSearchPanelView().then {
    $0.backgroundColor = MainManager.SI.bgColor
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1.5
    $0.layer.borderColor = MainManager.SI.textColor.cgColor
  }
  
  lazy var movieTable: UITableView = UITableView().then {
    $0.register(MovieSearchDetailTableViewCell.self, forCellReuseIdentifier: MovieSearchDetailTableViewCell.cellIdentifier)
    $0.separatorStyle = .none
    $0.rowHeight = 120
    $0.backgroundColor = MainManager.SI.tableColor
  }
  
  private let disposeBag: DisposeBag = DisposeBag()
  private let viewModel: MovieSearchViewModelType = MovieSearchViewModel()
  private var movieList: BehaviorRelay<[MovieData]> = BehaviorRelay<[MovieData]>(value: [])
  var startIndex: Int = 1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MainManager.SI.bgColor
    layoutSetUp()
    bind()
  }
}

extension MovieDetailSearchViewController {
  private func layoutSetUp() {
    title = "영화 검색"
    [searchPanel, movieTable].forEach { self.view.addSubview($0) }
    
    constrain(searchPanel) {
      $0.top    == $0.superview!.safeAreaLayoutGuide.top + 10
      $0.left   == $0.superview!.left + 10
      $0.right  == $0.superview!.right - 10
      $0.height == 40
    }
    
    constrain(movieTable, searchPanel) {
      $0.top    == $1.bottom + 10
      $0.left   == $0.superview!.left
      $0.right  == $0.superview!.right
      $0.bottom == $0.superview!.bottom
    }
  }
  
  private func bind() { //dataSource And dataBinding
    searchPanel.searchField.rx.text.filter{$0 != ""}
      .debounce(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: nil)
      .drive(onNext: { [weak self] (str) in
        guard let self = self else { return }
        self.viewModel.input.movieSearch(title: str!, start: self.startIndex) //값이 존재한다는 가정.
      }).disposed(by: disposeBag)
    
    viewModel.output.movieList.bind(to: movieList).disposed(by: disposeBag) //스트림 넘기고.
    
    movieList.filter{!$0.isEmpty}.asDriver(onErrorJustReturn: [])
      .drive(movieTable.rx.items(cellIdentifier: MovieSearchDetailTableViewCell.cellIdentifier, cellType: MovieSearchDetailTableViewCell.self)) { (row, movie, cell) in
        cell.config(info: movie)
      }.disposed(by: disposeBag)
    
    movieTable.rx.willDisplayCell.asDriver(onErrorJustReturn: (cell: UITableViewCell(), indexPath: IndexPath()))
      .drive(onNext: { (cell, _) in
        cell.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
          cell.alpha = 1
        })
      }).disposed(by: disposeBag)
    
    movieTable.rx.itemSelected.asDriver(onErrorJustReturn: IndexPath())
      .drive(onNext: { [weak self] (indexPath) in
        //웹뷰로 네이버 연동.
        guard let self = self else { return }
        let vc = MovieLinkViewController()
        vc.title = self.movieList.value[indexPath.row].title
        vc.urlRequest = URLRequest(url: URL(string: self.movieList.value[indexPath.row].link)!)
        self.navigationController?.pushViewController(vc, animated: true)
        self.searchPanel.searchField.text?.removeAll()
        self.searchPanel.searchField.resignFirstResponder()
      }).disposed(by: disposeBag)
  }
}
