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
        didPerformAction: @escaping (AdaptyUI.Action) -> Void,
        didSelectProduct: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didFinishPurchase: @escaping (AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: ((AdaptyPaywallProduct) -> Void)? = nil,
        didStartRestore: (() -> Void)? = nil,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRenderingWith: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: @escaping (AdaptyError) -> Bool = { _ in true }
    ) -> some View {
        let paywallView = AdaptyPaywallView(
            paywall: paywall,
            products: products,
            configuration: configuration,
            didPerformAction: didPerformAction,
            didSelectProduct: didSelectProduct,
            didStartPurchase: didStartPurchase,
            didFinishPurchase: didFinishPurchase,
            didFailPurchase: didFailPurchase,
            didCancelPurchase: didCancelPurchase,
            didStartRestore: didStartRestore,
            didFinishRestore: didFinishRestore,
            didFailRestore: didFailRestore,
            didFailRenderingWith: didFailRenderingWith,
            didFailLoadingProducts: didFailLoadingProducts
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
    let tagResolver: AdaptyTagResolver?

    init(
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        configuration: AdaptyUI.LocalizedViewConfiguration,
        tagResolver: AdaptyTagResolver? = nil,
        didPerformAction: @escaping (AdaptyUI.Action) -> Void,
        didSelectProduct: ((AdaptyPaywallProduct) -> Void)?,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)?,
        didFinishPurchase: @escaping (AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?,
        didStartRestore: (() -> Void)?,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRenderingWith: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: @escaping (AdaptyError) -> Bool
    ) {
        self.paywall = paywall
        self.products = products
        self.configuration = configuration
        self.tagResolver = tagResolver

        delegate = .init(
            didPerformAction: didPerformAction,
            didSelectProduct: didSelectProduct,
            didStartPurchase: didStartPurchase,
            didFinishPurchase: didFinishPurchase,
            didFailPurchase: didFailPurchase,
            didCancelPurchase: didCancelPurchase,
            didStartRestore: didStartRestore,
            didFinishRestore: didFinishRestore,
            didFailRestore: didFailRestore,
            didFailRenderingWith: didFailRenderingWith,
            didFailLoadingProducts: didFailLoadingProducts
        )
    }

    func makeUIViewController(context: Context) -> UIViewController {
        AdaptyPaywallController(paywall: paywall,
                                products: products,
                                viewConfiguration: configuration,
                                delegate: delegate,
                                tagResolver: tagResolver)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

class AdaptyPaywallDelegate_SwiftUI: NSObject, AdaptyPaywallControllerDelegate {
    private let didPerformAction: (AdaptyUI.Action) -> Void

    private let didSelectProduct: ((AdaptyPaywallProduct) -> Void)?
    private let didStartPurchase: ((AdaptyPaywallProduct) -> Void)?
    private let didFinishPurchase: (AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void
    private let didFailPurchase: (AdaptyPaywallProduct, AdaptyError) -> Void
    private let didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?

    private let didStartRestore: (() -> Void)?
    private let didFinishRestore: (AdaptyProfile) -> Void
    private let didFailRestore: (AdaptyError) -> Void

    private let didFailRenderingWith: (AdaptyError) -> Void
    private let didFailLoadingProducts: (AdaptyError) -> Bool

    init(
        didPerformAction: @escaping (AdaptyUI.Action) -> Void,
        didSelectProduct: ((AdaptyPaywallProduct) -> Void)?,
        didStartPurchase: ((AdaptyPaywallProduct) -> Void)?,
        didFinishPurchase: @escaping (AdaptyPaywallProduct, AdaptyPurchasedInfo) -> Void,
        didFailPurchase: @escaping (AdaptyPaywallProduct, AdaptyError) -> Void,
        didCancelPurchase: ((AdaptyPaywallProduct) -> Void)?,
        didStartRestore: (() -> Void)?,
        didFinishRestore: @escaping (AdaptyProfile) -> Void,
        didFailRestore: @escaping (AdaptyError) -> Void,
        didFailRenderingWith: @escaping (AdaptyError) -> Void,
        didFailLoadingProducts: @escaping (AdaptyError) -> Bool
    ) {
        self.didPerformAction = didPerformAction
        self.didSelectProduct = didSelectProduct
        self.didStartPurchase = didStartPurchase
        self.didFinishPurchase = didFinishPurchase
        self.didFailPurchase = didFailPurchase
        self.didCancelPurchase = didCancelPurchase
        self.didStartRestore = didStartRestore
        self.didFinishRestore = didFinishRestore
        self.didFailRestore = didFailRestore
        self.didFailRenderingWith = didFailRenderingWith
        self.didFailLoadingProducts = didFailLoadingProducts
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

    func paywallControllerDidStartRestore(_ controller: AdaptyPaywallController) {
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
