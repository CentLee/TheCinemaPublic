//
//  LoginVM.swift
//  TheCinema
//
//  Created by SatGatLee on 11/07/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import FirebaseDatabase
import GoogleSignIn
import ObjectMapper

enum LoginType {
  case google
  case email
}

protocol LoginInput {
  var emailText: BehaviorRelay<String?> {get set}
  var passwordText: BehaviorRelay<String?> {get set}
  func googleLogin(name: String, image: String, credential: AuthCredential)
  func loginFirebase()
}

protocol LoginOutput {
  var onLogined: PublishSubject<Void> {get set}
}
protocol LoginViewModelType {
  var input: LoginInput {get}
  var output: LoginOutput {get}
}

class LoginViewModel: LoginViewModelType, LoginInput, LoginOutput {
  var input: LoginInput {return self}
  var output: LoginOutput {return self}
  //이메일 로그인과 구글 로그인 연동.
  
  //Input
  var emailText: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
  var passwordText: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
  var onLoginTapped: BehaviorRelay<Void> = BehaviorRelay<Void>(value: ())
  var onGoogleLogined: PublishSubject<(String, String, AuthCredential)> = PublishSubject<(String, String, AuthCredential)>()
  
  //output
  var onLogined: PublishSubject<Void> = PublishSubject<Void>()
  
  private var userName: String = "" //구글 로그인용
  private var userProfileImage: String = "" //구글 로그인용
  private var ref: DatabaseReference = Database.database().reference()
  private let disposeBag: DisposeBag = DisposeBag()
}
extension LoginViewModel {
  func loginFirebase() {
    guard let email: String = emailText.value , let password: String = passwordText.value else { return }
    Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
      guard error == nil else { return }
      self.onLogined.onNext(())
    }
  }
  
  func googleLogin(name: String, image: String, credential: AuthCredential) {
    userName = name
    userProfileImage = image
    firebaseAuthentication(credential: credential)
  }
  private func firebaseAuthentication(credential: AuthCredential) {
    Auth.auth().signIn(with: credential) { [weak self] (result, error) in
      guard let self = self , let user = result?.user else { return }
      MainManager.SI.userInfo.userId = user.uid
      MainManager.SI.userInfo.userName = self.userName
      MainManager.SI.userInfo.userProfileImage = self.userProfileImage
      self.ref.child("User").observeSingleEvent(of: .value, with: { (snapshot) in
        guard snapshot.hasChild("\(user.uid)") else  {
          self.ref.child("User").child("\(user.uid)").setValue(["UserInformation" : ["user_id": user.uid, "user_name": self.userName, "user_profile_img": self.userProfileImage]])
          self.onLogined.onNext(())
          //데이터 저장 후 푸쉬
          return
        }
        self.onLogined.onNext(())
      })
      
    }
  }
}
