//
//  UserMenuViewModel.swift
//  TheCinema
//
//  Created by ChLee on 04/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

protocol UserMenuInput {
  func favoriteList()
  func inquiryTopList()
}

protocol UserMenuOutput {
  var favoriteMovies: PublishSubject<[MovieFavoriteData]> {get set}
  var genreTopList: PublishSubject<[GenreTotalData]> {get set}
}

protocol UserMenuViewModelType {
  var input: UserMenuInput {get}
  var output: UserMenuOutput {get}
}

class UserMenuViewModel: UserMenuViewModelType, UserMenuInput, UserMenuOutput {
  var input: UserMenuInput {return self}
  var output: UserMenuOutput {return self}
  
  
  var favoriteMovies: PublishSubject<[MovieFavoriteData]> = PublishSubject<[MovieFavoriteData]>()
  var genreTopList: PublishSubject<[GenreTotalData]> = PublishSubject<[GenreTotalData]>()
  private let disposeBag: DisposeBag = DisposeBag()
  private let ref: DatabaseReference = Database.database().reference()
  
}

extension UserMenuViewModel {
  func favoriteList() {
    var list: [MovieFavoriteData] = []
    DispatchQueue.global().async {
      self.ref.child("User").child(MainManager.SI.userInfo.userId).child("FavoriteMovie").observeSingleEvent(of: .value) { (snapshot) in
        guard !(snapshot.value is NSNull) else {
          self.favoriteMovies.onNext([])
          return
        }
        guard let item = snapshot.value as? [String : Any] else { return }
        for(_, value) in item {
          guard let movie = value as? [String : Any] , let data = Mapper<MovieFavoriteData>().map(JSON: movie) else { return }
          list.append(data)
        }
        self.favoriteMovies.onNext(list)
      }
      self.ref.removeAllObservers()
    }
    
  }
  
  func inquiryTopList() {
    var genreTotalList: [GenreTotalData] = []
    DispatchQueue.global().async {
      self.ref.child("GenreTop").queryLimited(toFirst: 3).queryOrderedByValue().observeSingleEvent(of: .value) { (snapshot) in
        guard !(snapshot.value is NSNull) else { return }
        guard let list = snapshot.value as? [String : Any] else { return }
        for (_ , value) in list {
          guard let item = value as? [String : Any], let data = Mapper<GenreTotalData>().map(JSON: item) else { return }
          genreTotalList.append(data)
        }
        self.genreTopList.onNext(genreTotalList)
      }
      self.ref.removeAllObservers()
    }
  }
}
