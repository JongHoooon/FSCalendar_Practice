//
//  ViewController.swift
//  FSCalendar_Practice
//
//  Created by JongHoon on 2022/11/13.
//

import UIKit
import FSCalendar
import SnapKit
import Then

class ViewController: UIViewController {
  
  // MARK: - Constant
  
  struct Icon {
    static let downIcon = UIImage(named: "down")?
      .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
    static let upIcon = UIImage(named: "up")?
      .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
    static let leftIcon = UIImage(systemName: "chevron.left")?
      .withTintColor(.label, renderingMode: .alwaysOriginal)
    static let rightIcon = UIImage(systemName: "chevron.right")?
      .withTintColor(.label, renderingMode: .alwaysOriginal)
  }
  
  // MARK: - Property
  
  let headerDateFormatter = DateFormatter().then {
    $0.dateFormat = "YYYY년 MM월 W주차"
    $0.locale = Locale(identifier: "ko_kr")
    $0.timeZone = TimeZone(identifier: "KST")
  }
  
  // MARK: - UI
  
  private lazy var calendarView = FSCalendar(frame: .zero)
  
  private lazy var toggleButton = UIButton().then {
    $0.setTitle("주", for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 16.0)
    $0.setTitleColor(.label, for: .normal)
    $0.setImage(Icon.downIcon, for: .normal)
    $0.backgroundColor = .systemGray6
    $0.semanticContentAttribute = .forceRightToLeft
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12.0,
                                      bottom: 0, right: 0)
    $0.layer.cornerRadius = 4.0
    $0.addTarget(self, action: #selector(tapToggleButton), for: .touchUpInside)
  }
  
  private lazy var leftButton = UIButton().then {
    $0.setImage(Icon.leftIcon, for: .normal)
    $0.addTarget(self, action: #selector(tapBeforeWeek), for: .touchUpInside)
  }
  
  private lazy var rightButton = UIButton().then {
    $0.setImage(Icon.rightIcon, for: .normal)
    $0.addTarget(self, action: #selector(tapNextWeek), for: .touchUpInside)
  }
  
  private lazy var headerLabel = UILabel().then { [weak self] in
    guard let self = self else { return }
    
    $0.font = .systemFont(ofSize: 16.0, weight: .bold)
    $0.textColor = .label
    $0.text = self.headerDateFormatter.string(from: Date())
  }
  
  private lazy var testLabel = UILabel().then {
    $0.text = "라벨입니다"
  }

  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    configureCalendar()
  }
}

// MARK: - FSCalendar

extension ViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    
    calendarView.snp.updateConstraints {
      $0.height.equalTo(bounds.height)
    }
    self.view.layoutIfNeeded()
  }
  
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    let currentPage = calendarView.currentPage
    
    headerLabel.text = headerDateFormatter.string(from: currentPage)
  }
}

// MARK: - Method

extension ViewController {
  
  private func configureUI() {
    
    let calendarButtonStackView = UIStackView(arrangedSubviews: [
      leftButton,
      rightButton,
      toggleButton
    ]).then {
      $0.axis = .horizontal
      $0.distribution = .equalSpacing
      $0.spacing = 12.0
      
      toggleButton.snp.makeConstraints {
        $0.height.equalTo(28.0)
        $0.width.equalTo(68.0)
      }
    }
    
    [
      calendarView,
      calendarButtonStackView,
      headerLabel,
      testLabel
    ].forEach { view.addSubview($0) }
    
    calendarView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(32.0)
      $0.trailing.leading.equalToSuperview().inset(12.0)
      $0.height.equalTo(300.0)
    }
    
    calendarButtonStackView.snp.makeConstraints {
      $0.centerY.equalTo(calendarView.calendarHeaderView.snp.centerY)
      $0.trailing.equalTo(calendarView.collectionView)
      $0.height.equalTo(28.0)
    }
    
    headerLabel.snp.makeConstraints {
      $0.centerY.equalTo(calendarView.calendarHeaderView.snp.centerY)
      $0.leading.equalTo(calendarView.collectionView)
    }
    
    testLabel.snp.makeConstraints {
      $0.top.equalTo(calendarView.snp.bottom).offset(16.0)
      $0.centerX.equalToSuperview()
    }
  }
  
  private func configureCalendar() {
    
    calendarView.delegate = self
    calendarView.dataSource = self
    
    calendarView.select(Date())
    
    calendarView.locale = Locale(identifier: "ko_KR")
    calendarView.scope = .week
    
    calendarView.appearance.headerTitleColor = .clear
    calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
    
    calendarView.appearance.selectionColor = .red
    
    let offset: Double = (self.view.frame.width - ("YYYY년 MM월 W주차" as NSString)
      .size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)])
      .width - 16.0 ) / 2.0
    calendarView.appearance.headerTitleOffset = CGPoint(x: -offset, y: 0)
    
    calendarView.weekdayHeight = 36.0
    calendarView.headerHeight = 36.0
    
    calendarView.appearance.weekdayFont = .systemFont(ofSize: 14.0)
    calendarView.appearance.titleFont = .systemFont(ofSize: 14.0)
    calendarView.appearance.titleTodayColor = .label
    calendarView.appearance.titleDefaultColor = .secondaryLabel
    
    calendarView.appearance.todayColor = .clear
    calendarView.appearance.weekdayTextColor = .label
    
    calendarView.placeholderType = .none
    
    calendarView.scrollEnabled = true
    calendarView.scrollDirection = .horizontal
  }
  
  func getNextWeek(date: Date) -> Date {
    return  Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: date)!
  }
  
  func getPreviousWeek(date: Date) -> Date {
    return  Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: date)!
  }
  
  // MARK: - Selector
  
  @objc func tapToggleButton() {
    if self.calendarView.scope == .month {
      self.calendarView.setScope(.week, animated: true)
      
      self.headerDateFormatter.dateFormat = "YYYY년 MM월 W주차"
      self.toggleButton.setTitle("주", for: .normal)
      self.toggleButton.setImage(Icon.downIcon, for: .normal)
      self.headerLabel.text = headerDateFormatter.string(from: calendarView.currentPage)
      
    } else {
      self.calendarView.setScope(.month, animated: true)
      self.headerDateFormatter.dateFormat = "YYYY년 MM월"
      self.toggleButton.setTitle("월", for: .normal)
      self.toggleButton.setImage(Icon.upIcon, for: .normal)
      self.headerLabel.text = headerDateFormatter.string(from: calendarView.currentPage)
    }
  }
  
  @objc func tapNextWeek() {
    self.calendarView.setCurrentPage(getNextWeek(date: calendarView.currentPage), animated: true)
  }
  
  @objc func tapBeforeWeek() {
    self.calendarView.setCurrentPage(getPreviousWeek(date: calendarView.currentPage), animated: true)
  }
}
