//
//  EGTabBarCell.swift
//
//  Created by Adam Henry on 2017/12/06.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class EGTabBarCell: UICollectionViewCell {
    open var option: EGPagingOption = EGPagingOption()
    let label = UILabel()
    let indicatorBar = UIView()
    let unreadImageView = UIImageView()
    var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
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

        unreadImageView.isHidden = true
        unreadImageView.layer.cornerRadius = 2.5
        unreadImageView.clipsToBounds = true
        unreadImageView.image = UIImage(color: UIColor(61, green: 194, blue: 175), rect: CGRect(x: 0, y: 0, width: 5, height: 5))
        self.contentView.addSubview(unreadImageView)
        unreadImageView.snp.makeConstraints { [weak self] make in
            guard let weakSelf = self else { return }
            make.left.equalTo(weakSelf.label.snp.right).offset(3)
            make.bottom.equalTo(weakSelf.label.snp.top).offset(2)
            make.width.height.equalTo(5)
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

    override func prepareForReuse() {
        self.subviews.filter { $0 is UILabel }.forEach { view in
            guard let label = view as? UILabel else { return }
            label.text = ""
        }
        indicatorBar.isHidden = true
        unreadImageView.isHidden = true
    }
}
