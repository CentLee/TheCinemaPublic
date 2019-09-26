//
//  UserProfileEditViewController.swift
//  TheCinema
//
//  Created by ChLee on 04/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

class UserProfileEditViewController: UIViewController {
  
  lazy var profileImage: UIButton = UIButton().then {
    $0.layer.cornerRadius = 50
    $0.clipsToBounds = true
  }
  lazy var cameraIcn: UIImageView = UIImageView().then {
    $0.image = UIImage(named: "camera")
  }
  lazy var nameTitle: UILabel = UILabel().then {
    $0.text = "닉네임"
    $0.textColor = MainManager.SI.textColor
  }
  lazy var separatorLine: UIView = UIView().then {
    $0.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
  }
  lazy var nameField: UITextField = UITextField().then {
    $0.placeholder = "닉네임을 입력하세요"
    MainManager.SI.TextFieldSetted($0)
    $0.textColor = MainManager.SI.textColor
  }
  lazy var completeBtn: UIButton = UIButton().then {
    $0.setTitle("수정", for: .normal)
    $0.setTitleColor(MainManager.SI.textColor, for: .normal)
    $0.isEnabled = false
  }
  
  private let disposeBag: DisposeBag = DisposeBag()
  private let viewModel: UserProfileEditViewModelType = UserProfileEditViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MainManager.SI.bgColor
    layoutSetUp()
    bind()
  }
}

extension UserProfileEditViewController {
  private func layoutSetUp() {
    [profileImage, cameraIcn, nameTitle, separatorLine, nameField].forEach { self.view.addSubview($0) }
    
    constrain(profileImage) {
      $0.top    == $0.superview!.safeAreaLayoutGuide.top + 20
      $0.left   == $0.superview!.left + 20
      $0.width  == 100
      $0.height == $0.width
    }
    
    constrain(cameraIcn, profileImage) {
      $0.width  == 28
      $0.height == $0.width
      $0.bottom == $1.bottom
      $0.right  == $1.right + 5
    }
    
    constrain(nameTitle, profileImage) {
      $0.left == $1.left
      $0.top  == $1.bottom + 30
    }
    
    constrain(separatorLine, nameTitle) {
      $0.top    == $1.bottom + 10
      $0.left   == $1.left
      $0.height == 1
      $0.width  == 200
    }
    
    constrain(nameField, separatorLine) {
      $0.top   == $1.bottom + 10
      $0.left  == $1.left
      $0.right == $1.right
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: completeBtn)
    profileImage.URLString(urlString: MainManager.SI.userInfo.userProfileImage, state: .normal)
    nameField.text = MainManager.SI.userInfo.userName
  }
  
  private func bind() {
    profileImage.rx.tap.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.profileImageEdit()
      }).disposed(by: disposeBag)
    
    nameField.rx.text.filter{$0 != "" && MainManager.SI.userInfo.userName != $0}.asDriver(onErrorJustReturn: nil)
      .debounce(RxTimeInterval.seconds(1))
      .drive(onNext: { [weak self] name in //값이 있다 가정
        guard let name = name else { return }
        self?.viewModel.input.userExistence(name: name) //중복 검사 플래그 태우고.
      }).disposed(by: disposeBag)
    
    completeBtn.rx.tap.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        guard let text = self?.nameField.text else { return }
        self?.viewModel.input.profileEdited(name: text)
      }).disposed(by: disposeBag)
    
    viewModel.output.existenceFlag.bind(to: completeBtn.rx.isEnabled).disposed(by: disposeBag)
    
    viewModel.output.editCompleted.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      }).disposed(by: disposeBag)
    
  }
  
  private func profileImageEdit() {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertController.title = "프로필 사진 변경"
    
    let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in
      
    }
    alertController.addAction(cancelAction)
    
    let takeAction = UIAlertAction(title: "사진 찍기", style: .default) { action in
      
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true)
      }
    }
    alertController.addAction(takeAction)
    
    let selectAction = UIAlertAction(title: "라이브러리에서 선택", style: .default) { action in
      
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
      }
    }
    alertController.addAction(selectAction)
    present(alertController, animated: true, completion: nil)
  }
}

extension UserProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
    profileImage.setImage(chosenImage, for: .normal)
    viewModel.input.profileImage.accept(chosenImage.pngData())
    picker.dismiss(animated: true, completion: nil)
  }
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }
}
