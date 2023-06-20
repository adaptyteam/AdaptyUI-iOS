//
//  AdaptyUI+DefaultConfiguration.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

import Adapty
import UIKit

extension UIAlertController {
    static func buildRestoredAlert(onDialogDismissed: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: "Successfully restored purchases!",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            onDialogDismissed?()
        }))
        return alert
    }

    static func buildErrorAlert(_ error: AdaptyError, onDialogDismissed: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: "Error Occured",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            onDialogDismissed?()
        }))
        return alert
    }
}

extension AdaptyPaywallControllerDelegate {
    public func paywallControllerDidPressCloseButton(_ controller: AdaptyPaywallController) {
        controller.dismiss(animated: true)
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didSelectProduct product: AdaptyPaywallProduct) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didStartPurchase product: AdaptyPaywallProduct) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFinishPurchase product: AdaptyPaywallProduct,
                                  profile: AdaptyProfile) {
        controller.dismiss(animated: true)
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailRenderingWith error: Error) {
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  didFailLoadingProductsWith error: AdaptyError) -> Bool {
        false
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  openURL url: URL) {
        UIApplication.shared.open(url, options: [:])
    }

    public func paywallController(_ controller: AdaptyPaywallController,
                                  buildDialogWith event: AdaptyUI.Event,
                                  onDialogDismissed: (() -> Void)?) -> UIViewController {
        switch event {
        case .restored:
            return UIAlertController.buildRestoredAlert(onDialogDismissed: onDialogDismissed)
        case let .error(error):
            return UIAlertController.buildErrorAlert(error, onDialogDismissed: onDialogDismissed)
        }
    }
}
