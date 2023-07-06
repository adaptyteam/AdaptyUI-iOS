//
//  AdaptyServiceButtonsComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

class AdaptyServiceButtonsComponent: UIStackView {
    private let termsText: AdaptyUI.Text
    private let privacyText: AdaptyUI.Text
    private let restoreText: AdaptyUI.Text

    private let onTerms: (() -> Void)?
    private let onPrivacy: (() -> Void)?
    private let onRestore: (() -> Void)?

    init(termsText: AdaptyUI.Text,
         privacyText: AdaptyUI.Text,
         restoreText: AdaptyUI.Text,
         onTerms: @escaping () -> Void,
         onPrivacy: @escaping () -> Void,
         onRestore: @escaping () -> Void) {
        self.termsText = termsText
        self.privacyText = privacyText
        self.restoreText = restoreText
        self.onTerms = onTerms
        self.onPrivacy = onPrivacy
        self.onRestore = onRestore

        super.init(frame: .zero)

        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var buttons: [UIButton]!

    private func buildServiceButton(text: AdaptyUI.Text) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(text.value, for: .normal)
        button.setTitleColor(text.fill?.asColor?.uiColor, for: .normal)
        button.titleLabel?.font = text.uiFont
        return button
    }

    private func setupView() {
        axis = .horizontal
        distribution = .fillEqually

        let termsButton = buildServiceButton(text: termsText)
        let privacyButton = buildServiceButton(text: privacyText)
        let restoreButton = buildServiceButton(text: restoreText)

        addArrangedSubview(termsButton)
        addArrangedSubview(privacyButton)
        addArrangedSubview(restoreButton)

        termsButton.addTarget(self, action: #selector(termsPressed), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(privacyPressed), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restorePressed), for: .touchUpInside)
    }

    @objc
    private func termsPressed() {
        onTerms?()
    }

    @objc
    private func privacyPressed() {
        onPrivacy?()
    }

    @objc
    private func restorePressed() {
        onRestore?()
    }
}
