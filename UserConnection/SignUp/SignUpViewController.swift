//
//  SignUpVC.swift
//  TheCinema
//
//  Created by SatGatLee on 06/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import Photos
import NotificationBannerSwift

class SignUpViewController: UIViewController {
  private let viewModel: SignUpViewModelType = SignUpViewModel()
  private let disposeBag: DisposeBag = DisposeBag()
  
  lazy var signUpView: SignUpView = SignUpView()
  
  lazy var loadingView: UIActivityIndicatorView = UIActivityIndicatorView().then {
    $0.style = .whiteLarge
    $0.color = .darkGray
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    layoutSetUp()
    bindSetUp()
    // Do any additional setup after loading the view.
  }
}
extension SignUpViewController {
  private func layoutSetUp() {
    view.backgroundColor = MainManager.SI.bgColor
    view.addSubview(signUpView)
    view.addSubview(loadingView)
    
    constrain(signUpView) {
      $0.edges == $0.superview!.safeAreaLayoutGuide.edges
    }
    
    constrain(loadingView) {
      $0.center == $0.superview!.center
    }
  }
  
  private func imagePicked() {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
      imagePicker.allowsEditing = true
      
      present(imagePicker, animated: true)
    }
  }
  
  private func bindSetUp() {
    let nameIsEmpty: ControlProperty<String?> = signUpView.nameText.rx.text
    nameIsEmpty.filter{$0 != ""}.asDriver(onErrorJustReturn: "").drive(viewModel.input.nameText).disposed(by: disposeBag)
    signUpView.emailText.rx.text.filter{$0 != ""}.asDriver(onErrorJustReturn: "").drive(viewModel.input.emailText).disposed(by: disposeBag)
    signUpView.passwordText.rx.text.filter{$0 != ""}.asDriver(onErrorJustReturn: "").drive(viewModel.input.passwordText).disposed(by: disposeBag)
    
    signUpView.cancelBtn.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    Driver.combineLatest(nameIsEmpty.map{$0 != ""}.asDriver(onErrorJustReturn: false), signUpView.emailText.rx.text.map{$0 != ""}.asDriver(onErrorJustReturn: false), signUpView.passwordText.rx.text.map{$0 != ""}.asDriver(onErrorJustReturn: false)) {
      $0 && $1 && $2 }
      .drive(onNext: {
        [weak self] (isValid)in
        guard let self = self else { return }
        self.signUpView.signUpBtn.isEnabled = isValid
      }).disposed(by: disposeBag)
    
    signUpView.signUpBtn.rx.tap.map{self.loadingView.startAnimating()}.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.viewModel.input.signUpUser()
      }).disposed(by: disposeBag)
    
    signUpView.profileImage.rx.tap.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.imagePicked()
      }).disposed(by: disposeBag)
    
    viewModel.output.onSignUp.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.loadingView.stopAnimating()
        self?.dismiss(animated: true, completion: {
          let banner = FloatingNotificationBanner(title: "축하드립니다.", subtitle: "회원가입이 완료되었습니다.", style: .success)
          banner.show(on: self)
        })
      }).disposed(by: disposeBag)
  }
}
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let chosenImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
    signUpView.profileImage.setBackgroundImage(chosenImage, for: .normal)
    viewModel.input.profileImg.accept(chosenImage.jpegData(compressionQuality: 0.5))
    
    picker.dismiss(animated: true, completion: nil)
  }
}
