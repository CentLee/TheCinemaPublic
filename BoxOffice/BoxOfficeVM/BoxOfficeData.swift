//
//  BoxOfficeData.swift
//  TheCinema
//
//  Created by ChLee on 02/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

class BoxOfficeResult: Mappable {
  var result: BoxOfficeList = BoxOfficeList(JSON: [:])!
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    result  <- map["boxOfficeResult"]
  }
}

class BoxOfficeList: Mappable {
  var list: [BoxOfficeData] = []
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    list  <- map["dailyBoxOfficeList"]
  }
}

class BoxOfficeData: Mappable {
  var rank: String = "" //일일 랭킹
  var movieName: String = ""
  var openDate: String = "" //개봉일
  var audience: String = "" //누적 관객 수
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    rank      <- map["rank"]
    movieName <- map["movieNm"]
    openDate  <- map["openDt"]
    audience  <- map["audiAcc"]
  }
}
