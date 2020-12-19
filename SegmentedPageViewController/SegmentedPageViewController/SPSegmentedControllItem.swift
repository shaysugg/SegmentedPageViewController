//
//  SPSegmentControllerItem.swift
//  SegmentedPageViewController
//
//  Created by Sha Yan on 12/12/20.
//

import Foundation
import UIKit


protocol SPSegmentedControllItemDelegate: class {
    func itemDidSelected(_ item: SPSegmentedControllItem, withIndex index: Int)
}


final class SPSegmentedControllItem: UIView  {
    
    //MARK:- Variables
    
    private var icon: UIImage? = nil
    private var selectedIcon: UIImage? = nil
    
    public var highlightColor: UIColor = .systemBlue { didSet {
        highlightLabel.textColor = highlightColor
        highlightIconView.tintColor = highlightColor
    }}
    
    public var textColor: UIColor = .secondaryLabel { didSet {
        label.textColor = textColor
    }}
    
    public var name: String { didSet {
        label.text = name
        highlightLabel.text = name
    }}
    
    public var font: UIFont! { didSet {
        label.font = font
        highlightLabel.font = font
    }}
    
    public var highlightAlpha = CGFloat(1) { didSet {
        highlightLabel.alpha = highlightAlpha
        highlightIconView.alpha = highlightAlpha
        iconView.alpha = 1 - highlightAlpha
    }}
    
    
    private(set) var index: Int
    weak var delegate: SPSegmentedControllItemDelegate?
    
    
    public var isSelected = false { didSet {
        highlightLabel.alpha = isSelected ? 1 : 0
        iconView.alpha = !isSelected ? 1 : 0
        highlightIconView.alpha = isSelected ? 1 : 0
    }}
    
    private var fillBasedOnWidth: Bool = true
    
    
    
    //MARK:- UIKit Variables
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = textColor
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var highlightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = highlightColor
        label.isUserInteractionEnabled = true
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = textColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private lazy var highlightIconView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = highlightColor
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    private lazy var HStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(didTapped))
    
    
    //MARK:- Functions
    
    init(index: Int,
         icon: UIImage?,
         selectedIcon: UIImage?,
         name: String,
         fillBasedOnWidth: Bool,
         selectedColor: UIColor,
         deselctedColor: UIColor,
         frame: CGRect = .zero) {
        
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.name = name
        self.fillBasedOnWidth = fillBasedOnWidth
        self.index = index
        super.init(frame: frame)
        
        addLabelWithIcon()
        addHighlighLabel()
        addHigHighlightIconIfExist()
        assignValues()
        
        addGestureRecognizer(tapGestureRecogniser)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func addLabelWithIcon() {
        
        addSubview(HStackView)
        
        //We just center HStackView which is ok for when we want equal items in SPSegmentController
        HStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        HStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
        //But When we want proportional items we need width of item which based on its text and image.
        //So super stackView which fills proportionally and contains item, know the item height and will give the item the space that it needs
        if fillBasedOnWidth {
            HStackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 1).isActive = true
        }
        
        if icon != nil || selectedIcon != nil {
            HStackView.addArrangedSubview(iconView)
        }
        HStackView.addArrangedSubview(label)
        
        iconView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
    }
    
    
    private func addHighlighLabel() {
        addSubview(highlightLabel)
        highlightLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        highlightLabel.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        highlightLabel.widthAnchor.constraint(equalTo: label.widthAnchor).isActive = true
        highlightLabel.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
    }
    
    private func addHigHighlightIconIfExist() {
        if selectedIcon == nil { return }
        
        addSubview(highlightIconView)
        highlightIconView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor).isActive = true
        highlightIconView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor).isActive = true
        highlightIconView.widthAnchor.constraint(equalTo: iconView.widthAnchor).isActive = true
        highlightIconView.heightAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true
        
    }
    
    private func assignValues() {
        iconView.image = icon
        label.text = name
        highlightLabel.text = name
        highlightIconView.image = selectedIcon
    }
    
    @objc private func didTapped() {
        delegate?.itemDidSelected(self, withIndex: index)
    }
    
}
