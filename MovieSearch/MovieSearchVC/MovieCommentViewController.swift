//
//  MovieCommentVC.swift
//  TheCinema
//
//  Created by ChLee on 28/08/2019.
//  Copyright © 2019 com.example. All rights reserved.
//

import UIKit

class MovieCommentViewController: UIViewController {
  lazy var commentInputView: UIView = UIView().then {
    $0.backgroundColor = UIColor(hexString: "#F7F7F7")
  }
  lazy var ratingPanel: UIView = UIView()
  lazy var ratingText: UILabel = UILabel().then {
    $0.text = "0"
    $0.textColor = MainManager.SI.textColor
    $0.font = UIFont(name: "NanumSquareOTFR", size: 15)
  }
  lazy var ratingStack: UIStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
  }
  lazy var commentText: UITextView = UITextView().then { //textview로 대체
    $0.layer.cornerRadius = 10
    $0.layer.borderWidth = 1
    $0.layer.borderColor = MainManager.SI.textColor.cgColor
    $0.clipsToBounds = true
    $0.text = "리뷰를 입력해주세요!"
    $0.textColor = textColor
    $0.delegate = self
    $0.font = UIFont(name: "NanumSquareOTFR", size: 15)
  }
  
  lazy var commentTable: UITableView = UITableView(frame: .zero, style: .grouped).then {
    $0.estimatedRowHeight = 50
    $0.rowHeight = UITableView.automaticDimension
    $0.separatorStyle = .none
    $0.delegate = self
    $0.backgroundColor = UIColor(hexString: "#F7F7F7")
    $0.register(MovieCommentTableViewCell.self, forCellReuseIdentifier: MovieCommentTableViewCell.cellIdentifier)
  }
  
  private var commentList: BehaviorRelay<[MovieComment]> = BehaviorRelay<[MovieComment]>(value: [])
  private var viewModel: MovieCommentViewModelType = MovieCommentViewModel()
  private let disposeBag: DisposeBag = DisposeBag()
  private let ref: DatabaseReference = Database.database().reference()
  private let textColor = UIColor.lightGray.withAlphaComponent(0.5)
  var commentData: MovieComment = MovieComment(JSON: [:])!
  var rating: Int = 0
  var movieId: String = ""
  var commentDefault: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    layoutSetUp()
    navigationSetUp()
    bind()
  }
}

//MARK:- Custom Function
extension MovieCommentViewController {
  private func bind() {
    viewModel.inputs.commentList(seq: movieId, recent: false)
    
    viewModel.outputs.comments.subscribe(onNext: { [weak self] (list) in
      self?.commentList.accept(list)
    }).disposed(by: disposeBag)
    
    viewModel.outputs.onCompleted.asDriver(onErrorJustReturn: false).filter{$0}
      .drive(onNext: { [weak self] _ in
        self?.clearContext()
      }).disposed(by: disposeBag)
    
    viewModel.outputs.onReportCompleted.asDriver(onErrorJustReturn: false).filter{$0}
      .drive(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      }).disposed(by: disposeBag)
    
    commentList.asDriver(onErrorJustReturn: [])
      .drive(commentTable.rx.items(cellIdentifier: MovieCommentTableViewCell.cellIdentifier, cellType: MovieCommentTableViewCell.self)) { (row, list, cell) in
        cell.commentViewModel = self.viewModel
        cell.commentViewModel.inputs.movieSeq.accept(self.movieId)
        cell.vc = self
        cell.config(data: list, recent: false)
      }.disposed(by: disposeBag)
  }
  
  @objc private func cancelAction() {
    dismiss(animated: true, completion: nil)
  }
  
  @objc private func registrationAction() { //등록 액션
    guard let text: String = commentText.text, text != "" else { return }
    let formatter: DateFormatter = DateFormatter().then {
      $0.dateFormat = "YYYY-MM-dd HH:mm"
    }
    commentData.rating = rating
    commentData.comment = text
    commentData.createdAt = formatter.string(from: Date.init())//Data.init()
    commentData.name = MainManager.SI.userInfo.userName
    commentData.image = MainManager.SI.userInfo.userProfileImage
    commentData.commentKey = ref.child("Comments").child("\(movieId)").childByAutoId().key!
    commentData.uid = MainManager.SI.userInfo.userId
    
    viewModel.inputs.registerComment(data: commentData)
  }
  
  @objc private func ratingTap(_ gesture: UITapGestureRecognizer) { //탭일 땐 어떤 놈을 눌렀는지에 대한 태그를 먼저 분기처리한 후 터치 포지션에 대해서 다시 한 번 그 객체에 센터보다 큰 지 작은 지 비교.
    guard let view = gesture.view else { return }
    ratingCalculate(tag: view.tag, center: (view.frame.width / 2) + (view.frame.origin.x), touchLocation: gesture.location(in: ratingStack).x)
  }
  
  private func textViewSetUp() {
    if commentText.text == "" {
      commentText.text = "리뷰를 입력해주세요!"
      commentText.textColor = textColor
      navigationItem.rightBarButtonItem?.isEnabled = false
      
    }
  }
  
  private func clearContext() {
    commentList.accept([commentData] + commentList.value)
    commentData = MovieComment(JSON: [:])! //클리어.
    ratingCalculate(tag: 0, center: (ratingStack.frame.width / 2) + (ratingStack.frame.origin.x), touchLocation: 0)
    commentText.text?.removeAll()
    commentText.resignFirstResponder()
    ratingText.text = "0"
  }
  
  private func ratingCalculate(tag: Int, center: CGFloat, touchLocation: CGFloat) { //별점 계산 함수.
    var currentIndex: Int = 0
    ratingStack.arrangedSubviews.enumerated().forEach {
      currentIndex = $0.offset + 1
      let image: UIImageView = $0.element as! UIImageView
      if currentIndex < tag {
        image.image = UIImage(named: "ic_star_large_full")
        rating = currentIndex * 2
      } else if currentIndex == tag && center > touchLocation { //3인데 센터 포지션보다 작으면 하프. 그럼 5점
        image.image = UIImage(named: "ic_star_large_half")
        rating = currentIndex * 2 - 1
      } else if currentIndex == tag && center < touchLocation { //3인데 센터 포지션보다 작으면 하프. 그럼 5점
        image.image = UIImage(named: "ic_star_large_full")
        rating = currentIndex * 2
      }
      else {
        image.image = UIImage(named: "ic_star_large")
      }
    }
    ratingText.text = "\(rating)"
  }
  
  private func layoutSetUp() {
    [commentInputView, commentTable].forEach { self.view.addSubview($0) }
    [ratingPanel, commentText, ratingText].forEach { self.commentInputView.addSubview($0) }
    self.ratingPanel.addSubview(ratingStack)
    
    constrain(commentInputView) {
      $0.height == 200
      $0.top    == $0.superview!.safeAreaLayoutGuide.top
      $0.left   == $0.superview!.left
      $0.right  == $0.superview!.right
    }
    
    constrain(ratingText) {
      $0.centerX == $0.superview!.centerX
      $0.top     == $0.superview!.top + 20
    }
    
    constrain(ratingPanel, ratingText) {
      $0.centerX == $0.superview!.centerX
      $0.width   == 250
      $0.height  == 50
      $0.top     == $1.bottom + 5
    }
    
    constrain(ratingStack) {
      $0.edges == $0.superview!.edges
    }
    
    constrain(commentText, ratingPanel) {
      $0.top    == $1.bottom + 10
      $0.left   == $1.left
      $0.right  == $1.right
      $0.bottom <= $0.superview!.bottom - 10
    }
    
    constrain(commentTable, commentInputView) {
      $0.top    == $1.bottom
      $0.left   == $0.superview!.left
      $0.right  == $0.superview!.right
      $0.bottom == $0.superview!.bottom
    }
    
    for i in 1...5 {
      let image: UIImageView = UIImageView()
      image.tag = i
      image.image = UIImage(named: "ic_star_large")
      image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ratingTap(_:))))
      image.isUserInteractionEnabled = true
      ratingStack.addArrangedSubview(image)
    }
  }
  
  private func navigationSetUp() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancelAction))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "등록", style: .plain, target: self, action: #selector(registrationAction))
    navigationItem.rightBarButtonItem?.isEnabled = false
    setNeedsStatusBarAppearanceUpdate()
  }
}

extension MovieCommentViewController: UITableViewDelegate, UITextViewDelegate {
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return commentList.value.count == 0 ? 0 : 30
  }
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return MovieDetailHeaderView(text: "리뷰")
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  //textview
  func textViewDidEndEditing(_ textView: UITextView) { //view.endediting == return
    textViewSetUp()
  }
  
  func textViewDidChange(_ textView: UITextView) { //마지막 커서가 되면 다시 되돌리고
    textViewSetUp()
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if textView.text == "리뷰를 입력해주세요!" {
      textView.text.removeAll()
      textView.textColor = .black
      navigationItem.rightBarButtonItem?.isEnabled = true
    }
    return true
  }
}
