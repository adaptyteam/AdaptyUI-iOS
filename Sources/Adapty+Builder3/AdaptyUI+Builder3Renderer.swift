//
//  File.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI
import UIKit

public class AdaptyBuilder3PaywallController: UIViewController {
    fileprivate let logId: String

    public let id = UUID()
    private let viewConfiguration: AdaptyUI.LocalizedViewConfiguration

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate,
        tagResolver: AdaptyTagResolver?
    ) {
        let logId = AdaptyUI.generateLogId()

        AdaptyUI.writeLog(level: .verbose, message: "#\(logId)# init template: \(viewConfiguration.templateId), products: \(products?.count ?? 0)")

        self.logId = logId
        self.viewConfiguration = viewConfiguration

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let screen = viewConfiguration.screens.first?.value {
            view.backgroundColor = screen.background.asColor?.uiColor ?? .white

            if let mainBlock = screen.mainBlock {
                addSubSwiftUIView(AdaptyUIElementView(mainBlock),
                                  to: view)
            } else {
                addSubSwiftUIView(Text("No main block found"),
                                  to: view)
            }
        } else {
            view.backgroundColor = .white // TODO: remove

            addSubSwiftUIView(Text("Rendering Failed!"),
                              to: view)
        }
    }

    deinit {
        log(.verbose, "deinit")
    }
}

extension AdaptyBuilder3PaywallController {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}
