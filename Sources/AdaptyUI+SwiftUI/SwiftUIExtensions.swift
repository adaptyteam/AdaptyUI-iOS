//
//  File.swift
//
//
//  Created by Alexey Goncharov on 30.11.23..
//

import Adapty
import SwiftUI

extension View {
    @ViewBuilder
    public func paywall(
        isPresented: Binding<Bool>,
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]? = nil,
        configuration: AdaptyUI.LocalizedViewConfiguration,
        fullScreen: Bool = true,
        didPerformAction: @escaping (AdaptyUI.Action) -> Void
    ) -> some View {
        let paywallView = AdaptyPaywallView(
            paywall: paywall,
            products: products,
            configuration: configuration,
            didPerformAction: didPerformAction
        )

        if fullScreen, #available(iOS 14.0, *) {
            fullScreenCover(
                isPresented: isPresented,
                content: {
                    paywallView
                        .ignoresSafeArea()
                }
            )
        } else {
            sheet(
                isPresented: isPresented,
                content: {
                    paywallView
                }
            )
        }
    }
}

struct AdaptyPaywallView: UIViewControllerRepresentable {
    let paywall: AdaptyPaywall
    let products: [AdaptyPaywallProduct]?
    let configuration: AdaptyUI.LocalizedViewConfiguration

    let delegate: AdaptyPaywallDelegate_SwiftUI

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        configuration: AdaptyUI.LocalizedViewConfiguration,
        didPerformAction: @escaping (AdaptyUI.Action) -> Void
    ) {
        self.paywall = paywall
        self.products = products
        self.configuration = configuration

        delegate = .init(didPerformAction: didPerformAction)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        AdaptyPaywallController(paywall: paywall,
                                products: products,
                                viewConfiguration: configuration,
                                delegate: delegate)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

class AdaptyPaywallDelegate_SwiftUI: NSObject, AdaptyPaywallControllerDelegate {
    let didPerformAction: (AdaptyUI.Action) -> Void

    init(didPerformAction: @escaping (AdaptyUI.Action) -> Void) {
        self.didPerformAction = didPerformAction
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didPerform action: AdaptyUI.Action) {
        didPerformAction(action)
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didSelectProduct product: AdaptyPaywallProduct) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didStartPurchase product: AdaptyPaywallProduct) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishPurchase product: AdaptyPaywallProduct,
                           purchasedInfo: AdaptyPurchasedInfo) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didFailPurchase product: AdaptyPaywallProduct,
                           error: AdaptyError) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didCancelPurchase product: AdaptyPaywallProduct) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didFinishRestoreWith profile: AdaptyProfile) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didFailRestoreWith error: AdaptyError) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didFailRenderingWith error: AdaptyError) {
    }

    func paywallController(_ controller: AdaptyPaywallController,
                           didFailLoadingProductsWith error: AdaptyError) -> Bool {
        false
    }
}
