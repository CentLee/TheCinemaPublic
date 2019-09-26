//
//  MainManager.swift
//  TheCinema
//
//  Created by SatGatLee on 06/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import Foundation
import ObjectMapper

class MainManager {
  static let SI = MainManager()
  
  var userInfo: UserInformation = UserInformation(JSON: [:])! //로그인시 받는 유저 정보
  private let ref: DatabaseReference = Database.database().reference()
  let bgColor: UIColor = UIColor(hexString: "#F9EEEF") //backgroundColor
  let textColor: UIColor = UIColor(hexString: "#474747") //textColor
  let tableColor: UIColor = UIColor(hexString: "#F7F7F7")
}
extension MainManager {
  func ratingCalculate(rating: Int, stackV: UIStackView) {
    var previoudIndex: Double = 0.0
    var currentIndex: Double = 0.0
    let rating: Double = Double(rating) / 2
    stackV.arrangedSubviews.enumerated().forEach {
      currentIndex = Double($0.offset) + 1.0
      let image: UIImageView = $0.element as! UIImageView
      if currentIndex <= rating {
        image.image = UIImage(named: "ic_star_large_full")
        previoudIndex = currentIndex
      } else if previoudIndex < rating && currentIndex > rating { //3.5 쩜오같은 사이즈
        image.image = UIImage(named: "ic_star_large_half")
        previoudIndex = currentIndex
      } else {
        image.image = UIImage(named: "ic_star_large")
      }
    }
  }
  
  func userInfo(uid: String) {
    DispatchQueue.global().async {
      self.ref.child("User").child("\(uid)").child("UserInformation").observeSingleEvent(of: .value) { (snapshot) in
        guard !(snapshot.value is NSNull) else { return }
        guard let item = snapshot.value as? [String:Any] , let data = Mapper<UserInformation>().map(JSON: item) else { return }
        MainManager.SI.userInfo = data
      }
      self.ref.removeAllObservers()
    }
    
  }
  
  func uploadProfileImage(uid: String, profileImage: Data? , onCompleted: @escaping ((String) -> Void)) {
    guard let image: Data = profileImage else {
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
  
  func navigationAppearance(navi: UINavigationController?) {
    navi?.navigationBar.barTintColor = bgColor
    navi?.navigationBar.tintColor = textColor
    navi?.navigationBar.isTranslucent = false
    navi?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : textColor, NSAttributedString.Key.font : UIFont(name: "NanumSquareOTFEB", size: 20)!]
  }
  
  func TextFieldSetted(_ field: UITextField) {
    field.borderStyle = .roundedRect
    field.autocorrectionType = .no
    field.autocapitalizationType = .none
    field.textColor = textColor
    field.font = UIFont(name: "NanumSquareOTFR", size:15)
  }
}
