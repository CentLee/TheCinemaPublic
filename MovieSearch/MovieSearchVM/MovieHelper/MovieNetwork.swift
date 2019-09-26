//
//  MovieNetwork.swift
//  TheCinema
//
//  Created by ChLee on 27/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

class MovieNetwork { //영화 단일 검색 api network
  static let SI: MovieNetwork = MovieNetwork()
  var headers:[String:String] = [:]
  var baseUrl: String = ""
  
  init() {
    baseHeaders()
  }
  
  private func baseHeaders() {
    if let infoDic : [String : Any] = Bundle.main.infoDictionary {
      if let id: String = infoDic["X-Naver-Client-Id"] as? String,
        let secret: String = infoDic["X-Naver-Client-Secret"] as? String,
        let url: String = infoDic["SearchApiBaseUrl"] as? String {
        headers["X-Naver-Client-Id"] = id
        headers["X-Naver-Client-Secret"] = secret
        iPrint(headers)
        baseUrl = url
      }
    }
  }
  
  func movieList(query: String, start: Int) -> Observable<MovieList> {
    let str: String = self.baseUrl + "query=\(query)&display=20&start=\(start)"
    return Observable<MovieList>.create { observer in
      guard let encodingStr: String = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else
      {
        return Disposables.create()
      }
      guard let url: URL = URL(string: encodingStr) else
      {
        return Disposables.create()
      }
      Alamofire.request(url, method: .get, headers: self.headers).responseJSON { (response) in
        switch response.result {
        case .success(_):
          guard let json = response.result.value as? [String : Any] else { return }
          iPrint(json)
          guard let data: MovieList = Mapper<MovieList>().map(JSON: json) else { return }
          observer.onNext(data)
          observer.onCompleted()
        case .failure(_):
          break
        }
      }
      return Disposables.create()
    }
  }
}
