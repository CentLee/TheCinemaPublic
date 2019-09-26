//
//  UserMenuViewController.swift
//  TheCinema
//
//  Created by ChLee on 04/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class UserMenuViewController: UIViewController { //유저 탭 즐겨 찾기 & 조회수 높은 장르 탑 3, 유저 프로필 편집.
  lazy var userMenuView: UserMenuView = UserMenuView().then {
    $0.backgroundColor = MainManager.SI.bgColor//UIColor(hexString: "#F8D1D1")
    $0.layer.borderWidth = 3
    $0.layer.borderColor = UIColor(hexString: "#F8D1D1").cgColor
  }
  
  lazy var favoriteTable: UITableView = UITableView().then {
    $0.separatorStyle = .none
    $0.rowHeight = 120
    $0.register(MovieSearchDetailTableViewCell.self, forCellReuseIdentifier: MovieSearchDetailTableViewCell.cellIdentifier)
    $0.backgroundColor = MainManager.SI.tableColor
    $0.isHidden = true
  }
  
  lazy var genreTopTable: UITableView = UITableView().then {
    $0.separatorStyle = .none
    $0.rowHeight = 120
    $0.register(MovieSearchDetailTableViewCell.self, forCellReuseIdentifier: MovieSearchDetailTableViewCell.cellIdentifier)
    $0.backgroundColor = MainManager.SI.tableColor
    $0.isHidden = true
  }
  
  lazy var menuBtn: UIButton = UIButton().then {
    $0.setImage(UIImage(named: "ic_list"), for: .normal)
  }
  
  lazy var menuDimView: UIView = UIView().then {
    $0.backgroundColor = MainManager.SI.textColor.withAlphaComponent(0.8)
  }
  
  private let viewModel: UserMenuViewModelType = UserMenuViewModel()
  private let disposeBag: DisposeBag = DisposeBag()
  
  var leftConstraint: NSLayoutConstraint = NSLayoutConstraint() //메뉴 넓이 제약
  var favoriteList: BehaviorRelay<[MovieFavoriteData]> = BehaviorRelay<[MovieFavoriteData]>(value: [])
  var genreTopList: BehaviorRelay<[GenreTotalData]> = BehaviorRelay<[GenreTotalData]>(value: [])
  var currentType: BehaviorRelay<UserMenuType?> = BehaviorRelay<UserMenuType?>(value: nil)
  
  override func viewDidLoad() { //버튼 누를 때 마다 값들 가져오기.
    super.viewDidLoad()
    navigationController?.navigationBar.topItem?.title = "유저 메뉴"
    view.backgroundColor = MainManager.SI.tableColor
    layoutSetUp()
    navigationSetUp()
    MainManager.SI.navigationAppearance(navi: navigationController)
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    iPrint(MainManager.SI.userInfo.userProfileImage)
    userMenuView.userProfile.URLString(urlString: MainManager.SI.userInfo.userProfileImage)
    userMenuView.userName.text = MainManager.SI.userInfo.userName
  }
}
extension UserMenuViewController {
  private func layoutSetUp() {
    [favoriteTable, genreTopTable, userMenuView].forEach { self.view.addSubview($0) }
    
    constrain(userMenuView) {
      leftConstraint = ($0.left   == $0.superview!.left - 4000)
      $0.top    == $0.superview!.safeAreaLayoutGuide.top
      $0.bottom == $0.superview!.safeAreaLayoutGuide.bottom
      $0.width  == screenWidth / 1.5
    }
    
    constrain(favoriteTable) {
      $0.edges == $0.superview!.safeAreaLayoutGuide.edges
    }
    
    constrain(genreTopTable) {
      $0.edges == $0.superview!.safeAreaLayoutGuide.edges
    }
    
    //    constrain(menuDimView) {
    //      $0.top    == $0.superview!.top
    //      $0.width  == screenWidth
    //      $0.bottom == $0.superview!.bottom
    //      leftConstraint = ($0.left   == $0.superview!.left - 4000)
    //    }
  }
  
  private func navigationSetUp() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuBtn)
  }
  
  private func bind() {
    //userMenuContentTable.dataSource = nil
    menuBtn.rx.tap
      .map{ [weak self] () -> Bool in
        guard let self = self else { return false}
        self.menuBtn.isSelected = !self.menuBtn.isSelected
        return self.menuBtn.isSelected
      }
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] (selected) in
        guard let self = self else { return }
        guard !selected else {
          self.userMenuView.frame.origin.x = -4000
          UIView.animate(withDuration: 0.5, animations: {
            self.leftConstraint.constant = 0
            self.userMenuView.frame.origin.x = 0
            //self.menuDimView.isHidden = false
            self.view.layoutIfNeeded()
          })
          return
        }
        self.userMenuView.frame.origin.x = -4000
      }).disposed(by: disposeBag)
    
    
    //    menuDimView.rx.tapGesture().when(.recognized).asDriver(onErrorJustReturn: UITapGestureRecognizer())
    //      .drive(onNext: { [weak self] _ in
    //        guard let type = self?.currentType.value else {
    //          self?.clearContext(type: .userMenu)
    //          return
    //        }
    //        self?.clearContext(type: type)
    //      }).disposed(by: disposeBag)
    
    userMenuView.menuTable.rx.itemSelected.asDriver(onErrorJustReturn: IndexPath())
      .drive(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        switch indexPath.row {
        case 0: //즐겨찾기
          self.viewModel.input.favoriteList()
          self.clearContext(type: UserMenuType.arrays[0])
        case 1:
          self.viewModel.input.inquiryTopList()
          self.clearContext(type: UserMenuType.arrays[1])
        case 2:
          self.clearContext(type: UserMenuType.arrays[2])
          let vc = UserProfileEditViewController()
          self.navigationController?.pushViewController(vc, animated: true)
        case 3://logout
          do  {
            try Auth.auth().signOut()
            MainManager.SI.userInfo = UserInformation(JSON: [:])!
            self.tabBarController?.dismiss(animated: true, completion: nil)
            //self.navigationController?.popToRootViewController(animated: true)
          } catch(let err) {
            iPrint(err.localizedDescription)
          }
        default: break
        }
      }).disposed(by: disposeBag)
    
    viewModel.output.favoriteMovies
      .map { [weak self] list -> [MovieFavoriteData] in
        guard !list.isEmpty else {
          //경고창
          self?.notificationBanner(text: "즐겨찾기 데이터가 없습니다. 등록 후 이용 바랍니다.")
          return []
        }
        self?.favoriteTable.isHidden = false
        self?.genreTopTable.isHidden = true
        return list
      }
      .bind(to: favoriteList).disposed(by: disposeBag)
    
    viewModel.output.genreTopList
      .map { [weak self] list -> [GenreTotalData] in
        guard !list.isEmpty else {
          //경고창
          self?.notificationBanner(text: "즐겨찾기 데이터가 없습니다. 등록 후 이용 바랍니다.")
          return []
        }
        self?.favoriteTable.isHidden = true
        self?.genreTopTable.isHidden = false
        return list
      }.bind(to: genreTopList).disposed(by: disposeBag)
    
    favoriteList.filter{!$0.isEmpty}
      .asDriver(onErrorJustReturn: [])
      .drive(favoriteTable.rx.items(cellIdentifier: MovieSearchDetailTableViewCell.cellIdentifier, cellType: MovieSearchDetailTableViewCell.self)) {
        (row, movie, cell) in
        cell.config(info: movie)
      }.disposed(by: disposeBag)
    
    genreTopList.filter{!$0.isEmpty}
      .asDriver(onErrorJustReturn: [])
      .drive(genreTopTable.rx.items(cellIdentifier: MovieSearchDetailTableViewCell.cellIdentifier, cellType: MovieSearchDetailTableViewCell.self)) {
        (row, genre, cell) in
        cell.config(info: genre)
      }.disposed(by: disposeBag)
    
    favoriteTable.rx.itemSelected.asDriver(onErrorJustReturn: IndexPath())
      .drive(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        let vc = MovieDetailInformationViewController()
        vc.movieInformation.movieSeq = self.favoriteList.value[indexPath.row].movieSeq
        self.navigationController?.pushViewController(vc, animated: true)
        self.favoriteTable.deselectRow(at: indexPath, animated: false)
        self.clearContext(type: UserMenuType.favorite)
      }).disposed(by: disposeBag)
    
    genreTopTable.rx.itemSelected.asDriver(onErrorJustReturn: IndexPath())
      .drive(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        let vc = MovieGenreViewController()
        vc.genre = self.genreTopList.value[indexPath.row].genreName
        self.navigationController?.pushViewController(vc, animated: true)
        self.genreTopTable.deselectRow(at: indexPath, animated: false)
        self.clearContext(type: UserMenuType.favorite)
      }).disposed(by: disposeBag)
  }
  
  private func clearContext(type: UserMenuType) {
    title = type.rawValue
    userMenuView.frame.origin.x = -4000
    leftConstraint.constant = -4000
    menuBtn.isSelected = !menuBtn.isSelected
    self.currentType.accept(type)
    view.layoutIfNeeded()
  }
  
  private func notificationBanner(text: String) {
    let banner = FloatingNotificationBanner(title: "데이터", subtitle: text, titleFont: UIFont(name: "NanumSquareOTFEB", size: 15)!, subtitleFont: UIFont(name: "NanumSquareOTFR", size: 13)!, style: .warning)
    banner.show(on: self)
  }
}
