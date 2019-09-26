//
//  MovieGenreNetwork.swift
//  TheCinema
//
//  Created by SatGatLee on 25/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

class MovieGenreNetwork {
  static let SI: MovieGenreNetwork = MovieGenreNetwork()
  var serviceKey: String = ""
  var baseUrl: String = ""
  
  init() {
    baseHeaders()
  }
  
  private func baseHeaders() {
    if let infoDic : [String : Any] = Bundle.main.infoDictionary {
      if let key: String = infoDic["GenreSearchServiceKey"] as? String,
        let url: String = infoDic["GenreSearchApiBaseUrl"] as? String {
        serviceKey = key
        baseUrl = url
      }
    }
  }
  
  func movieGenreList(start: String, genre: String) -> Observable<MovieGenreResult> {
    return Observable<MovieGenreResult>.create { observer in
      
      let str: String = self.baseUrl + "&createDts=1990&startCount=\(start)&genre=\(genre)&listCount=10&sort=prodYear&detail=Y&ServiceKey=\(self.serviceKey)"
      
      guard let encodingStr: String = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else
      {
        return Disposables.create()
      }
      guard let url: URL = URL(string: encodingStr) else
      {
        return Disposables.create()
      }
      
      Alamofire.request(url, method: .get).responseJSON { (response) in
        switch response.result {
        case .success(_):
          guard let json = response.result.value as? [String : Any] else { return }
          iPrint(json)
          guard let data: MovieGenreList = Mapper<MovieGenreList>().map(JSON: json) else { return }
          observer.onNext(data.items[0])
          observer.onCompleted()
        case .failure(_):
          break
        }
      }
      return Disposables.create()
    }
  }
  
  func movieDetailSearch(seq: String) -> Observable<MovieGenreData> {
    return Observable<MovieGenreData>.create { observer in
      guard let url: URL = URL(string: self.baseUrl + "&ServiceKey=\(self.serviceKey)&movieSeq=\(seq)") else
      {
        return Disposables.create()
      }
      iPrint(url)
      Alamofire.request(url, method: .get).responseJSON(completionHandler: { (response) in
        switch response.result {
        case .success(_):
          guard let json = response.result.value as? [String: Any] else { return }
          guard let data = Mapper<MovieGenreList>().map(JSON: json) else { return }
          observer.onNext(data.items[0].movies[0])
          observer.onCompleted()
        case .failure(let err): iPrint(err.localizedDescription)
        }
      })
      return Disposables.create()
    }
  }
}
