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

    init(footerBlock: AdaptyUI.FooterBlock) throws {
        self.footerBlock = footerBlock

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
        
        for (_, item) in footerBlock.items {
            guard case let .button(button) = item else {
                return
            }

            let buttonView = AdaptyButtonComponentView(component: button)
            addArrangedSubview(buttonView)
        }
    }
}
