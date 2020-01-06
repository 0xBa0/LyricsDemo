//
//  ViewController.swift
//  LyricsDemo
//
//  Created by Zack.Zhang on 2/1/2020.
//  Copyright © 2020 Zack.Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var selectedIndexPath: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let cellHeight: CGFloat = 44
        tableView.contentInset = UIEdgeInsets(top: (tableView.bounds.height - cellHeight) / 2,
                                              left: 0,
                                              bottom: (tableView.bounds.height - cellHeight) / 2,
                                              right: 0)
        tableView.scrollToRow(at: IndexPath(row: tableView.numberOfRows(inSection: 0) / 2, section: 0),
                              at: .middle,
                              animated: false)
        selectedIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 0) / 2, section: 0)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath) as! DemoCell
        cell.demoLabel.text = "row: \(indexPath.row)"
        cell.demoLabel.textColor = .yellow
        cell.demoLabel.targetColor = .red
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = Array(0..<tableView.numberOfRows(inSection: 0)).map{ IndexPath(row: $0, section: 0) }
        for indexPath in indexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? DemoCell {
                cell.drawDemoLabel(contentOffset: scrollView.contentOffset.y,
                                   contentInset: tableView.contentInset.top,
                                   current: indexPath.row)
            }
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
       let targetPoint = CGPoint(x: 0, y: targetContentOffset.pointee.y + tableView.contentInset.top)
        if let selectedIndexPath = tableView.indexPathForRow(at: targetPoint) {
            let fixedPoint = CGPoint(x: 0, y: 44 * CGFloat(selectedIndexPath.row) - tableView.contentInset.top)
            targetContentOffset.pointee = fixedPoint
            self.selectedIndexPath = selectedIndexPath
        }
    }
}

class DemoCell: UITableViewCell {
    
    @IBOutlet weak var demoLabel: DemoLabel!
    
    func drawDemoLabel(contentOffset y: CGFloat,
                       contentInset top: CGFloat,
                       current row: Int) {
        // label和cell等高
        let height = self.bounds.height
        // 计算开始渲染的Y值
        let beginDrawY: CGFloat = y - height * CGFloat(row) + top + height
        if beginDrawY <= height {
            // 进入行时，从顶部开始渲染高亮颜色
            demoLabel.draw(targetProgress: beginDrawY / height)
        }
        else {
            // 离开行时，从顶部开始渲染原本的颜色
            demoLabel.draw(sourceProgress: (beginDrawY - height) / height)
        }
    }
    
}

class DemoLabel: UILabel {
    
    var targetColor: UIColor!
    private var progress: CGFloat = 0.0
    private var isDrawSourceColor: Bool = false
    
    func draw(targetProgress: CGFloat) {
        self.isDrawSourceColor = false
        self.progress = targetProgress
        self.setNeedsDisplay()
    }
    
    func draw(sourceProgress: CGFloat) {
        self.isDrawSourceColor = true
        self.progress = sourceProgress
        self.setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
                        
        targetColor.set()
        // source in 选择Label颜色
        // Label和cell的高度一致
        if isDrawSourceColor {
            let targetRect = CGRect(x: rect.origin.x,
                                    y: rect.height * progress,
                                    width: rect.width,
                                    height: rect.height)
            UIRectFillUsingBlendMode(targetRect, .sourceIn)
        }
        else {
            let targetRect = CGRect(x: rect.origin.x,
                                    y: rect.origin.y,
                                    width: rect.width,
                                    height: rect.height * progress)
            UIRectFillUsingBlendMode(targetRect, .sourceIn)
        }
        

    }
    
}
