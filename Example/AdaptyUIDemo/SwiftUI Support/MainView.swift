//
//  MainView.swift
//  AdaptyUIDemo
//
//  Created by Alexey Goncharov on 30.11.23..
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: MainViewModel

    @State var paywallId: String = "test_alexey"

    var list: some View {
        List {
            Section {
                TextField("Paywall Id", text: $paywallId)
                Button("Load") {
                    Task {
                        await viewModel.loadPaywall(id: paywallId)
                    }
                }
            }

            if let paywall = viewModel.paywall {
                Section {
                    HStack {
                        Text("Variation Id")
                        Spacer()
                        Text(paywall.variationId)
                    }

                    Button("Load View") {
                        Task {
                            await viewModel.loadViewConfiguration()
                        }
                    }
                }
            }

            if let viewConfig = viewModel.viewConfig {
                Section {
                    HStack {
                        Text("Template")
                        Spacer()
                        Text(viewConfig.templateId)
                    }

                    Button("Present") {
                        paywallPresented = true
                    }
                }
            }
        }
    }

    @State var paywallPresented = false

    var body: some View {
        NavigationView {
            if let paywall = viewModel.paywall, let viewConfig = viewModel.viewConfig {
                list.paywall(
                    isPresented: $paywallPresented,
                    paywall: paywall,
                    configuration: viewConfig,
                    didPerformAction: { action in
                        switch action {
                        case .close:
                            paywallPresented = false
                        default:
                            break
                        }
                    }
                )
            } else {
                list
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel())
}
