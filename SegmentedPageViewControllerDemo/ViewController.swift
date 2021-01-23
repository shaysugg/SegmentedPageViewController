//
//  ViewController.swift
//  SegmentedPageViewController
//
//  Created by Sha Yan on 10/17/20.
//

import UIKit

class ViewController: UIViewController {

    lazy var viewcontrollers: [UIViewController] = { makeExampleViewControlers() }()
    var segmentedPageVC: SegmentedPageViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSegmentedPageViewController()
        customizeSegmentedPageViewController2()
        
        view.backgroundColor = .systemBackground
    }
    
    private func addSegmentedPageViewController() {
        
        segmentedPageVC = SegmentedPageViewController(
            pages: [
                .init(viewController: viewcontrollers[0],
                      icon: UIImage(systemName: "ladybug"),
                      selectedIcon: UIImage(systemName: "ladybug.fill"),
                      title: "Page1"),
                
                .init(viewController: viewcontrollers[1],
                      icon: UIImage(systemName: "face.smiling"),
                      selectedIcon: UIImage(systemName: "face.smiling.fill"),
                      title: "Page2"),
                
                .init(viewController: viewcontrollers[2],
                      title: "Very Long Title Page3")
            ]
            
            ,segmentControllerFillMode: .proportionally)
        
        
        self.addChild(segmentedPageVC)
        view.addSubview(segmentedPageVC.view)
        segmentedPageVC.didMove(toParent: self)
        
    }
    
    
    
    
    
    private func makeExampleViewControlers() -> [UIViewController] {
        let vc1 = ExampleViewController()
        vc1.labelTitle = "First View Controller"
        vc1.view.backgroundColor = .systemYellow
        
        let vc2 = ExampleViewController()
        vc2.labelTitle = "Second View Controller"
        vc2.view.backgroundColor = .systemRed
        
        let vc3 = ExampleViewController()
        vc3.labelTitle = "Third View Controller"
        vc3.view.backgroundColor = .systemGreen
        
        return [vc1, vc2, vc3]
    }
}


extension ViewController {
    private func customizeSegmentedPageViewController1() {
        segmentedPageVC.segmentController.highlightColor = .systemRed
        segmentedPageVC.segmentController.underlineHeight = 20
        segmentedPageVC.segmentController.itemsHeight = 40
        segmentedPageVC.segmentController.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        segmentedPageVC.segmentController.textColor = .systemGray6
        segmentedPageVC.segmentController.underlineImage = UIImage(systemName: "triangle.fill")
    }
    
    
    private func customizeSegmentedPageViewController2() {
        segmentedPageVC.segmentController.highlightColor = .label
        segmentedPageVC.segmentController.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        segmentedPageVC.segmentController.textColor = .secondaryLabel
        segmentedPageVC.segmentController.underlineHeight = 10
        segmentedPageVC.segmentController.underlineImageViewCornerRadius = 5
        segmentedPageVC.segmentController.underlineImage = nil
    }
}


fileprivate class ExampleViewController: UIViewController {
    
    public var labelTitle: String = "" { didSet {
        label.text = labelTitle
    }}
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}
