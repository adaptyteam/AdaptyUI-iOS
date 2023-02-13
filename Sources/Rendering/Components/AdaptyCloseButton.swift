//
//  AdaptyCloseButton.swift
//
//
//  Created by Alexey Goncharov on 2023-01-18.
//

import Adapty
import UIKit

class AdaptyCloseButton: UIView {
    private let onTap: () -> Void

    init(onTap: @escaping () -> Void) {
        self.onTap = onTap

        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addConstraints([
            widthAnchor.constraint(equalToConstant: 32.0),
            heightAnchor.constraint(equalToConstant: 32.0),
        ])

        backgroundColor = UIColor(red: 232.0 / 255.0,
                                  green: 234.0 / 255.0,
                                  blue: 238.0 / 255.0,
                                  alpha: 0.5)
        layer.masksToBounds = true
        layer.cornerRadius = 16.0
        layer.borderColor = UIColor(red: 17.0 / 255.0,
                                    green: 17.0 / 255.0,
                                    blue: 17.0 / 255.0,
                                    alpha: 0.1).cgColor
        layer.borderWidth = 1.0

        let crossImageView = UIImageView(image: UIImage(systemName: "xmark"))
        crossImageView.translatesAutoresizingMaskIntoConstraints = false
        crossImageView.tintColor = .black

        addSubview(crossImageView)
        addConstraints([
            crossImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            crossImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        crossImageView.addConstraints([
            crossImageView.widthAnchor.constraint(equalToConstant: 16.0),
            crossImageView.heightAnchor.constraint(equalToConstant: 18.0),
        ])

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear

        addSubview(button)
        addConstraints([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        button.addTarget(self, action: #selector(buttonDidTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonDidTouchUp), for: .touchUpOutside)
        button.addTarget(self, action: #selector(buttonDidTouchUp), for: .touchUpInside)
    }

    @objc
    private func buttonDidTouchDown() {
        alpha = 0.7
    }

    @objc
    private func buttonDidTouchUp() {
        alpha = 1.0
        onTap()
    }
}
