import UIKit

class CalendarViewController: UIViewController {
  
  init(date: Date) {
    super.init(nibName: nil, bundle: nil)
    
    let label = UILabel(frame: .zero)
    label.font = UIFont.systemFont(ofSize: 50, weight: UIFont.Weight.thin)
    label.textColor = UIColor(red: 95/255, green: 102/255, blue: 108/255, alpha: 1)
    label.text = DateFormatters.shortDateFormatter.string(from: date)
    label.sizeToFit()
    
    let scrollView = UIScrollView()
    scrollView.frame = self.view.bounds
    
    scrollView.addSubview(label)
//    view.addSubview(label)
    scrollView.constrainCentered(label)
    
    scrollView.contentSize = CGSize(width: self.view.bounds.width, height: 2000)
    view.addSubview(scrollView)
    view.backgroundColor = .white
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
