//
//  MovieSearchVM.swift
//  TheCinema
//
//  Created by ChLee on 30/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation


protocol MovieSearchInput {
  func movieSearch(title: String, start: Int)
  func movieDetailSearch(seq: String)
}

protocol MovieSearchOutPut {
  var movieList: PublishSubject<[MovieData]> {get set}
  var movieInfo: PublishSubject<MovieGenreData> {get set}
}

protocol MovieSearchViewModelType {
  var input: MovieSearchInput {get}
  var output: MovieSearchOutPut {get}
}


class MovieSearchViewModel: MovieSearchViewModelType, MovieSearchInput, MovieSearchOutPut {
  var input: MovieSearchInput {return self}
  var output: MovieSearchOutPut {return self}
  
  var movieList: PublishSubject<[MovieData]> = PublishSubject<[MovieData]>()
  var movieInfo: PublishSubject<MovieGenreData> = PublishSubject<MovieGenreData>()
  
  private let disposeBag: DisposeBag = DisposeBag()
}
extension MovieSearchViewModel { //네이버 검색
  func movieSearch(title: String, start: Int) { //무비검색
    MovieNetwork.SI.movieList(query: title, start: start)
      .subscribe(onNext: { [weak self] (list) in
        //
        self?.movieList.onNext(list.items)
      }).disposed(by: disposeBag)
  }
  
  func movieDetailSearch(seq: String) {
    MovieGenreNetwork.SI.movieDetailSearch(seq: seq)
      .subscribe(onNext: { [weak self] (movie) in
        self?.movieInfo.onNext(movie)
      }).disposed(by: disposeBag)
  }
}
