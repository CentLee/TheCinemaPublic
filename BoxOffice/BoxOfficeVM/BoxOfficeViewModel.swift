//
//  BoxOfficeVM.swift
//  TheCinema
//
//  Created by SatGatLee on 20/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

protocol BoxOfficeInput {
  func boxOfficeSearch(date: String)
}

protocol BoxOfficeOutput {
  var boxOffice: [BoxOfficeData] {get set}
  var boxOfficeInfo: PublishSubject<[MovieGenreData]> {get set}
}
protocol BoxOfficeViewModelType {
  var input: BoxOfficeInput {get}
  var output: BoxOfficeOutput {get}
}

class BoxOfficeViewModel: BoxOfficeViewModelType, BoxOfficeInput, BoxOfficeOutput {
  
  var input: BoxOfficeInput {return self}
  var output: BoxOfficeOutput {return self}
  
  private let disposeBag: DisposeBag = DisposeBag()
  private let ref: DatabaseReference = Database.database().reference()
  
  var boxOffice: [BoxOfficeData] = [] {
    didSet {
      boxOfficeList()
    }
  }
  var boxOfficeInfo: PublishSubject<[MovieGenreData]> = PublishSubject<[MovieGenreData]>()
}
extension BoxOfficeViewModel {
  private func boxOfficeList() {
    var movieList: [MovieGenreData] = []
    Observable.from(boxOffice)
      .enumerated()
      .concatMap { (index, data) -> Observable<MovieGenreData> in
        return BoxOfficeNetwork.SI.boxOfficeMovie(movieNm: data.movieName, date: data.openDate.replacingOccurrences(of: "-", with: ""))
      }
      .subscribe(onNext: { (data) in
        movieList.append(data)
      }, onCompleted: {
        iPrint(movieList.count)
        self.boxOfficeInfo.onNext(movieList)
      }).disposed(by: disposeBag)
  }
  
  func boxOfficeSearch(date: String) {
    BoxOfficeNetwork.SI.boxOfficeList(date: date)
      .subscribe(onNext: { [weak self] data in
        self?.boxOffice = data
      }).disposed(by: disposeBag)
  }
}
