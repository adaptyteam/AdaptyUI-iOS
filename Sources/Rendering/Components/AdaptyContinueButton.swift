//
//  AdaptyContinueButton.swift
//
//
//  Created by Alexey Goncharov on 2023-01-18.
//

import Adapty
import UIKit

class AdaptyContinueButton: UIButton {
    private let text: AdaptyUI.Text
    private let color: AdaptyUI.Color
    private let onTap: () -> Void

    init(text: AdaptyUI.Text, color: AdaptyUI.Color, onTap: @escaping () -> Void) {
        self.text = text
        self.color = color
        self.onTap = onTap

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        setupView()
        setupConstraints()
        setupActions()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var progressView: UIActivityIndicatorView!

    private func setupView() {
        backgroundColor = color.uiColor
        layer.masksToBounds = true
        layer.cornerRadius = 8.0

        let attr = NSMutableAttributedString(string: text.value ?? "")
        attr.addAttributes([
            NSAttributedString.Key.kern: 2.16,
        ], range: NSRange(location: 0, length: attr.length))

        setAttributedTitle(attr, for: .normal)
        setAttributedTitle(NSAttributedString(string: ""), for: .disabled)

        if let color = text.color?.uiColor {
            setTitleColor(color, for: .normal)
        }

        if let font = text.font?.uiFont() {
            titleLabel?.font = font
        }

        let progressView = UIActivityIndicatorView(style: .medium)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.color = text.color?.uiColor ?? .white
        progressView.isHidden = true
        addSubview(progressView)

        self.progressView = progressView
    }

    private func setupConstraints() {
        addConstraints([
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightAnchor.constraint(equalToConstant: 64.0),
        ])
    }

    private func setupActions() {
        addTarget(self, action: #selector(buttonDidTouchUp), for: .touchUpInside)
    }

    func updateInProgress(_ inProgress: Bool) {
        progressView.isHidden = !inProgress
        isEnabled = !inProgress

        if inProgress {
            progressView.startAnimating()
        } else {
            progressView.stopAnimating()
        }
    }

    @objc
    private func buttonDidTouchUp() {
        onTap()
    }
}
