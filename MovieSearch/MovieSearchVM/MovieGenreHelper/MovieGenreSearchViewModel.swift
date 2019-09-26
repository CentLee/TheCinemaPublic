//
//  MovieGenreSearchVM.swift
//  TheCinema
//
//  Created by SatGatLee on 22/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

enum MovieGenreType: String {
  case fantasy = "판타지"
  case fear = "공포"
  case animation = "애니메이션"
  case action = "액션"
  case comedy = "코미디"
  case romance = "로맨스"
  case musical = "뮤지컬"
  case sf = "SF"
  
  static var arrays: [MovieGenreType] {
    return [.fear, .romance, .musical, .animation, .action, .comedy, .fantasy, .sf]
  }
  
  var image: UIImage {
    return UIImage(named: "\(self)")!
  }
}
protocol MovieGenreSearchInput { //장르별 검색 kmdb 사용.
  //  var genre: PublishRelay<(String, Int)> {get set}
  func genreMovie(start: String, genre: String)
  func genreClick(genre: String)
}

protocol MovieGenreSearchOutput {
  var genreList: PublishSubject<MovieGenreResult> {get set}
}

protocol MovieGenreSearchViewModelType {
  var inputs: MovieGenreSearchInput {get}
  var outputs: MovieGenreSearchOutput {get}
}
class MovieGenreSearchViewModel: MovieGenreSearchViewModelType, MovieGenreSearchOutput, MovieGenreSearchInput {
  
  var genreList: PublishSubject<MovieGenreResult> = PublishSubject<MovieGenreResult>()
  
  //장르별 검색 및 단일 검색할 것들.
  //인풋으로 장르 및 단일 영화이름 오면 그걸로 파싱.
  
  var inputs: MovieGenreSearchInput {return self}
  var outputs: MovieGenreSearchOutput {return self}
  
  private let ref: DatabaseReference = Database.database().reference()
  private let disposeBag: DisposeBag = DisposeBag()
  init() { }
}
extension MovieGenreSearchViewModel {
  func genreMovie(start: String, genre: String) {
    //글로벌에서 돌고
    MovieGenreNetwork.SI.movieGenreList(start: start, genre: genre)
      .subscribe(onNext: { [weak self] (movieResult) in
        self?.genreList.onNext(movieResult)
      }).disposed(by: disposeBag)
  }
  
  func genreClick(genre: String) {
    DispatchQueue.global().async {
      self.ref.child("GenreTop").observeSingleEvent(of: .value, with: { (snapshot) in
        guard !(snapshot.value is NSNull) else {
          self.ref.child("GenreTop").childByAutoId().setValue(["genre_count": 1, "genre_name": genre])
          return
        } //아무것도 없으면 저장한다 맨 처음 값
        guard let item = snapshot.value as? [String: Any] else { return }
        for(key, value) in item {
          guard let genreValue = value as? [String: Any], let data = Mapper<GenreTotalData>().map(JSON: genreValue) else { return }
          if data.genreName == genre { //같은 데이터가 존재하면
            self.ref.child("GenreTop").child(key).updateChildValues(["genre_count": data.genreCount + 1])
          }
        }
      })
      self.ref.removeAllObservers()
    }
  }
}
