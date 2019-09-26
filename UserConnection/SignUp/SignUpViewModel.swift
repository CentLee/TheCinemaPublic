//
//  SignUpVM.swift
//  TheCinema
//
//  Created by SatGatLee on 06/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

protocol SignUpInput {
  var nameText: BehaviorRelay<String?> {get set}
  var emailText: BehaviorRelay<String?> {get set}
  var passwordText: BehaviorRelay<String?> {get set}
  var profileImg: BehaviorRelay<Data?> {get set}
  
  func signUpUser()
}

protocol SignUpOutput {
  var onSignUp: PublishSubject<Void> {get}
}

protocol SignUpViewModelType {
  var input: SignUpInput {get}
  var output: SignUpOutput {get}
}

class SignUpViewModel: SignUpViewModelType, SignUpInput, SignUpOutput {
  
  var input: SignUpInput {return self}
  var output: SignUpOutput {return self}
  
  var nameText: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
  var emailText: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
  var passwordText: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
  var profileImg: BehaviorRelay<Data?> = BehaviorRelay<Data?>(value: nil)
  
  //output
  var onSignUp: PublishSubject<Void> = PublishSubject<Void>()
  
  private let ref: DatabaseReference = Database.database().reference()
  private let disposeBag: DisposeBag = DisposeBag()
}

extension SignUpViewModel {
  
  private func distinctName(onCompleted: @escaping (() -> Void)) { //이름 중복 검사
    ref.child("User").observeSingleEvent(of: .value) { [weak self] (snapshot) in
      guard let self = self else { return }
      guard snapshot.hasChildren() else {
        onCompleted()
        return
      } //데이터가 없다 그냥 사인업 가능
      
      guard let item = snapshot.value as? [String : AnyObject] else { return }
      for (_, value) in item {
        if let name = value["user_name"] as? String {
          iPrint(name)
          if name == self.nameText.value {
            return
          }
        }
      } //포문이 끝났다 그럼 데이터 파싱 끝
      onCompleted()
    }
  }
  
  func signUpUser() {
    guard let password: String = passwordText.value, let email: String = emailText.value, let name: String = nameText.value else { return }
    Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (result, error) in
      guard error == nil , let user = result?.user , let self = self else { return }
      
      MainManager.SI.uploadProfileImage(uid: user.uid, profileImage: self.profileImg.value, onCompleted: { (imgURL) in
        self.ref.child("User").child(user.uid).setValue(["UserInformation": ["user_id": user.uid, "user_name": name, "user_profile_img": imgURL]])
        //self.ref.child("UserName").childByAutoId().setValue(["userName" : name]) //중복검사용 플래그 형식으로 넣고.
        self.onSignUp.onNext(())
        self.ref.removeAllObservers()
      })
    })
  }
  
  private func uploadProfileImage(uid: String, onCompleted: @escaping ((String) -> Void)) {
    guard let image: Data = profileImg.value else {
      onCompleted("")
      return
    }
    let path = "ProfileImage/\(uid).png"
    let storage = Storage.storage().reference(forURL: "gs://thecinema-65db1.appspot.com")
    let imageRef = storage.child(path)
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    let uploadTask = imageRef.putData(image, metadata: metadata, completion: { (metadata, error) in
      if error != nil {
        print(error!.localizedDescription)
        return
      } else { //이미지 저장이 완벽히 됐을 때
        imageRef.downloadURL(completion: { (url, error) in
          if let url = url {
            onCompleted(url.absoluteString)
          }
        })
      }
    })
    uploadTask.resume()
  }
}
