//
//  AdaptyTextItemsComponentView.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

class AdaptyTextItemsComponentView: UIStackView {
    private let textItems: AdaptyUI.TextItems

    init(textItems: AdaptyUI.TextItems) {
        self.textItems = textItems

        super.init(frame: .zero)

        axis = .vertical
        alignment = .fill
        spacing = 8.0
        translatesAutoresizingMaskIntoConstraints = false

        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var items: [AdaptyTextItemView]!

    private func setupView() {
        var items = [AdaptyTextItemView]()

        for i in 0 ..< textItems.items.count {
            let item = AdaptyTextItemView(text: textItems.items[i])
            addArrangedSubview(item)
            items.append(item)
        }

        self.items = items
    }
}
