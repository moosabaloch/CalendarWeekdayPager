import UIKit
import Parchment

// First thing we need to do is create our own PagingItem that will
// hold our date. We need to make sure it conforms to Hashable and
// Comparable, as that is required by PagingViewController. We also
// cache the formatted date strings for performance.

struct CalendarItem: PagingItem, Hashable, Comparable {
  let date: Date
  let dateText: String
  let weekdayText: String
  
  init(date: Date) {
    self.date = date
    self.dateText = DateFormatters.dateFormatter.string(from: date)
    self.weekdayText = DateFormatters.weekdayFormatter.string(from: date)
  }
  
  var hashValue: Int {
    return date.hashValue
  }
  
  static func ==(lhs: CalendarItem, rhs: CalendarItem) -> Bool {
    return lhs.date == rhs.date
  }
  
  static func <(lhs: CalendarItem, rhs: CalendarItem) -> Bool {
    return lhs.date < rhs.date
  }
}

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Create an instance of PagingViewController where CalendarItem
    // is set as the generic type.
    let pagingViewController = PagingViewController<CalendarItem>()
	pagingViewController.menuItemSource = .class(type: CalendarPagingCell.self)
    let width = self.view.frame.width/7
    pagingViewController.menuItemSize = .fixed(width: width, height: 58)
    pagingViewController.textColor = UIColor(red: 95/255, green: 102/255, blue: 108/255, alpha: 1)
    pagingViewController.selectedTextColor = UIColor(red: 117/255, green: 111/255, blue: 216/255, alpha: 1)
    pagingViewController.indicatorColor = UIColor(red: 117/255, green: 111/255, blue: 216/255, alpha: 1)
    
    // Add the paging view controller as a child view
    // controller and constrain it to all edges
    addChild(pagingViewController)
    view.addSubview(pagingViewController.view)
    view.constrainToEdges(pagingViewController.view)
    pagingViewController.didMove(toParent: self)
    
    // Set our custom data source
    pagingViewController.infiniteDataSource = self
    
    // Set the current date as the selected paging item
    pagingViewController.select(pagingItem: CalendarItem(date: Date()))
    
//    pagingViewController.menuTransition = .animateAfter
    pagingViewController.menuInteraction = .swipe//.scrolling
    
    pagingViewController.menuTransition = .animateAfter
  }
  
}

// We need to conform to PagingViewControllerDataSource in order to
// implement our custom data source. We set the initial item to be the
// current date, and every time pagingItemBeforePagingItem: or
// pagingItemAfterPagingItem: is called, we either subtract or append
// the time interval equal to one day. This means our paging view
// controller will show one menu item for each day.

extension ViewController: PagingViewControllerInfiniteDataSource {

    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemBeforePagingItem pagingItem: T , withIndexOffset : Int) -> T? {
        let calendarItem = pagingItem as! CalendarItem
//        let interval = Double(-(86400*withIndexOffset))
        
        let date = calendarItem.date.add(amount: -7, type: Calendar.Component.day)//addingTimeInterval(interval)
        print("Get Date for Previous 7  Days")
        print(date)
        return CalendarItem(date: date) as? T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemAfterPagingItem pagingItem: T , withIndexOffset : Int) -> T? {
        let calendarItem = pagingItem as! CalendarItem
        let date = calendarItem.date.add(amount: 7, type: Calendar.Component.day)//.addingTimeInterval(Double(86400*withIndexOffset))
        print("Get Date for Next 7 Days")
        print(date)
        
        
        return CalendarItem(date: date) as? T
    }
    
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForPagingItem pagingItem: T) -> UIViewController {
    let calendarItem = pagingItem as! CalendarItem
    return CalendarViewController(date: calendarItem.date)
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemBeforePagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    let date = calendarItem.date.add(amount: -1, type: Calendar.Component.day)//addingTimeInterval(-86400)
    
    return CalendarItem(date: date) as? T
  }
  
  func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemAfterPagingItem pagingItem: T) -> T? {
    let calendarItem = pagingItem as! CalendarItem
    let date = calendarItem.date.add(amount: 1, type: Calendar.Component.day)//addingTimeInterval(86400)
   
    return CalendarItem(date: date) as? T
  }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, realPagingItemBeforePagingItem pagingItem: T , isReal : Bool ) -> T? {
        let calendarItem = pagingItem as! CalendarItem
        let date = calendarItem.date.add(amount: -1, type: Calendar.Component.day)//addingTimeInterval(-86400)
        if date < date.startOfWeek!{
            return nil
        }
        return CalendarItem(date: date) as? T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, realPagingItemAfterPagingItem pagingItem: T , isReal : Bool) -> T? {
        let calendarItem = pagingItem as! CalendarItem
        let date = calendarItem.date.add(amount: 1, type: Calendar.Component.day)//addingTimeInterval(86400)
        if date > date.endOfWeek! {
            return nil
        }
        return CalendarItem(date: date) as? T
    }
  
}

extension Date {
    // Current Date Adding commponent
    func add(amount number : Int , type : Calendar.Component ) -> Date {
        let calendar = Calendar.autoupdatingCurrent
        return calendar.date(byAdding: type, value: number, to: self)!
    }
    
//    var startOfWeek: Date? {
//        let gregorian = Calendar(identifier: .gregorian)
//        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
//        return gregorian.date(byAdding: .day, value: 1, to: sunday)
//    }
//
//    var endOfWeek: Date? {
//        let gregorian = Calendar(identifier: .gregorian)
//        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
//        return gregorian.date(byAdding: .day, value: 7, to: sunday)
//    }
    var startOfWeek: Date? {
        let gregorian = Calendar(identifier: .gregorian)
//        gregorian.timeZone = Calendar.current.timeZone
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return gregorian.date(byAdding: .day, value: 1, to: sunday)
    }
    
    var endOfWeek: Date? {

        let gregorian = Calendar(identifier: .gregorian)
     
        guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        let calculatedDate = gregorian.date(byAdding: .day, value: 7, to: sunday)
        if self.isSunday() {
            return self.add(amount: 1, type: Calendar.Component.hour)//self.add(amount: -1, type: Calendar.Component.day)
        }
        if self.isMonday() {
            return self.add(amount: -25, type: Calendar.Component.hour)
        }
        return calculatedDate
    }
    
    func toDateInt() -> Int {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd"//"dd MMMM - EEEE"
        return Int(dateFormatterPrint.string(from: self) ) ?? 0
    }
    
    func isSunday() -> Bool {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE"//"dd MMMM - EEEE"
        return dateFormatterPrint.string(from: self).contains("Sunday")
    }
    func isMonday() -> Bool {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "EEEE"//"dd MMMM - EEEE"
        return dateFormatterPrint.string(from: self).contains("Monday")
    }
    
    func toDateString_ddMMMM_EEEE() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "HH:MM - dd EEEE MMMM"//"dd MMMM - EEEE"
        return dateFormatterPrint.string(from: self)
    }
    
//    ////https://stackoverflow.com/a/33397770/4994239
//
//
//    static func today() -> Date {
//        return Date()
//    }
//
//    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
//        return get(.Next,
//                   weekday,
//                   considerToday: considerToday)
//    }
//
//    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
//        return get(.Previous,
//                   weekday,
//                   considerToday: considerToday)
//    }
//
//    func get(_ direction: SearchDirection,
//             _ weekDay: Weekday,
//             considerToday consider: Bool = false) -> Date {
//
//        let dayName = weekDay.rawValue
//
//        let weekdaysName = getWeekDaysInEnglish().map { $0.lowercased() }
//
//        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
//
//        let searchWeekdayIndex = weekdaysName.index(of: dayName)! + 1
//
//        let calendar = Calendar(identifier: .gregorian)
//
//        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
//            return self
//        }
//
//        var nextDateComponent = DateComponents()
//        nextDateComponent.weekday = searchWeekdayIndex
//
//
//        let date = calendar.nextDate(after: self,
//                                     matching: nextDateComponent,
//                                     matchingPolicy: .nextTime,
//                                     direction: direction.calendarSearchDirection)
//
//        return date!
//    }
    
}
//
//// MARK: Helper methods
//extension Date {
//    func getWeekDaysInEnglish() -> [String] {
//        var calendar = Calendar(identifier: .gregorian)
//        calendar.locale = Locale(identifier: "en_US_POSIX")
//        return calendar.weekdaySymbols
//    }
//
//    enum Weekday: String {
//        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
//    }
//
//    enum SearchDirection {
//        case Next
//        case Previous
//
//        var calendarSearchDirection: Calendar.SearchDirection {
//            switch self {
//            case .Next:
//                return .forward
//            case .Previous:
//                return .backward
//            }
//        }
//    }
//}
