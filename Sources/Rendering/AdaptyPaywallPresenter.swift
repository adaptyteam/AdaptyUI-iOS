//
//  AdaptyPaywallPresenter.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Combine
import Foundation

extension Array where Element == AdaptyPaywallProduct {
    var hasUnknownEligibiity: Bool {
        contains(where: { $0.introductoryDiscount != nil && $0.introductoryOfferEligibility == .unknown })
    }
}

protocol AdaptyPaywallPresenterDelegate: NSObject {
    func didFailLoadingProducts(with policy: AdaptyProductsFetchPolicy,
                                error: AdaptyError) -> Bool
}

class AdaptyPaywallPresenter {
    fileprivate let logId: String
    private let queue = DispatchQueue(label: "AdaptyUI.SDK.PaywallPresenterQueue")

    let paywall: AdaptyPaywall

    weak var delegate: AdaptyPaywallPresenterDelegate?

    @Published var viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    @Published var products: [AdaptyPaywallProduct]?
    @Published var selectedProduct: AdaptyPaywallProduct?
    @Published var productsFetchingInProgress: Bool = false
    @Published var purchaseInProgress: Bool = false
    @Published var restoreInProgress: Bool = false

    private var cancellable = Set<AnyCancellable>()

    var onPurchase: ((AdaptyResult<AdaptyProfile>) -> Void)?
    var onRestore: ((AdaptyResult<AdaptyProfile>) -> Void)?

    public init(
        logId: String,
        paywall: AdaptyPaywall,
        products: [AdaptyPaywallProduct]?,
        viewConfiguration: AdaptyUI.LocalizedViewConfiguration
    ) {
        self.logId = logId
        self.paywall = paywall
        self.products = products
        self.viewConfiguration = viewConfiguration

        selectedProduct = products?.first
    }

    func selectProduct(id: String) {
        log(.verbose, "select product: \(id)")
        selectedProduct = products?.first(where: { $0.vendorProductId == id })
    }

    func logShowPaywall() {
        log(.verbose, "logShowPaywall begin")

        AdaptyUI.logShowPaywall(paywall,
                                viewConfiguration: viewConfiguration) { [weak self] error in
            if let error = error {
                self?.log(.error, "logShowPaywall fail: \(error)")
            } else {
                self?.log(.verbose, "logShowPaywall success")
            }
        }
    }

    func makePurchase() {
        guard let selectedProduct = selectedProduct else { return }

        log(.verbose, "makePurchase begin")

        purchaseInProgress = true
        Adapty.makePurchase(product: selectedProduct) { [weak self] result in
            self?.onPurchase?(result)
            self?.purchaseInProgress = false

            switch result {
            case .success:
                self?.log(.verbose, "makePurchase success")
            case let .failure(error):
                self?.log(.error, "makePurchase fail: \(error)")
            }
        }
    }

    func restorePurchases() {
        log(.verbose, "restorePurchases begin")

        restoreInProgress = true
        Adapty.restorePurchases { [weak self] result in
            self?.onRestore?(result)
            self?.restoreInProgress = false

            switch result {
            case .success:
                self?.log(.verbose, "restorePurchases success")
            case let .failure(error):
                self?.log(.error, "restorePurchases fail: \(error)")
            }
        }
    }

    // MARK: - Products Fetching

    func loadProductsIfNeeded() {
        guard !productsLoadingInProgress else { return }

        guard let products = products else {
            loadProducts()
            return
        }

        if products.hasUnknownEligibiity {
            loadProductsEnsuringEligibility()
        }
    }

    private var productsLoadingInProgress = false

    private func loadProducts() {
        productsLoadingInProgress = true

        log(.verbose, "loadProducts begin")

        queue.async { [weak self] in
            guard let self = self else { return }

            Adapty.getPaywallProducts(paywall: self.paywall) { [weak self] result in
                switch result {
                case let .success(products):
                    self?.log(.verbose, "loadProducts success")

                    self?.products = products

                    if self?.selectedProduct == nil {
                        self?.selectedProduct = products.first
                    }

                    if products.hasUnknownEligibiity {
                        self?.loadProductsEnsuringEligibility()
                    } else {
                        self?.productsLoadingInProgress = false
                    }

                case let .failure(error):
                    self?.log(.error, "loadProducts fail: \(error)")
                    self?.productsLoadingInProgress = false

                    if self?.delegate?.didFailLoadingProducts(with: .default, error: error) ?? false {
                        self?.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                            self?.loadProducts()
                        }
                    }
                }
            }
        }
    }

    private func loadProductsEnsuringEligibility() {
        productsLoadingInProgress = true

        log(.verbose, "loadProductsEnsuringEligibility begin")

        queue.async { [weak self] in
            guard let self = self else { return }

            Adapty.getPaywallProducts(paywall: self.paywall, fetchPolicy: .waitForReceiptValidation) { [weak self] result in
                switch result {
                case let .success(products):
                    self?.log(.verbose, "loadProductsEnsuringEligibility success")
                    self?.products = products
                    self?.productsLoadingInProgress = false
                case let .failure(error):
                    self?.log(.error, "loadProductsEnsuringEligibility fail: \(error)")
                    self?.productsLoadingInProgress = false

                    if self?.delegate?.didFailLoadingProducts(with: .waitForReceiptValidation, error: error) ?? false {
                        self?.queue.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
                            self?.loadProductsEnsuringEligibility()
                        }
                    }
                }
            }
        }
    }
}

extension AdaptyPaywallPresenter {
    func log(_ level: AdaptyLogLevel, _ message: String) {
        AdaptyUI.writeLog(level: level, message: "#\(logId)# \(message)")
    }
}
