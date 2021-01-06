//
//  ContainerViewController.swift
//  StickeyHeaderiOS
//
//  Created by Faizan Memon on 06/01/21.
//

import UIKit

class StickyHeaderViewController2: UIViewController {
    
    //MARK:- Change this value for number of tabs.
    
    let tabsCount = 5;
    
    //MARK:- Outlets
    
    @IBOutlet weak var stickyHeaderView: UIView!
    @IBOutlet weak var tabBarCollectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint!
    
    //MARK:- Programatic UI Properties
    
    var pageViewController = UIPageViewController()
    var selectedTabView = UIView()
    
    //MARK:- Model
    
    var pageCollection = PageCollection()
    
    //MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupPagingViewController()
        populateBottomView()
    }
    
    //MARK: View Setup
    
    func setupCollectionView() {
        
        let layout = tabBarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.estimatedItemSize = CGSize(width: 100, height: 50)
        
        tabBarCollectionView.register(UINib(nibName: TabBarCollectionViewCellID, bundle: nil),
                                      forCellWithReuseIdentifier: TabBarCollectionViewCellID)
        tabBarCollectionView.dataSource = self
        tabBarCollectionView.delegate = self
        tabBarCollectionView.showsHorizontalScrollIndicator = false
        tabBarCollectionView.bounces = false
        setupSelectedTabView()
    }
    
    func setupSelectedTabView() {
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        label.text = "TAB \(1)"
        label.sizeToFit()
        var width = label.intrinsicContentSize.width
        width = width + 40
        
        selectedTabView.frame = CGRect(x: 20, y: 55, width: width, height: 5)
        selectedTabView.backgroundColor = UIColor(red:0.65, green:0.58, blue:0.94, alpha:1)
        tabBarCollectionView.addSubview(selectedTabView)
    }
    
    func setupPagingViewController() {
        
        pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    func populateBottomView() {
        
        for subTabCount in 0..<tabsCount {
            
            let tabContentVC = ContentViewController1()
            tabContentVC.innerTableViewScrollDelegate = self
            tabContentVC.numberOfCells = (subTabCount + 1) * 5
            
            let displayName = "TAB \(subTabCount + 1)"
            let page = Page(with: displayName, _vc: tabContentVC)
            pageCollection.pages.append(page)
        }
        
        let initialPage = 0
        
        pageViewController.setViewControllers([pageCollection.pages[initialPage].vc],
                                                  direction: .forward,
                                                  animated: true,
                                                  completion: nil)
        
        

        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        bottomView.addSubview(pageViewController.view)
        pinPagingViewControllerToBottomView()
    }
    
    func pinPagingViewControllerToBottomView() {
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        pageViewController.view.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
    }

    
    //MARK:- UI Laying Out Methods
    
    func setBottomPagingView(toPageWithAtIndex index: Int, andNavigationDirection navigationDirection: UIPageViewController.NavigationDirection) {
        
        pageViewController.setViewControllers([pageCollection.pages[index].vc],
                                                  direction: navigationDirection,
                                                  animated: true,
                                                  completion: nil)
    }
    
    func scrollSelectedTabView(toIndexPath indexPath: IndexPath, shouldAnimate: Bool = true) {
            if let cell = self.tabBarCollectionView.cellForItem(at: indexPath) {
                self.selectedTabView.frame.size.width = cell.frame.width
                self.selectedTabView.frame.origin.x = cell.frame.origin.x
            }
    }
}

//MARK:- Collection View Data Source

extension StickyHeaderViewController2: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return pageCollection.pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let tabCell = collectionView.dequeueReusableCell(withReuseIdentifier: TabBarCollectionViewCellID, for: indexPath) as? TabBarCollectionViewCell {
            
            tabCell.tabNameLabel.text = pageCollection.pages[indexPath.row].name
            return tabCell
        }
        
        return UICollectionViewCell()
    }
}

//MARK:- Collection View Delegate

extension StickyHeaderViewController2: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item == pageCollection.selectedPageIndex {
            
            return
        }
        
        var direction: UIPageViewController.NavigationDirection
        
        if indexPath.item > pageCollection.selectedPageIndex {
            
            direction = .forward
            
        } else {
            
            direction = .reverse
        }
        
        pageCollection.selectedPageIndex = indexPath.item
        
        tabBarCollectionView.scrollToItem(at: indexPath,
                                          at: .centeredHorizontally,
                                          animated: true)
        
        scrollSelectedTabView(toIndexPath: indexPath)
        
        setBottomPagingView(toPageWithAtIndex: indexPath.item, andNavigationDirection: direction)
    }
}

//MARK:- Delegate Method to give the next and previous View Controllers to the Page View Controller

extension StickyHeaderViewController2: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (1..<pageCollection.pages.count).contains(currentViewControllerIndex) {
                
                // go to previous page in array
                
                return pageCollection.pages[currentViewControllerIndex - 1].vc
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let currentViewControllerIndex = pageCollection.pages.firstIndex(where: { $0.vc == viewController }) {
            
            if (0..<(pageCollection.pages.count - 1)).contains(currentViewControllerIndex) {
                
                // go to next page in array
                
                return pageCollection.pages[currentViewControllerIndex + 1].vc
            }
        }
        return nil
    }
}

//MARK:- Delegate Method to tell Inner View Controller movement inside Page View Controller
//Capture it and change the selection bar position in collection View

extension StickyHeaderViewController2: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        
        guard let currentVC = pageViewController.viewControllers?.first else { return }
        
        guard let currentVCIndex = pageCollection.pages.firstIndex(where: { $0.vc == currentVC }) else { return }
        
        let indexPathAtCollectionView = IndexPath(item: currentVCIndex, section: 0)
        
        scrollSelectedTabView(toIndexPath: indexPathAtCollectionView)
        tabBarCollectionView.scrollToItem(at: indexPathAtCollectionView,
                                          at: .centeredHorizontally,
                                          animated: true)
    }
}

//MARK:- Sticky Tab Effect

extension StickyHeaderViewController2: InnerTableViewScrollDelegate {

    var currentTopConstraint: CGFloat {
        return headerViewTopConstraint.constant
    }

    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat) {
        headerViewTopConstraint.constant -= scrollDistance
    }
}
