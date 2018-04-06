//
//  EGPageViewController.swift
//
//  Created by Adam Henry on 2017/12/05.
//

import UIKit
import SnapKit

public class EGPageViewController: UIPageViewController {
    open var option: EGPagingOption = EGPagingOption()
    open var tabItems: [(viewController: UIViewController, title: String)] = []

    var infiniteTabView: EGInfiniteTabView?

    var beginPoint: CGFloat = 0.0
    var shouldScrollBar: Bool = true
    var beforeIndex: Int = 0

    var defaultIndex: Int = 0
    var currentIndex: Int? {
        guard let viewController = viewControllers?.first else {
            return nil
        }
        return tabItems.map { $0.viewController }.index(of: viewController)
    }

    convenience init(option: EGPagingOption) {
        self.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.option = option
        self.infiniteTabView = EGInfiniteTabView(option: option)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.layoutMargins = UIEdgeInsets(top: option.tabHeight, left: 0, bottom: 0, right: 0)

        let scrollView = view.subviews.compactMap { $0 as? UIScrollView }.first
        scrollView?.delegate = self
        dataSource = self
        delegate = self

        setViewControllers([tabItems[defaultIndex].viewController], direction: .forward, animated: false, completion: nil)
        if let infiniteTabView = self.infiniteTabView {
            self.view.addSubview(infiniteTabView)
            infiniteTabView.tabs = tabItems.compactMap({ $0.title })
            infiniteTabView.option = option
            infiniteTabView.snp.makeConstraints { make in
                make.height.equalTo(option.tabHeight)
                make.top.left.right.equalToSuperview()
            }
            infiniteTabView.onPageItemPressed = { [weak self] index in
                guard let weakSelf = self, let currentIndex = weakSelf.currentIndex else { return }
                weakSelf.shouldScrollBar = false
                infiniteTabView.indicatorView.isHidden = true
                if index != weakSelf.currentIndex {
                    var direction: UIPageViewControllerNavigationDirection = .forward
                    if currentIndex == weakSelf.tabItems.count - 1 && index == 0 {
                        direction = .forward
                    } else if index == weakSelf.tabItems.count - 1 && currentIndex == 0 {
                        direction = .reverse
                    } else if currentIndex < index {
                        direction = .forward
                    } else {
                        direction = .reverse
                    }
                    weakSelf.setViewControllers([weakSelf.tabItems[index].viewController], direction: direction, animated: true, completion: { _ in
                        guard let collectionView = infiniteTabView.collectionView else { return }
                        infiniteTabView.updateCollectionViewUserInteractionEnabled(true)
                        infiniteTabView.collectionViewContentOffsetX = collectionView.contentOffset.x
                        infiniteTabView.indicatorView.isHidden = false
                    })
                } else {
                    infiniteTabView.updateCollectionViewUserInteractionEnabled(true)
                }
            }
            infiniteTabView.onScrollInitiate = { [weak self] in
                guard let weakSelf = self else { return }
                for view in weakSelf.view.subviews {
                    if view.isKind(of: UIScrollView.self) {
                        view.isUserInteractionEnabled = false
                    }
                }
            }
            infiniteTabView.onScrollRelease = { [weak self] in
                guard let weakSelf = self else { return }
                for view in weakSelf.view.subviews {
                    if view.isKind(of: UIScrollView.self) {
                        view.isUserInteractionEnabled = true
                    }
                }
            }
            infiniteTabView.collectionViewContentOffsetX = infiniteTabView.collectionView?.contentOffset.x ?? 0
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let currentIndex = currentIndex {
            infiniteTabView?.updateCurrentIndex(index: currentIndex)
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let currentIndex = currentIndex {
            infiniteTabView?.updateCurrentIndex(index: currentIndex)
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let scrollView = view.subviews.compactMap ({ $0 as? UIScrollView }).first else { return }
        scrollView.frame = CGRect(x: scrollView.frame.origin.x,
                                  y: option.tabHeight,
                                  width: scrollView.frame.width,
                                  height: scrollView.frame.height)
    }

    func goToIndex(index: Int) {
        if self.tabItems.count <= index { return }
        self.setViewControllers([self.tabItems[index].viewController], direction: .forward, animated: false, completion: { [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.infiniteTabView?.updateCurrentIndex(index: index)
        })
    }
}

extension EGPageViewController: UIScrollViewDelegate {
    fileprivate var defaultContentOffsetX: CGFloat {
        return self.view.bounds.width
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldScrollBar else { return }

        infiniteTabView?.updateScrollOffset(index: currentIndex ?? 0, contentOffsetX: scrollView.contentOffset.x - view.frame.width)
    }
}

// MARK: - UIPageViewControllerDataSource

extension EGPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController: viewController, isAfter: false)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nextViewController(viewController: viewController, isAfter: true)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        shouldScrollBar = true
        infiniteTabView?.updateCollectionViewUserInteractionEnabled(false)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentIndex = currentIndex, let infiniteTabView = self.infiniteTabView, currentIndex < infiniteTabView.tabs.count, completed {
            infiniteTabView.updateCurrentIndex(index: currentIndex)
            beforeIndex = currentIndex
        }
        infiniteTabView?.updateCollectionViewUserInteractionEnabled(true)
    }

    private func nextViewController(viewController: UIViewController, isAfter: Bool) -> UIViewController? {
        guard var index = tabItems.map({ $0.viewController }).index(of: viewController) else { return nil }

        index = isAfter ? index + 1 : index - 1

        if index < 0 {
            index = tabItems.count - 1
        } else if index == tabItems.count {
            index = 0
        }

        if index >= 0 && index < tabItems.count {
            return tabItems[index].viewController
        }

        return nil
    }
}
