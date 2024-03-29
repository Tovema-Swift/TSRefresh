//
//  TSRefreshAutoFooter.swift
//  TSRefreshExanple
//
//  Created by Lee on 2018/8/22.
//  Copyright © 2018年 LEE. All rights reserved.
//

import UIKit

open class TSRefreshAutoFooter: TSRefreshFooter {
    /// 是否自动刷新(默认为YES)
    public var automaticallyRefresh: Bool = true
    /// 当底部控件出现多少时就自动刷新(默认为1.0，也就是底部控件完全出现时，才会自动刷新)
    public var triggerAutomaticallyRefreshPercent: CGFloat = 1.0
    /// 是否每一次拖拽只发一次请求
    public var onlyRefreshPerDrag: Bool = false
    /// 一个新的拖拽
    var oneNewPan: Bool = false

    open override var state: TSRefreshState {
        set(newState) {
            // 状态检查
            let oldState = self.state
            if oldState == newState {
                return
            }
            super.state = newState

            // 根据状态做事情
            if newState == .Refreshing {
                executeRefreshingCallback()
            } else if newState == .NoMoreData || state == .Idle {
                if oldState == .Refreshing {
                    endRefreshingCompletionBlock?()
                }
            }
        }
        get {
            return super.state
        }
    }

    open override var isHidden: Bool {
        set(newHidden) {
            let lastHidden = isHidden
            super.isHidden = newHidden

            if !lastHidden, newHidden {
                state = .Idle
                scrollView?.insetBottom -= height
            } else if lastHidden, !newHidden {
                scrollView?.insetBottom += height
                y = scrollView?.contentH ?? 0
            }
        }
        get {
            return super.isHidden
        }
    }
}

extension TSRefreshAutoFooter {
    open override func prepare() {
        super.prepare()
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            if isHidden == false {
                scrollView?.insetBottom += height
            }
            // 设置位置
            y = scrollView?.contentH ?? 0
        } else { // 被移除了
            if isHidden == false {
                scrollView?.insetBottom -= height
            }
        }
    }

    open override func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey: Any]?) {
        super.scrollViewContentSizeDidChange(change)

        // 设置位置
        y = scrollView?.contentH ?? 0
    }

    open override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey: Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        if state != .Idle || !automaticallyRefresh || y == 0 {
            return
        }
        guard let scrollView = scrollView else { return }
        if scrollView.insetTop + scrollView.contentH > scrollView.height { // 内容超过一个屏幕
            if scrollView.offsetY >= scrollView.contentH - scrollView.height + height * triggerAutomaticallyRefreshPercent + scrollView.insetBottom - height {
                guard let change = change else { return }
                // 防止手松开时连续调用
                let old = change[NSKeyValueChangeKey.oldKey] as? CGPoint
                let new = change[.newKey] as? CGPoint
                if new?.y ?? 0 <= old?.y ?? 0 { return }

                // 当底部刷新控件完全出现时，才刷新
                beginRefreshing()
            }
        }
    }

    open override func scrollViewPanStateDidChange(_ change: [NSKeyValueChangeKey: Any]?) {
        super.scrollViewPanStateDidChange(change)

        guard let scrollView = scrollView, state == .Idle else { return }
        let panState = scrollView.panGestureRecognizer.state
        switch panState {
        case .ended: // 手松开
            if scrollView.insetTop + scrollView.contentH <= scrollView.height { // 不够一个屏幕
                if scrollView.offsetY >= scrollView.insetTop { // 向上拽
                    beginRefreshing()
                }
            } else {
                if scrollView.offsetY >= scrollView.contentH + scrollView.insetBottom - scrollView.height {
                    beginRefreshing()
                }
            }
        case .began:
            oneNewPan = true
        default:
            break
        }
    }

    open override func beginRefreshing() {
        if !oneNewPan, onlyRefreshPerDrag {
            return
        }
        super.beginRefreshing()
        oneNewPan = false
    }
}
