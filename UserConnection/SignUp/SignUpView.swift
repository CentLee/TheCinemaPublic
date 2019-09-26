//
//  SignUpV.swift
//  TheCinema
//
//  Created by SatGatLee on 06/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

class SignUpView: UIView { //회원가입 뷰
  //이름 중복 플로우.
  lazy var contentView: UIView = UIView()
  
  lazy var profileImage: UIButton = UIButton().then {
    $0.setBackgroundImage(UIImage(named:"user"), for: .normal)
    $0.imageView?.contentMode = .scaleToFill
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.cornerRadius = 50
    $0.clipsToBounds = true
  }
  
  lazy var textStack: UIStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 30
    $0.distribution = .equalSpacing
  }
  
  lazy var nameText: UITextField = UITextField().then {
    $0.placeholder = "별명"
    MainManager.SI.TextFieldSetted($0)
  }
  
  lazy var emailText: UITextField = UITextField().then {
    $0.placeholder = "이메일"
    MainManager.SI.TextFieldSetted($0)
  }
  
  lazy var passwordText: UITextField = UITextField().then {
    $0.placeholder = "비밀번호"
    $0.isSecureTextEntry = true
    MainManager.SI.TextFieldSetted($0)
  }
  
  lazy var btnStack: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
  }
  
  lazy var signUpBtn: UIButton = UIButton().then {
    $0.setTitle("회원가입", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.setTitleColor(.lightGray, for: .disabled)
    $0.isEnabled = false
    $0.titleLabel?.font = UIFont(name: "NanumSquareOTFR", size:15)
  }
  lazy var cancelBtn: UIButton = UIButton().then {
    $0.setTitle("취소", for: .normal)
    $0.setTitleColor(.black, for: .normal)
    $0.titleLabel?.font = UIFont(name: "NanumSquareOTFR", size:15)
  }
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    layoutSetUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension SignUpView {
  private func layoutSetUp() {
    addSubview(contentView)
    [profileImage, textStack, btnStack].forEach { self.contentView.addSubview($0) }
    [nameText, emailText, passwordText].forEach { self.textStack.addArrangedSubview($0) }
    [cancelBtn, signUpBtn].forEach { self.btnStack.addArrangedSubview($0) }
    
    constrain(contentView) {
      $0.edges == $0.superview!.safeAreaLayoutGuide.edges
    }
    
    constrain(profileImage) {
      $0.top     == $0.superview!.top + 100
      $0.centerX == $0.superview!.centerX
      $0.width   == 100
      $0.height  == $0.width
    }
    
    constrain(textStack, profileImage) {
      $0.top     == $1.bottom + 30
      $0.centerX == $1.centerX
      $0.width   == screenWidth / 2
    }
    
    constrain(btnStack, textStack) {
      $0.width   == $1.width
      $0.top     == $1.bottom + 20
      $0.centerX == $1.centerX
    }
  }
}
