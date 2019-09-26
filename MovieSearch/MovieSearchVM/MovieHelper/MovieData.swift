//
//  MovieData.swift
//  TheCinema
//
//  Created by ChLee on 27/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

class MovieList: Mappable { //영화 검색 리스트
  var start: Int = 0
  var items: [MovieData] = []
  
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    start  <- map["start"]
    items  <- map["items"]
  }
}

class MovieData: Mappable {
  var title: String = ""
  var link: String = ""
  var image: String = ""
  var userRating: String = ""
  var actor: String = ""
  var director: String = ""
  var date: String = ""
  
  var full: String {
    return title + " /\(date)년/ \(director)"
  }
  required init?(map: Map) { }
  
  func mapping(map: Map) {
    title      <- map["title"]
    link       <- map["link"]
    image      <- map["image"]
    userRating <- map["userRating"]
    actor      <- map["actor"]
    director   <- map["director"]
    date       <- map["pubDate"]
  }
}

//"title": "주마등<b>주식</b>회사",
//"link": "https://movie.naver.com/movie/bi/mi/basic.nhn?code=96811",
//"image": "https://ssl.pstatic.net/imgmovie/mdi/mit110/0968/96811_P01_142155.jpg",
//"subtitle": "走馬&amp;#28783;株式&amp;#20250;社",
//"pubDate": "2012",
//"director": "미키 코이치로|",
//"actor": "카시이 유우|쿠보타 마사타카|카지와라 히카리|치요 쇼타|요코야마 메구미|카시와바라 슈지|",
//"userRating": "4.50"

