//
//  EGInfiniteTabView.swift
//
//  Created by Adam Henry on 2017/12/06.
//

import UIKit
import SnapKit

class EGInfiniteTabView: UIView {
    open var option: EGPagingOption = EGPagingOption()
    let indicatorView = UIView()
    let bottomLineView = UIView(frame: CGRect.zero)

    var collectionView: UICollectionView?
    var pageTabItemsWidth: CGFloat = 0.0
    var collectionViewContentOffsetX: CGFloat = 0.0
    var currentlySelectedTab: Int = 0
    var beforeIndex: Int = 0
    var shouldUpdate: Bool = false

    private var _tabs: [String] = []
    var tabs: [String] {
        set {
            _tabs = newValue
            guard let collectionView = collectionView else { return }
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
        get { return _tabs }
    }

    var onPageItemPressed: ((_ index: Int) -> Void)?
    var onScrollInitiate: (() -> Void)?
    var onScrollRelease: (() -> Void)?

    convenience init(option: EGPagingOption) {
        self.init()
        self.option = option
        commonInit()
    }

    func commonInit() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: self.frame, collectionViewLayout: collectionViewLayout)
        if let collectionView = self.collectionView {
            collectionView.register(EGTabBarCell.self, forCellWithReuseIdentifier: "EGTabBarCell")
            collectionView.backgroundColor = option.tabBackgroundColor
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.dataSource = self
            collectionView.delegate = self
            self.addSubview(collectionView)
            collectionView.snp.makeConstraints({ make in
                make.top.bottom.left.right.equalToSuperview()
            })

            bottomLineView.backgroundColor = option.bottomLineColor
            bottomLineView.alpha = 0.0
            self.addSubview(bottomLineView)
            bottomLineView.snp.makeConstraints({ make in
                make.width.equalToSuperview()
                make.height.equalTo(option.bottomLineHeight)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
            })

            indicatorView.backgroundColor = option.indicatorColor
            self.addSubview(indicatorView)
            indicatorView.snp.makeConstraints({ make in
                make.width.equalTo(option.tabWidth)
                make.height.equalTo(option.indicatorHeight)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
            })
        }
    }

    func updateScrollOffset(index: Int, contentOffsetX: CGFloat) {
        shouldUpdate = false
        if let collectionView = self.collectionView {
            DispatchQueue.main.async {
                self.indicatorView.isHidden = false
                collectionView
                    .visibleCells
                    .flatMap { $0 as? EGTabBarCell }
                    .forEach {
                        $0.hideIndicator()
                }
            }
        }
        let distance: CGFloat = option.tabWidth
        let scrollRate = contentOffsetX / UIScreen.main.bounds.width
        let scroll = scrollRate * distance
        if let collectionView = self.collectionView {
            collectionView.setContentOffset(collectionView.contentOffset, animated: false)
            collectionView.contentOffset.x = collectionViewContentOffsetX + scroll
        }
    }

    func updateCurrentIndex(index: Int) {
        currentlySelectedTab = index
        let indexPath = IndexPath(row: index + tabs.count, section: 0)
        self.moveScrollBar(indexPath: indexPath)
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionViewContentOffsetX = collectionView?.contentOffset.x ?? 0
    }

    func updateCollectionViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
        collectionView?.isUserInteractionEnabled = userInteractionEnabled
    }

    func moveScrollBar(indexPath: IndexPath) {
        self.collectionView?.reloadData()
        beforeIndex = indexPath.row
    }
}

 // MARK: UICollectionViewDataSource
extension EGInfiniteTabView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "EGTabBarCell", for: indexPath) as? EGTabBarCell)!
        cell.option = self.option
        cell.setData(title: tabs[indexPath.row % tabs.count],
                      isCurrent: (indexPath.row % tabs.count == currentlySelectedTab && shouldUpdate),
                      shouldHighlightText: indexPath.row % tabs.count == currentlySelectedTab)
        if tabs[indexPath.row % tabs.count] == BMPageViewController.newsTabTitle {
            cell.unreadImageView.isHidden = !BMNewsManager.sharedManager.isExistUnreadNews.value
        }
        layoutIfNeeded()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabs.count * 3 //page tab count * 3
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        shouldUpdate = true
        updateCollectionViewUserInteractionEnabled(false)
        let adjustedIndex = indexPath.row % tabs.count
        self.onPageItemPressed?(adjustedIndex)
        currentlySelectedTab = adjustedIndex
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.moveScrollBar(indexPath: indexPath)
    }
}

extension EGInfiniteTabView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            shouldUpdate = true
            indicatorView.isHidden = true
            if let collectionView = collectionView,
                let cell = collectionView.cellForItem(at: IndexPath(row: beforeIndex, section: 0)) as? EGTabBarCell {
                cell.showIndicator()
            }
        }
        if scrollView.isTracking {
            self.onScrollInitiate?()
        }

        if pageTabItemsWidth == 0.0 {
            pageTabItemsWidth = floor(scrollView.contentSize.width / 3.0) // 表示したい要素群のwidthを計算
        }

        if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > pageTabItemsWidth * 2.0) { // スクロールした位置がしきい値を超えたら中央に戻す
            scrollView.contentOffset.x = pageTabItemsWidth
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.onScrollRelease?()
    }
}

extension EGInfiniteTabView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: option.tabWidth, height: option.tabHeight)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
