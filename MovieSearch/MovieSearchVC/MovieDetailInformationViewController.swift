//
//  MovieDetailInformationVC.swift
//  TheCinema
//
//  Created by ChLee on 27/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

enum MovieDetailType: String {
  case summary = "요약정보"
  case plot = "줄거리"
  case stills = "스틸샷"
  case comment = "최근 리뷰"
  
  static var arrays: [MovieDetailType] {
    return [.summary, .plot, stills, .comment]
  }
}
class MovieDetailInformationViewController: UIViewController { //영화 상세정보 ( 리뷰 즐겨찾기 ) KMDB API 사용해서 전체적인 데이터를 즉시 표현
  //데이터 들어오면 리뷰랑 즐겨찾기 가져온다. 영화 이름에 해당하는 코멘트만.
  //테이블 뷰 섹션 멀티플로 구성.
  lazy var movieInfoTable: UITableView = UITableView(frame: .zero, style: .grouped).then {
    $0.estimatedRowHeight = 50 // 기본은 이정도.. 셀마다 각자 지정예정이고 한줄평과 줄거리 감독출연등은 다이나믹
    $0.rowHeight = UITableView.automaticDimension
    $0.separatorStyle = .none
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    $0.register(MovieSummaryTableViewCell.self, forCellReuseIdentifier: MovieSummaryTableViewCell.cellIdentifier)
    $0.register(MoviePlotTableViewCell.self, forCellReuseIdentifier: MoviePlotTableViewCell.cellIdentifier)
    $0.register(MovieCommentTableViewCell.self, forCellReuseIdentifier: MovieCommentTableViewCell.cellIdentifier)
    $0.register(MovieStillShotTableViewCell.self, forCellReuseIdentifier: MovieStillShotTableViewCell.cellIdentifier)
  }
  
  lazy var favoriteBtn: UIButton = UIButton().then {
    $0.setImage(UIImage(named: "unFavorite"), for: .normal)
    $0.setImage(UIImage(named: "favorite"), for: .selected)
    $0.isHighlighted = false
  }
  
  var movieInformation: MovieGenreData = MovieGenreData(JSON: [:])! {
    didSet {
      //영화 코멘트들 가져오면서 데이터 바인드 및 리로드.
      
    }
  }
  
  private let viewModel: MovieCommentViewModelType = MovieCommentViewModel()
  private let searchViewModel: MovieSearchViewModelType = MovieSearchViewModel()
  private var commentList: BehaviorRelay<[MovieComment]> = BehaviorRelay<[MovieComment]>(value: [])
  private let disposeBag: DisposeBag = DisposeBag()
  
  override func viewWillAppear(_ animated: Bool) {
    
    //들어왔는데 데이터가 없으면..... 파싱을 해와야한다.이건 나중에 할까....그럼 의미가 업센 시바이밪
    guard movieInformation.title != "" else {
      searchViewModel.input.movieDetailSearch(seq: movieInformation.movieSeq)
      return
    }
    viewModel.inputs.myFavorite(seq: movieInformation.movieSeq)
    viewModel.inputs.commentList(seq: movieInformation.movieSeq, recent: true)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    layoutSetUp()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteBtn)
    
    bind()
  }
}
extension MovieDetailInformationViewController {
  private func layoutSetUp() {
    view.addSubview(movieInfoTable)
    
    constrain(movieInfoTable) {
      $0.edges == $0.superview!.edges
    }
    
    movieInfoTable.reloadData()
  }
  
  private func bind() {
    viewModel.outputs.comments.subscribe(onNext: { [weak self] (list) in
      self?.commentList.accept(list)
    }).disposed(by: disposeBag)
    
    commentList.asDriver(onErrorJustReturn: []) //댓글이 없어졌을 경우도 생각해서.
      .drive(onNext : { [weak self] _ in
        self?.movieInfoTable.reloadData()
      }).disposed(by: disposeBag)
    
    favoriteBtn.rx.tap.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        self.viewModel.inputs.favorite(info: self.movieInformation)
      }).disposed(by: disposeBag)
    
    viewModel.outputs.favoriteMovie.asDriver(onErrorJustReturn: false)
      .drive(favoriteBtn.rx.isSelected).disposed(by: disposeBag)
    
    viewModel.outputs.favoriteEnabled.asDriver(onErrorJustReturn: false)
      .drive(favoriteBtn.rx.isSelected).disposed(by: disposeBag)
    
    searchViewModel.output.movieInfo.asDriver(onErrorJustReturn: MovieGenreData(JSON: [:])!)
      .drive(onNext: { [weak self] info in
        guard let self = self else { return }
        self.movieInformation = info
        self.viewModel.inputs.commentList(seq: self.movieInformation.movieSeq, recent: true) //데이터 가져왔으면 코멘트도 가져온다.
        
      }).disposed(by: disposeBag)
  }
}

extension MovieDetailInformationViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 3 ? commentList.value.count : 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0: //요약정보
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieSummaryTableViewCell.cellIdentifier, for: indexPath) as? MovieSummaryTableViewCell else { return UITableViewCell()}
      cell.config(info: movieInformation)
      return cell
    case 1:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviePlotTableViewCell.cellIdentifier, for: indexPath) as? MoviePlotTableViewCell else { return UITableViewCell()}
      cell.plot.text = movieInformation.plot.split(separator: ".").joined(separator: ".\n\n")
      return cell
    case 2:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieStillShotTableViewCell.cellIdentifier, for: indexPath) as? MovieStillShotTableViewCell else { return UITableViewCell()}
      cell.stills.accept(movieInformation.stills.split(separator: "|").map{String($0)})
      return cell
    case 3:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCommentTableViewCell.cellIdentifier, for: indexPath) as? MovieCommentTableViewCell else { return UITableViewCell()}
      cell.config(data: commentList.value[indexPath.row])
      return cell
    default:break
    }
    return UITableViewCell()
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let v = MovieDetailHeaderView(text: MovieDetailType.arrays[section].rawValue)
    v.btn.isHidden = section != 3
    v.btn.rx.tap.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        let vc = MovieCommentViewController()
        vc.movieId = self.movieInformation.movieSeq
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
      }).disposed(by: disposeBag)
    return v
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let v: UIView = UIView()
    v.backgroundColor = .clear
    return v
  }
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return section == 3 ? 0 : 10
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.section == 2 ? 200 : UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.alpha = 0
    
    UIView.animate(withDuration: 0.5) {
      cell.alpha = 1
    }
  }
}
