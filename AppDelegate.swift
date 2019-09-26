//
//  AppDelegate.swift
//  TheCinema
//
//  Created by SatGatLee on 2019. 7. 8..
//  Copyright © 2019년 com.example. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
  
  var window: UIWindow?
  
  // var appServices: AppServices
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    
    UserDefaults.standard.set(String(""), forKey: "currentDate")
    let loginVC = LoginViewController()
    window = UIWindow(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    guard let window = window else { return false }
    window.rootViewController = loginVC
    window.makeKeyAndVisible()
    
    
    
    GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
    
    return true
  }
  func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
    return GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
  }
  
  // ios 이상에서 앱 실행 시 해당 메소드를 구현해야 합니다.
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    //구글 로그인 시 사용하는 부분 입니다. 리턴은 Bool 형태로 구성되어 있어서, 단독 사용시 return 에 바로 입력하셔도 됩니다.
    let googleSession = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    
    return googleSession
  }
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

