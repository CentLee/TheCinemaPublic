//
//  UserMenuTableViewCell.swift
//  TheCinema
//
//  Created by ChLee on 04/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

enum UserMenuType: String {
  case favorite = "즐겨찾는 영화"
  case inquiryTop = "조회수 탑 장르"
  case profileEdit = "프로필 편집"
  case logout = "로그아웃"
  static var arrays: [UserMenuType] {
    return [.favorite, .inquiryTop, .profileEdit, .logout]
  }
  
  var image: UIImage {
    return UIImage(named: "\(self)")!
  }
}

class UserMenuTableViewCell: UITableViewCell { //조회율 높은 장르에도 같이 쓰는 셀
  static let cellIdentifier: String = String(describing: UserMenuTableViewCell.self)
  
  lazy var menuIcn: UIImageView = UIImageView().then {
    $0.layer.cornerRadius = 10
  }
  lazy var menuTitle: UILabel = UILabel().then {
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFB", size: 15)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    layoutSetUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
extension UserMenuTableViewCell {
  private func layoutSetUp() {
    [menuIcn, menuTitle].forEach { self.contentView.addSubview($0) }
    
    constrain(menuIcn) {
      $0.centerY == $0.superview!.centerY
      $0.width   == 32
      $0.height  == $0.width
      $0.left    == $0.superview!.left + 10
    }
    
    constrain(menuTitle, menuIcn) {
      $0.left    == $1.right + 10
      $0.centerY == $1.centerY
    }
  }
}

class UserMenuTableViewDataSource: NSObject ,UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return UserMenuType.arrays.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: UserMenuTableViewCell.cellIdentifier, for: indexPath) as? UserMenuTableViewCell else { return UITableViewCell() }
    cell.menuIcn.image = UserMenuType.arrays[indexPath.row].image
    cell.menuTitle.text = UserMenuType.arrays[indexPath.row].rawValue
    cell.selectionStyle = .none
    return cell
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
}

class UserMenuTableViewDelegate: NSObject, UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return MovieDetailHeaderView(text: "메뉴")
  }
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
  }
}
