//
//  ColorTabs.swift
//  ColorMatchTabs
//
//  Created by Sergey Butenko on 13/6/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let HighlighterViewOffScreenOffset: CGFloat = 0

private let SwitchAnimationDuration: TimeInterval = 0.3
private let HighlighterAnimationDuration: TimeInterval = SwitchAnimationDuration / 2

@objc public protocol ColorTabsDataSource: class {
  
  func numberOfItems(inTabSwitcher tabSwitcher: ColorTabs) -> Int
  func tabSwitcher(_ tabSwitcher: ColorTabs, titleAt index: Int) -> String
  func tabSwitcher(_ tabSwitcher: ColorTabs, iconAt index: Int) -> UIImage
  func tabSwitcher(_ tabSwitcher: ColorTabs, hightlightedIconAt index: Int) -> UIImage
  func tabSwitcher(_ tabSwitcher: ColorTabs, tintColorAt index: Int) -> UIColor
  func titleTextColor() -> UIColor
  func titleFont() -> UIFont
  func backgroundColor() -> UIColor
  func hightlightIconTintColor(_ index: Int) -> UIColor
  func normalIconTintColor() -> UIColor
  func buttonTintColor() -> UIColor
  
}

open class ColorTabs: UIControl {
  
  open weak var dataSource: ColorTabsDataSource?
  
  /// Text color for titles.
  open var titleTextColor: UIColor?
  
  /// Font for titles.
  open var titleFont: UIFont?
  
  fileprivate let stackView = UIStackView()
  fileprivate let stackView1 = UIStackView()
  fileprivate let stackView2 = UIStackView()
  fileprivate var buttons: [UIButton] = []
  fileprivate var labels: [UILabel] = []
  fileprivate(set) lazy var highlighterView: UIView = {
    let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 0, height: self.bounds.height))
    let highlighterView = UIView(frame: frame)
    // highlighterView.layer.cornerRadius = self.bounds.height / 2
    self.addSubview(highlighterView)
    self.sendSubview(toBack: highlighterView)
    
    return highlighterView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  override open var frame: CGRect {
    didSet {
      stackView.frame = CGRect(x: 0, y: bounds.origin.y, width: bounds.width/3, height: bounds.height)//bounds
      stackView1.frame = CGRect(x: bounds.width/3, y: bounds.origin.y, width: bounds.width/3, height: bounds.height)
      stackView2.frame = CGRect(x: bounds.width/3 * 2, y: bounds.origin.y, width: bounds.width/3, height: bounds.height)
    }
  }
  
  override open var bounds: CGRect {
    didSet {
      //stackView.frame = bounds
      stackView.frame = CGRect(x: 0, y: bounds.origin.y, width: bounds.width/3, height: bounds.height)//bounds
      stackView1.frame = CGRect(x: bounds.width/3, y: bounds.origin.y, width: bounds.width/3, height: bounds.height)
      stackView2.frame = CGRect(x: bounds.width/3 * 2, y: bounds.origin.y, width: bounds.width/3, height: bounds.height)
    }
  }
  
  open var selectedSegmentIndex: Int = 0 {
    didSet {
      if oldValue != selectedSegmentIndex {
        transition(from: oldValue, to: selectedSegmentIndex)
        sendActions(for: .valueChanged)
      }
    }
  }
  
  open override func didMoveToWindow() {
    super.didMoveToWindow()
    
    if window != nil {
      layoutIfNeeded()
      let countItems = dataSource?.numberOfItems(inTabSwitcher: self) ?? 0
      if countItems > selectedSegmentIndex {
        transition(from: selectedSegmentIndex, to: selectedSegmentIndex)
      }
    }
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    
    moveHighlighterView(toItemAt: selectedSegmentIndex)
  }
  
  open func centerOfItem(atIndex index: Int) -> CGPoint {
    return buttons[index].center
  }
  
  open func setIconsHidden(_ hidden: Bool) {
    buttons.forEach {
      $0.alpha = hidden ? 0 : 1
    }
  }
  
  open func setHighlighterHidden(_ hidden: Bool) {
    let sourceHeight = hidden ? bounds.height : 0
    let targetHeight = hidden ? 0 : bounds.height
    
    let animation: CAAnimation = {
      $0.fromValue = sourceHeight / 2
      $0.toValue = targetHeight / 2
      $0.duration = HighlighterAnimationDuration
      return $0
    }(CABasicAnimation(keyPath: "cornerRadius"))
    highlighterView.layer.add(animation, forKey: nil)
    //highlighterView.layer.cornerRadius = targetHeight / 2
    
    UIView.animate(withDuration: HighlighterAnimationDuration, animations: {
      self.highlighterView.frame.size.height = targetHeight
      self.highlighterView.alpha = hidden ? 0 : 1
      
      for label in self.labels  {
        label.alpha = hidden ? 0 : 1
      }
    })
  }
  
  open func reloadData() {
    guard let dataSource = dataSource else {
      return
    }
    
    buttons = []
    labels = []
    let count = dataSource.numberOfItems(inTabSwitcher: self)
    for index in 0..<count {
      let button = createButton(forIndex: index, withDataSource: dataSource)
      buttons.append(button)
      //stackView.addArrangedSubview(button)
      
      
      let label = createLabel(forIndex: index, withDataSource: dataSource)
      labels.append(label)
      if index == 0 {
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(label)
      }
      if index == 1 {
        stackView1.addArrangedSubview(button)
        stackView1.addArrangedSubview(label)
      }
      if index == 2 {
        stackView2.addArrangedSubview(button)
        stackView2.addArrangedSubview(label)
      }
      //stackView.addArrangedSubview(label)
    }
  }
  
}

/// Setup
private extension ColorTabs {
  
  func commonInit() {
    addSubview(stackView)
    addSubview(stackView1)
    addSubview(stackView2)
    stackView.distribution = .fillProportionally
    stackView1.distribution = .fillProportionally
    stackView2.distribution = .fillProportionally
  }
  
  func createButton(forIndex index: Int, withDataSource dataSource: ColorTabsDataSource) -> UIButton {
    self.backgroundColor = dataSource.backgroundColor()
    let button = UIButton()
    button.tintColor = dataSource.buttonTintColor()
    button.setImage(dataSource.tabSwitcher(self, iconAt: index), for: UIControlState())
    button.setImage(dataSource.tabSwitcher(self, hightlightedIconAt: index), for: .selected)
    button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
    
    return button
  }
  
  func createLabel(forIndex index: Int, withDataSource dataSource: ColorTabsDataSource) -> UILabel {
    let label = UILabel()
    
    label.isHidden = true
    label.textAlignment = .left
    label.text = dataSource.tabSwitcher(self, titleAt: index)
    label.textColor = dataSource.titleTextColor()
    label.textAlignment = .center
    label.font = dataSource.titleFont()
    
    return label
  }
  
}

public extension ColorTabs {
  
  @objc func selectButton(_ sender: UIButton) {
    if let index = buttons.index(of: sender) {
      selectedSegmentIndex = index
    }
  }
  
  func transition(from fromIndex: Int, to toIndex: Int) {
    guard let fromLabel = labels[safe: fromIndex],
      let fromIcon = buttons[safe: fromIndex],
      let toLabel = labels[safe: toIndex],
      let toIcon = buttons[safe: toIndex] else {
        return
    }
    
    let animation = {
      fromLabel.isHidden = true
      fromLabel.alpha = 0
      fromIcon.isSelected = false
      fromIcon.imageView?.tintColor = self.dataSource!.normalIconTintColor()
      
      toLabel.isHidden = false
      toLabel.alpha = 1
      toIcon.isSelected = true
      toIcon.imageView?.tintColor = self.dataSource!.hightlightIconTintColor(toIndex)
      
      self.stackView.layoutIfNeeded()
      self.stackView1.layoutIfNeeded()
      self.stackView2.layoutIfNeeded()
      self.layoutIfNeeded()
      self.moveHighlighterView(toItemAt: toIndex)
    }
    
    UIView.animate(
      withDuration: SwitchAnimationDuration,
      delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 3,
      options: [],
      animations: animation,
      completion: nil
    )
  }
  
  func moveHighlighterView(toItemAt toIndex: Int) {
    guard let countItems = dataSource?.numberOfItems(inTabSwitcher: self) , countItems > toIndex else {
      return
    }
    
    if toIndex == 0 {
      highlighterView.frame.origin.x = stackView.frame.origin.x
    }
    if toIndex == 1 {
      highlighterView.frame.origin.x = stackView1.frame.origin.x
    }
    if toIndex == 2 {
      highlighterView.frame.origin.x = stackView2.frame.origin.x
    }
    highlighterView.frame.size.width = stackView.frame.width
    highlighterView.layer.addBorder(edge: .bottom, color: dataSource!.tabSwitcher(self, tintColorAt: toIndex), thickness: 1)
  }
}

