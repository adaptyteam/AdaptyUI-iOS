//
//  AdaptyTemplateController.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit

public final class AdaptyTemplateController: UIViewController {
    private let layoutBuilder: LayoutBuilder

    init(layoutBuilder: LayoutBuilder) {
        self.layoutBuilder = layoutBuilder

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        layoutBuilder.buildInterface(on: view)
        layoutBuilder.onCloseButtonPressed { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutBuilder.viewDidLayoutSubviews(view)
    }
}
