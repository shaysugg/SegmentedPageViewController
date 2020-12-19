//
//  SegmentedPageViewController.swift
//  SegmentedPageViewController
//
//  Created by Sha Yan on 10/17/20.
//

import UIKit


protocol SegmentedPageViewControllerDelegate: class {
    ///Use this delegate function to know when SegmentedPageViewController completely transitioned to another page
    func pageControllerScrolledToPage(withIndex index: Int)
}

extension SegmentedPageViewControllerDelegate {
    func pageControllerScrolledToPage(withIndex index: Int) {}
}


class SegmentedPageViewController: UIViewController {
    
    //MARK:- Variables
    
    ///An item of SegmentedPageViewController.
    struct Page {
        let viewController: UIViewController
        var icon: UIImage? = nil
        var selectedIcon: UIImage? = nil
        let title: String
    }
    private(set) public var pages = [Page]()
    
    
    var viewControllers: [UIViewController] {
        pages.map{ $0.viewController }
    }
    
    
    ///How items of SegmentController should distribute.
    enum SegmentControllFilMode {
        case proportionally
        case equally
    }
    private var fillMode: SegmentControllFilMode!
    
    
    public weak var delegate: SegmentedPageViewControllerDelegate?
    
    ///These variables use for handelling transition of SegmentController components when user manually scrolls PageViewController.
    
    private var scrollViewInitialOffset = CGFloat(0)
    private var currentVCIndex = 0
    private var isScrollViewDragging = false { didSet {
        //Disable these two components temporarily during dragging to prevent possible issues.
        pageViewController.view.isUserInteractionEnabled = !isScrollViewDragging
        segmentController.isUserInteractionEnabled = !isScrollViewDragging
    } }
    
    //MARK:- UIKit Variables
    
    private var pageViewController: UIPageViewController!
    var segmentController: SPSegmentedControll!
    
    
    //MARK:- Initializer
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(pages: [Page], segmentControllerFillMode: SegmentControllFilMode) {
        self.init()
        self.pages = pages
        self.fillMode = segmentControllerFillMode
        self.segmentController = SPSegmentedControll(
            items: pages.convertToSegmenItems(),
            shouldFillProportionally: segmentControllerFillMode == .proportionally)
    }
    
    
    
    //MARK:- Functions
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        
        addSegmentController()
        addPageViewController()
        
        selectFirstPage()
        
        segmentController.delegate = self
        pageViewController.delegate = self
        pageViewController.dataSource = self
        scrollViewOfPageViewController().delegate = self
        
    }
    
    private func addSegmentController() {
        view.addSubview(segmentController)
        segmentController.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        segmentController.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        segmentController.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
    }
    
    
    private func addPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                  navigationOrientation: .horizontal)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.backgroundColor = .clear
        
        pageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: segmentController.bottomAnchor).isActive = true
        
    }
    
    
    private func scrollViewOfPageViewController() -> UIScrollView {
        return pageViewController.view.subviews.filter{$0 is UIScrollView}.first as! UIScrollView
    }
    
    
    private func selectFirstPage() {
        segmentController.itemViews.first?.isSelected = true
        guard let firstVC = viewControllers.first else { return }
        pageViewController.setViewControllers([firstVC],
                                              direction: .forward,
                                              animated: false,
                                              completion: nil)
    }
    
}

//MARK:- PageController Delegates

extension SegmentedPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    final func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        viewControllers.viewController(before: viewController)
    }
    
    final func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        viewControllers.viewController(after: viewController)
    }
    
    final func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard let currentVC = (pageViewController.viewControllers?.first),
              let index = viewControllers.firstIndex(of: currentVC) else{ return }
        
        segmentController.chooseItemAsSelected(at: index)
        segmentController.moveUnderlineImageView(toItemAtIndex: index, animated: false)
        
        currentVCIndex = index
        isScrollViewDragging = false
        
        delegate?.pageControllerScrolledToPage(withIndex: index)
    }
    
    
}


//MARK:- SPSegmentController Delegates

extension SegmentedPageViewController: SPSegmentedContollDelegate {
    func itemChoosed(withIndex index: Int) {
        pageViewController.jumpToViewController(withIndex: index, wichExistsIn: viewControllers)
        currentVCIndex = index
    }
}


//MARK:- ScrollView Delegates

extension SegmentedPageViewController: UIScrollViewDelegate {
    
    final func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewInitialOffset = scrollView.contentOffset.x
        isScrollViewDragging = true
    }
    
    final func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrollViewDragging = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //First whe make sure that scrolling caused by user dragging, not programaticlly scroll
        guard isScrollViewDragging else { return }
        
        //Figure out which diraction user is scrolling
        var direction = 0
        if scrollViewInitialOffset < scrollView.contentOffset.x {
            direction = 1 //going right
        }else if scrollViewInitialOffset > scrollView.contentOffset.x {
            direction = -1 //going left
        }
        
        //Configure which percent have been scrolled
        let positionFromStartOfCurrentPage = abs(scrollViewInitialOffset - scrollView.contentOffset.x)
        let percent = positionFromStartOfCurrentPage /  self.view.frame.width
        
        
        //Make sure user scrolles between items
        guard (0..<segmentController.itemViews.count).contains(currentVCIndex + direction)
        else { return }
        
        //Configuring some parametes
        let currentItem = segmentController.itemViews[currentVCIndex]
        let nextItem = segmentController.itemViews[currentVCIndex + direction]
        let currentItemWidth = currentItem.bounds.width
        let nextItemWidth = nextItem.bounds.width
        let spacing = segmentController.spacing
        
        //MAGIC!
        //Use this parameters in these magic formulas
        //To figure out tranformation based on percent of scrollView that been dragged
        let xshift = ((currentItemWidth + nextItemWidth) / 2 + spacing) * percent * CGFloat(direction)
        let widthDifference = (nextItemWidth - currentItemWidth) * percent
        
        let transform = CGAffineTransform(translationX: xshift, y: 0)
        
        segmentController.transformUnderlineImageView(by: transform)
        segmentController.addToUnderlineImageViewWidth(constant: widthDifference)
        
        //This prevents the situation which scroll ended up in the same item and 0 percent cause a flickering on highlithing SegmentController item
        if direction == 0 && percent == 0 { return }
        
        //highlight SegmentController item base on percent of scrollView that been dragged
        currentItem.highlightAlpha = 1 - percent
        nextItem.highlightAlpha = percent
    }
    
    
    
    
}


//MARK:- [ViewController] Extensions

fileprivate extension Array where Element == UIViewController {
    func viewController(after viewController: UIViewController) -> UIViewController? {
        
        if let index = self.firstIndex(of: viewController){
            if index < self.count - 1 {
                return self[index + 1]
            }else {
                return nil
            }
        }
        return nil
    }
    
    
    func viewController(before viewController: UIViewController) -> UIViewController? {
        
        if let index = self.firstIndex(of: viewController) {
            if index > 0 {
                return self[index - 1]
            }else {
                return nil
            }
        }
        return nil
    }
}

//MARK:- PageController Extensions

fileprivate extension UIPageViewController {
    func jumpToViewController(withIndex index: Int, wichExistsIn viewControllers: [UIViewController]) {
        if let currentVC = self.viewControllers?.first,
           let currentIndex = viewControllers.firstIndex(of: currentVC) {
            
            if index > currentIndex {
                self.setViewControllers([viewControllers[index]],
                                        direction: .forward,
                                        animated: true,
                                        completion: nil)
                
            }else if index < currentIndex {
                self.setViewControllers([viewControllers[index]],
                                        direction: .reverse,
                                        animated: true,
                                        completion: nil)
            }
        }
    }
    
}


fileprivate extension Array where Element == SegmentedPageViewController.Page {
    func convertToSegmenItems() -> [SPSegmentedControll.ItemInfo] {
        self.map {
            SPSegmentedControll.ItemInfo(
                icon: $0.icon,
                selectedIcon: $0.selectedIcon,
                name: $0.title)
        }
    }
}
