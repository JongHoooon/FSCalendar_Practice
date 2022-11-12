# FSCalendar_Practice

![Simulator Screen Recording - iPhone 11 Pro - 2022-11-13 at 03 24 46](https://user-images.githubusercontent.com/98168685/201489157-067f59d0-d0bc-4c35-9c87-9dc74fbbc827.gif)

## HeaderTitle

HeaderTitle는 center, left, right로 설정해줄 수 있는데 left, right가 애매한 1/3위치에 있어서 투명하게 만들어 주고 라벨을 새로 만들어줬습니다.


* headerTitle 투명하게

```swift
calendarView.appearance.headerTitleColor = .clear
calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
 ```

* headerLabel을 새로 만들어주고

```swift
let headerDateFormatter = DateFormatter().then {
  $0.dateFormat = "YYYY년 MM월 W주차"
  $0.locale = Locale(identifier: "ko_kr")
  $0.timeZone = TimeZone(identifier: "KST")
}

 private lazy var headerLabel = UILabel().then { [weak self] in
  guard let self = self else { return }
    
  $0.font = .systemFont(ofSize: 16.0, weight: .bold)
  $0.textColor = .label
  $0.text = self.headerDateFormatter.string(from: Date())
}
```

* calendarCurrentPageDidChange 메소드를 사용해서 페이지가 바뀔때마다 headerLabel의 text를 update해줍니다.

```swift
func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
  let currentPage = calendarView.currentPage
    
  headerLabel.text = headerDateFormatter.string(from: currentPage)
}
```

## 이전주, 다음주 버튼

* 버튼 생성
```swift
private lazy var leftButton = UIButton().then {
  $0.setImage(Icon.leftIcon, for: .normal)
  $0.addTarget(self, action: #selector(tapBeforeWeek), for: .touchUpInside)
}
  
private lazy var rightButton = UIButton().then {
  $0.setImage(Icon.rightIcon, for: .normal)
  $0.addTarget(self, action: #selector(tapNextWeek), for:.touchUpInside)
}
```

* 이전주, 다음주 값을 주는 메소드 생성

```swift
func getNextWeek(date: Date) -> Date {
  return  Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: date)!
}
  
func getPreviousWeek(date: Date) -> Date {
  return  Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: date)!
}
```

* 버튼에 연결할 selector 생성

```swift
@objc func tapNextWeek() {
  self.calendarView.setCurrentPage(getNextWeek(date: calendarView.currentPage), animated: true)
}
  
@objc func tapBeforeWeek() {
  self.calendarView.setCurrentPage(getPreviousWeek(date: calendarView.currentPage), animated: true)
}
```


## scope 토글 버튼

* 버튼 생성

```swift
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
```

* selector 생성
  * dateFormat, buttonImage, buttonTitle scope에 맞게 변경해줍니다.

```swift
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
```

* boundingRectWillChange 메소드를 사용해서 toggle할때마다 calendarView의 높이를 업데이트 해줍니다.
```swift

func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    
  calendarView.snp.updateConstraints {
    $0.height.equalTo(bounds.height)
  }
  self.view.layoutIfNeeded()
 }
```

> [참고](https://github.com/WenchaoD/FSCalendar)

