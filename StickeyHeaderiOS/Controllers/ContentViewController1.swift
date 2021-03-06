//
//  ContentViewController1.swift
//  StickeyHeaderiOS
//
//  Created by Sowndharya M on 06/01/18.
//  Copyright © 2018 Sowndharya M. All rights reserved.
//

import UIKit

enum DragDirection {
    
    case Up
    case Down
}

protocol InnerTableViewScrollDelegate: class {
    var currentTopConstraint: CGFloat { get }
    func innerTableViewDidScroll(withDistance scrollDistance: CGFloat)
}

class ContentViewController1: UIViewController {
    
    //MARK:- Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Scroll Delegate
    
    weak var innerTableViewScrollDelegate: InnerTableViewScrollDelegate?
    
    //MARK:- Stored Properties for Scroll Delegate
    
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    //MARK:- Data Source
    
    var numberOfCells: Int = 0
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    //MARK:- View Setup
    
    func setupTableView() {
        
        tableView.register(UINib(nibName: TabTableViewCellID, bundle: nil),
                           forCellReuseIdentifier: TabTableViewCellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
    }
}


//MARK:- Table View Data Source

extension ContentViewController1: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: TabTableViewCellID) as? TabTableViewCell {
            
            cell.cellLabel.text = "This is cell \(indexPath.row + 1)"
            return cell
        }
        
        return UITableViewCell()
    }
}

//MARK:- Scroll View Actions

extension ContentViewController1: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var delta = scrollView.contentOffset.y - oldContentOffset.y
        
        if let currentTopConstraint = innerTableViewScrollDelegate?.currentTopConstraint {
            
            /**
             *  Push above only when the conditions meet:-
             *  1. The current offset of the table view should be greater than the previous offset indicating an upward scroll.
             *  2. The top view's height should be within its minimum height.
             *  3. Optional - Collapse the header view only when the table view's edge is below the above view - This case will occur if you are using Step 2 of the next condition and have a refresh control in the table view.
             */
            
            delta = min(delta, 200 - currentTopConstraint)
            if delta > 0,
                currentTopConstraint > -200,
                scrollView.contentOffset.y > 0 {
                
                dragDirection = .Up
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            /**
             *  Bring it down only when the conditions meet:-
             *  1. The current offset of the table view should be lesser than the previous offset indicating an downward scroll.
             *  2. Optional - The top view's height should be within its maximum height. Skipping this step will give a bouncy effect. Note that you need to write extra code in the outer view controller to bring back the view to the maximum possible height.
             *  3. Expand the header view only when the table view's edge is below the header view, else the table view should first scroll till it's offset is 0 and only then the header should expand.
             */
            
            if delta < 0,
               currentTopConstraint < 0,
                scrollView.contentOffset.y < 0 {
                
                dragDirection = .Down
                innerTableViewScrollDelegate?.innerTableViewDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
}
