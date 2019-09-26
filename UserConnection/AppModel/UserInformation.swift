//
//  UserInformation.swift
//  TheCinema
//
//  Created by SatGatLee on 03/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

class UserInformation: Mappable {
  var userName: String = ""
  var userProfileImage: String = ""
  var userId: String = ""
  
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    userName         <- map["user_name"]
    userProfileImage <- map["user_profile_img"]
    userId           <- map["user_id"]
  }
  //유저 정보 : 로그인 시 가져오는 정보들을 저장하고 있다.
}
