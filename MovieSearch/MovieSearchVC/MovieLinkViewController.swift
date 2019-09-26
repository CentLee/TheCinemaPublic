//
//  MovieLinkVC.swift
//  TheCinema
//
//  Created by ChLee on 02/09/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit
import WebKit

class MovieLinkViewController: UIViewController { //영화 네이버 링크 뷰.
  
  lazy var linkView: WKWebView = WKWebView().then {
    $0.backgroundColor = .white
  }
  var urlRequest: URLRequest? {
    didSet {
      layoutSetUp( onCompleted: { [weak self] in
        guard let self = self , let request = self.urlRequest else { return }
        self.linkView.load(request)
      })
      
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

extension MovieLinkViewController {
  private func layoutSetUp(onCompleted: @escaping (() -> Void)) {
    view.addSubview(linkView)
    
    constrain(linkView) {
      $0.edges == $0.superview!.edges
    }
    
    onCompleted()
  }
}
