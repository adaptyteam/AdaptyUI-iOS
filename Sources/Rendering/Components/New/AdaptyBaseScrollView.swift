//
//  AdaptyBaseScrollView.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import UIKit

final class AdaptyBaseScrollView: UIScrollView {
    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        contentInsetAdjustmentBehavior = .never
        delegate = delegate
        alwaysBounceVertical = true
        delaysContentTouches = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AdaptyInterfaceBilder {
    static func layoutScrollView(
        _ scrollView: AdaptyBaseScrollView,
        on superview: UIView
    ) {
        superview.addSubview(scrollView)
        superview.addConstraints([
            scrollView.topAnchor.constraint(equalTo: superview.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])
    }
}
