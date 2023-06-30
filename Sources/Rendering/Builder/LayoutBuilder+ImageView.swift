//
//  File.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit

extension LayoutBuilder {
    func layoutCoverImageView(
        _ imageView: UIImageView,
        on superview: UIView,
        multiplier: CGFloat,
        minHeight: CGFloat
    ) {
        superview.addSubview(imageView)

        let hConstraintMult = imageView.heightAnchor.constraint(equalTo: superview.heightAnchor,
                                                                multiplier: multiplier)
        hConstraintMult.priority = .init(999.0)
        let hConstraintFix = imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        hConstraintFix.priority = .init(1000.0)

        superview.addConstraints([
            imageView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0.0),
            imageView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0.0),
            imageView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0.0),

            hConstraintMult,
            hConstraintFix,
        ])
    }

    func layoutBackgroundImageView(
        _ imageView: UIImageView,
        on superview: UIView
    ) {
        superview.addSubview(imageView)

        superview.addConstraints([
            imageView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0.0),
            imageView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0.0),
            imageView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0.0),
            imageView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0.0),
        ])
    }
}
