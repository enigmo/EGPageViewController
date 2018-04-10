//
//  EGTabBarCell.swift
//
//  Created by Adam Henry on 2017/12/06.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

open class EGTabBarCell: UICollectionViewCell {
    open var option: EGPagingOption = EGPagingOption()
    let label = UILabel()
    let indicatorBar = UIView()
    var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        label.textAlignment = .center
        self.contentView.addSubview(label)
        label.font = option.font
        label.textColor = option.textColor
        let bottomMergin = option.textBottomMergin
        label.snp.makeConstraints { make in
            make.bottom.equalTo(-bottomMergin)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-10)
        }

        indicatorBar.backgroundColor = .black
        indicatorBar.isHidden = true
        self.contentView.addSubview(indicatorBar)
        indicatorBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(option.indicatorHeight)
        }
    }

    func setData(title: String, isCurrent: Bool, shouldHighlightText: Bool) {
        label.text = title
        label.textColor = shouldHighlightText ? option.textHighlightColor : option.textColor
        indicatorBar.isHidden = !isCurrent
    }

    func hideIndicator() {
        indicatorBar.isHidden = true
    }

    func showIndicator() {
        indicatorBar.isHidden = false
    }

    override open func prepareForReuse() {
        self.subviews.filter { $0 is UILabel }.forEach { view in
            guard let label = view as? UILabel else { return }
            label.text = ""
        }
        indicatorBar.isHidden = true
    }
}
