//
//  UserProfileEditViewModel.swift
//  TheCinema
//
//  Created by ChLee on 04/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation

protocol UserProfileEditInput {
  var profileImage: BehaviorRelay<Data?> {get set}
  func profileEdited(name: String)
  func userExistence(name: String)
}

protocol UserProfileEditOutput {
  var existenceFlag: PublishSubject<Bool> {get set}
  var editCompleted: PublishSubject<Void> {get set}
}

protocol UserProfileEditViewModelType {
  var input: UserProfileEditInput {get}
  var output: UserProfileEditOutput {get}
}

class UserProfileEditViewModel: UserProfileEditViewModelType, UserProfileEditInput, UserProfileEditOutput {
  
  var input: UserProfileEditInput {return self}
  var output: UserProfileEditOutput {return self}
  
  var profileImage: BehaviorRelay<Data?> = BehaviorRelay<Data?>(value: nil)
  var existenceFlag: PublishSubject<Bool> = PublishSubject<Bool>()
  var editCompleted: PublishSubject<Void> = PublishSubject<Void>()
  private let ref: DatabaseReference = Database.database().reference()
  private let disposeBag: DisposeBag = DisposeBag()
}

extension UserProfileEditViewModel {
  func profileEdited(name: String) {
    if let image = profileImage.value {
      MainManager.SI.uploadProfileImage(uid: MainManager.SI.userInfo.userId, profileImage: image) { [weak self] (imgUrl) in
        self?.ref.child("User").child(MainManager.SI.userInfo.userId).child("UserInformation").updateChildValues(["user_name": name, "user_profile_img": imgUrl])
        MainManager.SI.userInfo.userName = name
        MainManager.SI.userInfo.userProfileImage = imgUrl
        iPrint(MainManager.SI.userInfo.userProfileImage)
        self?.editCompleted.onNext(())
      }
    } else {
      ref.child("User").child(MainManager.SI.userInfo.userId).child("UserInformation").updateChildValues(["user_name": name])
      MainManager.SI.userInfo.userName = name
      editCompleted.onNext(())
    }
  }
  
  func userExistence(name: String) { //닉네임 중복검사 플로우
    ref.child("User").observeSingleEvent(of: .value) { (snapshot) in
      guard !(snapshot.value is NSNull) else { return }
      guard let items = snapshot.value as? [String : Any] else { return }
      for (_, value) in items {
        if let list = value as? [String : String] {
          guard list["user_name"] != name else {
            self.existenceFlag.onNext(false)
            return
          }
        }
      }
      self.existenceFlag.onNext(true)
    }
    ref.removeAllObservers()
  }
}
