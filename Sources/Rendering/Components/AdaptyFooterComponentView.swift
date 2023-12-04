//
//  AdaptyFooterComponentView.swift
//
//
//  Created by Alexey Goncharov on 11.7.23..
//

import Adapty
import UIKit

final class AdaptyFooterComponentView: UIStackView {
    let footerBlock: AdaptyUI.FooterBlock
    let tagConverter: AdaptyUI.Text.CustomTagConverter?
    let onTap: (AdaptyUI.ButtonAction?) -> Void

    init(footerBlock: AdaptyUI.FooterBlock,
         tagConverter: AdaptyUI.Text.CustomTagConverter?,
         onTap: @escaping (AdaptyUI.ButtonAction?) -> Void) throws {
        self.footerBlock = footerBlock
        self.tagConverter = tagConverter
        self.onTap = onTap

        super.init(frame: .zero)

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .fillEqually

        for (_, item) in footerBlock.orderedItems {
            guard case let .button(button) = item else { continue }

            let buttonView = AdaptyButtonComponentView(
                component: button,
                tagConverter: tagConverter,
                contentViewMargins: .footerButtonDefaultMargin,
                onTap: { [weak self] action in self?.onTap(action) }
            )
            addArrangedSubview(buttonView)
        }
    }
}
