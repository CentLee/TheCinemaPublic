//
//  LoginVC.swift
//  TheCinema
//
//  Created by SatGatLee on 11/07/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
  //MARK:- 로그인 화면
  lazy var loginView: LoginView = LoginView()
  private let viewModel: LoginViewModelType = LoginViewModel()
  private let disposeBag: DisposeBag = DisposeBag()
  
  override func viewWillAppear(_ animated: Bool) {
    btnIsEnabled(flag: true)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    guard Auth.auth().currentUser != nil , let uid = Auth.auth().currentUser?.uid else { return }
    MainManager.SI.userInfo(uid: uid)
    tabBarSetUp()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(loginView)
    view.backgroundColor = MainManager.SI.bgColor
    constrain(loginView, view) {
      $0.edges == $1.safeAreaLayoutGuide.edges
    }
    
    GIDSignIn.sharedInstance().uiDelegate = self
    GIDSignIn.sharedInstance().delegate = self
    
    setupBind()
  }
}
extension LoginViewController {
  private func btnIsEnabled(flag: Bool) {
    loginView.googleLoginBtn.isEnabled = flag
  }
  
  private func setupBind() {
    loginView.emailText.rx.text.filter{$0 != ""}.asDriver(onErrorJustReturn: "").drive(viewModel.input.emailText).disposed(by: disposeBag)
    loginView.passwordText.rx.text.filter{$0 != ""}.asDriver(onErrorJustReturn: "").drive(viewModel.input.passwordText).disposed(by: disposeBag)
    
    loginView.googleLoginBtn.rx.tap.asDriver()
      .drive(onNext: {
        GIDSignIn.sharedInstance()?.signIn()
      })
      .disposed(by: disposeBag)
    
    Driver.combineLatest(loginView.emailText.rx.text.map{$0 != ""}.asDriver(onErrorJustReturn: false), loginView.passwordText.rx.text.map{$0 != ""}.asDriver(onErrorJustReturn: false)) { (isEmailValid, isPasswordValid) in
      return isEmailValid && isPasswordValid
      }
      .drive(onNext: { [weak self] (isValid) in
        self?.loginView.loginBtn.isEnabled = isValid
      }).disposed(by: disposeBag)
    
    loginView.loginBtn.rx.tap.asDriver()
      .drive(onNext: {[weak self] in
        self?.viewModel.input.loginFirebase()
      }).disposed(by: disposeBag)
    
    viewModel.output.onLogined.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self?.btnIsEnabled(flag: true)
        MainManager.SI.userInfo(uid: uid)
        self?.loginView.emailText.text?.removeAll()
        self?.loginView.passwordText.text?.removeAll()
        self?.tabBarSetUp()
      }).disposed(by: disposeBag)
    
    loginView.signUpBtn.rx.tap
      .asDriver()
      .drive(onNext: { [weak self] in
        let vc: SignUpViewController = SignUpViewController()
        self?.present(vc, animated: true, completion: nil)
      }).disposed(by: disposeBag)
  }
  
  private func tabBarSetUp() { //탭바 이니셜
    let firstVC = BoxOfficeViewController()
    firstVC.tabBarItem = UITabBarItem(title: "BoxOffice", image: UIImage(named: "boxOffice"), tag: 0)
    let secondVC = MovieSearchViewController()
    secondVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
    let threeVC = UserMenuViewController()
    threeVC.tabBarItem = UITabBarItem(title: "userMenu", image: UIImage(named: "userMenu"), tag: 2)
    let tabbar: UITabBarController = UITabBarController()
    tabbar.viewControllers = [UINavigationController(rootViewController: firstVC), UINavigationController(rootViewController: secondVC), UINavigationController(rootViewController: threeVC)]
    tabbar.tabBar.barTintColor = MainManager.SI.bgColor
    tabbar.tabBar.unselectedItemTintColor = UIColor.lightGray.withAlphaComponent(0.5)
    tabbar.tabBar.tintColor = MainManager.SI.textColor
    tabbar.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "NanumSquareOTFB", size: 12)!], for: .normal)
    present(tabbar, animated: true, completion: nil)
  }
}

extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) { //로그인 되면 정보 가지고 파이어베이스 저장ㄴ
    guard let _ = user, let authentication = user.authentication else { return }
    let creadential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
    
    if user.profile.hasImage {
      viewModel.input.googleLogin(name: user.profile.name, image: user.profile.imageURL(withDimension: 100)!.absoluteString, credential: creadential)
    } else {
      viewModel.input.googleLogin(name: user.profile.name, image: "", credential: creadential)
    }
  }
}
