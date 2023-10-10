//
//  AdaptyPaywallControllerDelegate.swift
//
//
//  Created by Alexey Goncharov on 27.1.23..
//

import Adapty
import UIKit

extension AdaptyUI {
    // This enum describes user initiated actions.
    public enum Action {
        // User pressed Close Button
        case close
        // User pressed any button with URL
        case openURL(url: URL)
        // User pressed any button with custom action (e.g. login)
        case custom(id: String)
    }
}

/// Implement this protocol to respond to different events happening inside the purchase screen.
public protocol AdaptyPaywallControllerDelegate: NSObject {
    /// If user performs an action process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - action: an ``AdaptyUI.Action`` value.
    func paywallController(_ controller: AdaptyPaywallController,
                           didPerform action: AdaptyUI.Action)

    /// If product was selected for purchase (by user or by system), this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` which was selected.
    func paywallController(_ controller: AdaptyPaywallController,
                           didSelectProduct product: AdaptyPaywallProduct)

    /// If user initiates the purchase process, this method will be invoked.
    ///
    /// - Parameters:
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` of the purchase.
    func paywallController(_ controller: AdaptyPaywallController,
                           didStartPurchase product: AdaptyPaywallProduct)

    /// This method is invoked when a successful purchase is made.
    ///
    /// The default implementation is simply dismissing the controller:
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - purchasedInfo: an ``AdaptyPurchasedInfo`` object containing up to date information about successful purchase.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishPurchase product: AdaptyPaywallProduct,
                           purchasedInfo: AdaptyPurchasedInfo)

    /// This method is invoked when the purchase process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - product: an ``AdaptyPaywallProduct`` of the purchase.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailPurchase product: AdaptyPaywallProduct,
                           error: AdaptyError)

    /// This method is invoked when user cancel the purchase manually.
    /// - Parameters
    ///     - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///     - product: an ``AdaptyPaywallProduct`` of the purchase.
    func paywallController(_ controller: AdaptyPaywallController,
                           didCancelPurchase product: AdaptyPaywallProduct)

    /// This method is invoked when a successful restore is made.
    ///
    /// Check if the ``AdaptyProfile`` object contains the desired access level, and if so, the controller can be dismissed.
    /// ```
    /// controller.dismiss(animated: true)
    /// ```
    ///
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - profile: an ``AdaptyProfile`` object containing up to date information about the user.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishRestoreWith profile: AdaptyProfile)

    /// This method is invoked when the restore process fails.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailRestoreWith error: AdaptyError)

    /// This method will be invoked in case of errors during the screen rendering process.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailRenderingWith error: AdaptyError)

    /// This method is invoked in case of errors during the products loading process.
    /// - Parameters:
    ///   - controller: an ``AdaptyPaywallController`` within which the event occurred.
    ///   - error: an ``AdaptyError`` object representing the error.
    /// - Returns: Return `true`, if you want to retry products fetching.
    func paywallController(_ controller: AdaptyPaywallController,
                           didFailLoadingProductsWith error: AdaptyError) -> Bool
}

extension AdaptyUI {
    public static let SDKVersion = "2.0.2"

    /// If you are using the [Paywall Builder](https://docs.adapty.io/docs/paywall-builder-getting-started), you can use this method to get a configuration object for your paywall.
    ///
    /// - Parameters:
    ///   - forPaywall: the ``AdaptyPaywall`` for which you want to get a configuration.
    ///   - completion: A result containing the ``AdaptyUI.ViewConfiguration>`` object. Use it with [AdaptyUI](https://github.com/adaptyteam/AdaptySDK-iOS-VisualPaywalls.git) library.
    public static func getViewConfiguration(
        forPaywall paywall: AdaptyPaywall,
        locale: String,
        _ completion: @escaping AdaptyResultCompletion<AdaptyUI.LocalizedViewConfiguration>
    ) {
        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: [
                "paywall_id": paywall.id,
                "paywall_variation_id": paywall.variationId,
                "locale": locale,
                "builder_version": AdaptyUI.SDKVersion,
            ])
        } catch {
            let encodingError = AdaptyUIError.encoding(error)
            completion(.failure(AdaptyError(encodingError)))
            return
        }

        AdaptyUI.getViewConfiguration(data: data) { result in
            completion(result.map { $0.extractLocale(locale) })
        }
    }

    /// Right after receiving ``AdaptyUI.ViewConfiguration``, you can create the corresponding ``AdaptyPaywallController`` to present it afterwards.
    ///
    /// - Parameters:
    ///   - paywall: an ``AdaptyPaywall`` object, for which you are trying to get a controller.
    ///   - products: optional ``AdaptyPaywallProducts`` array. Pass this value in order to optimize the display time of the products on the screen. If you pass `nil`, ``AdaptyUI`` will automatically fetch the required products.
    ///   - viewConfiguration: an ``AdaptyUI.LocalizedViewConfiguration`` object containing information about the visual part of the paywall. To load it, use the ``AdaptyUI.getViewConfiguration(paywall:locale:)`` method.
    ///   - delegate: the object that implements the ``AdaptyPaywallControllerDelegate`` protocol. Use it to respond to different events happening inside the purchase screen.
    /// - Returns: an ``AdaptyPaywallController`` object, representing the requested paywall screen.
    public static func paywallController(
        for paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]? = nil,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration,
        delegate: AdaptyPaywallControllerDelegate
    ) -> AdaptyPaywallController {
        AdaptyPaywallController(
            paywall: paywall,
            products: products,
            viewConfiguration: viewConfiguration,
            delegate: delegate
        )
    }
}
