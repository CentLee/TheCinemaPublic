//
//  UserMenuView.swift
//  TheCinema
//
//  Created by ChLee on 04/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

class UserMenuView: UIView {
  lazy var userInfoView: UIView = UIView().then {
    $0.backgroundColor = MainManager.SI.bgColor
  }
  lazy var userProfile: UIImageView = UIImageView().then {
    $0.layer.cornerRadius = 25
    $0.clipsToBounds = true
  }
  lazy var userName: UILabel = UILabel().then {
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFB", size: 15)
  }
  
  lazy var menuTable: UITableView = UITableView(frame: .zero, style: .grouped).then {
    $0.rowHeight = 50
    $0.register(UserMenuTableViewCell.self, forCellReuseIdentifier: UserMenuTableViewCell.cellIdentifier)
    $0.backgroundColor = MainManager.SI.tableColor
  }
  var datasource: UserMenuTableViewDataSource?
  var delegate: UserMenuTableViewDelegate?
  override init(frame: CGRect) {
    super.init(frame: .zero)
    layoutSetUp()
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
extension UserMenuView {
  private func layoutSetUp() {
    [userInfoView, menuTable].forEach { self.addSubview($0) }
    [userProfile, userName].forEach { self.userInfoView.addSubview($0) }
    
    constrain(userInfoView) {
      $0.left   == $0.superview!.left
      $0.right  == $0.superview!.right
      $0.top    == $0.superview!.top
      //$0.width  == $0.superview!.width
      $0.height == 100
    }
    
    constrain(userProfile) {
      $0.centerY == $0.superview!.centerY
      $0.left    == $0.superview!.left + 20
      $0.width   == 50
      $0.height  == $0.width
    }
    
    constrain(userName, userProfile) {
      $0.left    == $1.right + 10
      $0.centerY == $1.centerY
    }
    
    constrain(menuTable, userInfoView) {
      $0.top    == $1.bottom
      $0.left   == $0.superview!.left
      $0.right  == $0.superview!.right
      $0.bottom == $0.superview!.bottom
    }
    userProfile.URLString(urlString: MainManager.SI.userInfo.userProfileImage)
    userName.text = MainManager.SI.userInfo.userName
    
    datasource = UserMenuTableViewDataSource()
    delegate = UserMenuTableViewDelegate()
    menuTable.dataSource = datasource
    menuTable.delegate = delegate
    menuTable.reloadData()
  }
}
