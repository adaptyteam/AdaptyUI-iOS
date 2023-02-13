//
//  AdaptyTextRowsComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

class AdaptyTextRowsComponent: UIStackView {
    private let textRows: AdaptyUI.TextRows
    private let imageColor: UIColor

    init(textRows: AdaptyUI.TextRows, imageColor: UIColor) {
        self.textRows = textRows
        self.imageColor = imageColor

        super.init(frame: .zero)

        axis = .vertical
        alignment = .leading
        spacing = 8.0
        translatesAutoresizingMaskIntoConstraints = false

        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var items: [AdaptyTextRowComponent]!

    private func setupView() {
        var items = [AdaptyTextRowComponent]()

        for i in 0 ..< textRows.rows.count {
            let item = AdaptyTextRowComponent(textRows: textRows, index: i, imageColor: imageColor)
            addArrangedSubview(item)
            items.append(item)
        }

        self.items = items
    }
}
