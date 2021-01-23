//
//  SPSegmentController.swift
//  SegmentedPageViewController
//
//  Created by Sha Yan on 10/17/20.
//

import UIKit

protocol SPSegmentedContollDelegate: class {
    func itemChoosed(withIndex index: Int)
}

final class SPSegmentedControll: UIView {
    
    //MARK:- Customizable Values
    
    ///Values which can be used to customize SPSegmentController Appereance
    
    ///The color of selected item
    public var highlightColor: UIColor = .systemBlue { didSet {
        itemViews.forEach { $0.highlightColor = highlightColor }
        underlineImageView.tintColor = highlightColor
        setUnderlineImageViewBackgroundIfNeeded()
    }}
    
    
    //The color of unselected items
    public var textColor: UIColor = .secondaryLabel { didSet {
        itemViews.forEach { $0.textColor = textColor }
    }}
    
    public var font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize) { didSet {
        itemViews.forEach {$0.font = font}
    }}
    
    /**
     The Image which always be in center bottom of selected Item
     If Image set as nil a view with backgroundColor of highlightColor appears instead
     */
    public var underlineImage: UIImage? { didSet {
        underlineImageView.image = underlineImage
        setUnderlineImageViewBackgroundIfNeeded()
    }}
    
    public var underlineImageViewCornerRadius: CGFloat = 0 { didSet {
        underlineImageView.layer.cornerRadius = underlineImageViewCornerRadius
    }}
    
    public var underlineHeight: CGFloat = 3 { didSet {
        underlineViewHeightConstraint?.constant = underlineHeight
        stackViewBottomConstraint.constant = -underlineHeight
        layoutIfNeeded()
    }}
    
    ///This variable changes the height of SegmentController
    public var itemsHeight: CGFloat = 50 { didSet {
        stackViewHeighConstraint.constant = itemsHeight
        layoutSubviews()
    }}
    
    public var underlineMovementAnimationLenght: Double = 0.3
    
    ///This variable changes the space between items of SegmentController
    public var spacing = CGFloat(5) {
        didSet { stackView.spacing = spacing }
    }
    
    
    //MARK:- Variables
    
    ///This is what an item of SPSegmentController should contains.
    public struct ItemInfo {
        var icon: UIImage? = nil
        var selectedIcon: UIImage? = nil
        let name: String
    }
    private(set) var itemInfos = [ItemInfo]()
    
    ///Views that have been created based on itemInfos that passed in initializer
    private(set) var itemViews = [SPSegmentedControllItem]()
    
    weak var delegate: SPSegmentedContollDelegate?
    
    private(set) var shouldFillProportionally: Bool = true
    
    
    //MARK:- UIKit Variables
    
    
    private lazy var underlineImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.backgroundColor = highlightColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var underlineViewCenterXConstrait: NSLayoutConstraint?
    private var underlineViewWidthConstraint: NSLayoutConstraint?
    private var underlineViewHeightConstraint: NSLayoutConstraint?
    
    
    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    private var stackViewHeighConstraint: NSLayoutConstraint!
    private var stackViewBottomConstraint: NSLayoutConstraint!
    
    
    //MARK:- Initializers
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addStackView()
    }
    
    convenience init(items: [ItemInfo], shouldFillProportionally: Bool) {
        self.init()
        self.itemInfos = items
        self.shouldFillProportionally = shouldFillProportionally
        addItemsToStackView()
        addUnderlineView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK:- Setup Design Functions
    
    private func addStackView() {
        addSubview(stackView)
        stackView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -underlineHeight)
        stackViewHeighConstraint = stackView.heightAnchor.constraint(equalToConstant: itemsHeight)
        stackViewHeighConstraint.isActive = true
        stackViewBottomConstraint.isActive = true
        
    }
    
    private func addUnderlineView() {
        
        guard let firstItemView = itemViews.first else { return }
        
        addSubview(underlineImageView)
        underlineImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        underlineViewCenterXConstrait = underlineImageView.centerXAnchor.constraint(equalTo: firstItemView.centerXAnchor)
        underlineViewCenterXConstrait?.isActive = true
        
        underlineViewWidthConstraint = underlineImageView.widthAnchor.constraint(equalTo: firstItemView.widthAnchor)
        underlineViewWidthConstraint?.isActive = true
        
        underlineViewHeightConstraint = underlineImageView.heightAnchor.constraint(equalToConstant: underlineHeight)
        underlineViewHeightConstraint?.isActive = true
        
    }
    
    
    private func addItemsToStackView() {
        var index = 0
        for item in itemInfos {
            let itemView = SPSegmentedControllItem(
                index: index,
                icon: item.icon,
                selectedIcon: item.selectedIcon,
                name: item.name,
                fillBasedOnWidth: shouldFillProportionally,
                selectedColor: highlightColor,
                deselctedColor: textColor)
            
            itemView.delegate = self
            
            itemViews.append(itemView)
            stackView.addArrangedSubview(itemView)
            
            index += 1
        }
        
    }
    
    private func setUnderlineImageViewBackgroundIfNeeded() {
        underlineImageView.backgroundColor = underlineImage == nil ? highlightColor : .clear
    }
    
    //MARK:- Functions
    
    func chooseItemAsSelected(at index: Int) {
        guard (0..<itemViews.count).contains(index) else { return }
        
        itemViews.forEach {$0.isSelected = false}
        itemViews[index].isSelected = true
    }
    
    func moveUnderlineImageView(toItemAtIndex index: Int, animated: Bool) {
        let item = itemViews[index]
        
        //Reset any transform that caused by transformUnderlineImageView
        underlineImageView.transform = CGAffineTransform(translationX: 0, y: 0)
                
        //Move underlineImageView to the center of selectedItemIndex by enabling constraint
        underlineViewCenterXConstrait?.isActive = false
        underlineViewWidthConstraint?.isActive = false
        underlineViewCenterXConstrait = underlineImageView.centerXAnchor.constraint(equalTo: item.centerXAnchor)
        underlineViewWidthConstraint = underlineImageView.widthAnchor.constraint(equalTo: item.widthAnchor)
        underlineViewCenterXConstrait?.isActive = true
        underlineViewWidthConstraint?.isActive = true
        
        if animated {
            UIView.animate(
                withDuration: underlineMovementAnimationLenght,
                delay: 0,
                options: .curveEaseInOut,
                animations: {
                    self.layoutIfNeeded()
                }, completion: nil)
            
        }else {
            layoutIfNeeded()
        }
    }
    
    
    func transformUnderlineImageView(by transform: CGAffineTransform) {
        underlineImageView.transform = transform
    }
    
    
    func addToUnderlineImageViewWidth(constant: CGFloat) {
        underlineViewWidthConstraint?.constant = constant
        layoutIfNeeded()
    }
    
}


//MARK:- SPSegment Item Delegate

extension SPSegmentedControll: SPSegmentedControllItemDelegate {
    func itemDidSelected(_ item: SPSegmentedControllItem, withIndex index: Int) {
        delegate?.itemChoosed(withIndex: index)
        
        chooseItemAsSelected(at: index)
        moveUnderlineImageView(toItemAtIndex: index, animated: true)
        
    }
    
}

//MARK:- Constraint Extensions

fileprivate extension NSLayoutConstraint {
    func withHighPriority() -> NSLayoutConstraint {
        self.priority = UILayoutPriority(999)
        return self
    }
    
    func withLowPriority() -> NSLayoutConstraint {
        self.priority = UILayoutPriority(150)
        return self
    }
}
