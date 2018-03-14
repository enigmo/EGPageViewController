//
//  EGPagingOption.swift
//
//  Created by Adam Henry on 2017/12/12.
//

import UIKit

public struct EGPagingOption {
    public init() {}

    //Tab
    public let tabWidth = UIScreen.main.bounds.width / 4

    private let fontSize: CGFloat = 11
    private let searchBarBottomMargin: CGFloat = 7
    public var textBottomMergin: CGFloat = 13.5

    public var font: UIFont {
        return UIFont(name: "HiraginoSans-W6", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
    }
    public var tabHeight: CGFloat { return (textBottomMergin - searchBarBottomMargin) + fontSize + textBottomMergin }
    public var tabBackgroundColor: UIColor = .white
    public var textHighlightColor: UIColor = UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    public var textColor: UIColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)

    //Indicator
    public var indicatorHeight: CGFloat = 1.0
    public var indicatorColor: UIColor = .black

    //Page
    public var pageBackgoundColor: UIColor = .white

    //Bottom Line
    public var showsBottomLine: Bool = false
    public var bottomLineHeight: Float = 0.5
    public var bottomLineColor: UIColor = UIColor(red:217.0/255.0, green:217.0/255.0, blue:217.0/255.0, alpha: 1.0)
}
