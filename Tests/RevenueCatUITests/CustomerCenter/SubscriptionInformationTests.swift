//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  PurchaseInformationTests.swift
//
//  Created by Cesar de la Vega on 10/25/24.

import Nimble
import XCTest

import RevenueCat
@testable import RevenueCatUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
class PurchaseInformationTests: TestCase {

    static let locale: Locale = .current
    static let mockDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter
    }()

    func testAppleEntitlementAndSubscribedProduct() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithAppleSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let mockProduct = TestStoreProduct(
            localizedTitle: "Monthly Product",
            price: 6.99,
            localizedPriceString: "$6.99",
            productIdentifier: entitlement.productIdentifier,
            productType: .autoRenewableSubscription,
            localizedDescription: "PRO monthly",
            subscriptionGroupIdentifier: "group",
            subscriptionPeriod: .init(value: 1, unit: .month),
            introductoryDiscount: nil,
            locale: Self.locale
        )

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 subscribedProduct: mockProduct.toStoreProduct(),
                                                                 dateFormatter: Self.mockDateFormatter))
        expect(subscriptionInfo.title) == "Monthly Product"
        expect(subscriptionInfo.durationTitle) == "1 month"
        expect(subscriptionInfo.explanation) == .earliestRenewal
        expect(subscriptionInfo.price) == .paid("$6.99")

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .nextBillingDate
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .appStore
    }

    func testAppleEntitlementAndNonRenewingSubscribedProduct() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithNonRenewingAppleSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let mockProduct = TestStoreProduct(
            localizedTitle: "Monthly Product",
            price: 6.99,
            localizedPriceString: "$6.99",
            productIdentifier: entitlement.productIdentifier,
            productType: .autoRenewableSubscription,
            localizedDescription: "PRO monthly",
            subscriptionGroupIdentifier: "group",
            subscriptionPeriod: .init(value: 1, unit: .month),
            introductoryDiscount: nil,
            locale: Self.locale
        )

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 subscribedProduct: mockProduct.toStoreProduct(),
                                                                 dateFormatter: Self.mockDateFormatter))
        expect(subscriptionInfo.title) == "Monthly Product"
        expect(subscriptionInfo.durationTitle) == "1 month"
        expect(subscriptionInfo.explanation) == .earliestExpiration
        expect(subscriptionInfo.price) == .paid("$6.99")

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expires
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .appStore
    }

    func testAppleEntitlementAndExpiredSubscribedProduct() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithExpiredAppleSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let mockProduct = TestStoreProduct(
            localizedTitle: "Monthly Product",
            price: 6.99,
            localizedPriceString: "$6.99",
            productIdentifier: entitlement.productIdentifier,
            productType: .autoRenewableSubscription,
            localizedDescription: "PRO monthly",
            subscriptionGroupIdentifier: "group",
            subscriptionPeriod: .init(value: 1, unit: .month),
            introductoryDiscount: nil,
            locale: Self.locale
        )

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 subscribedProduct: mockProduct.toStoreProduct(),
                                                                 dateFormatter: Self.mockDateFormatter))
        expect(subscriptionInfo.title) == "Monthly Product"
        expect(subscriptionInfo.durationTitle) == "1 month"
        expect(subscriptionInfo.explanation) == .expired
        expect(subscriptionInfo.price) == .paid("$6.99")

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expired
        expect(expirationOrRenewal.date) == .date("Apr 12, 2000")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .appStore
    }

    func testInitWithGoogleEntitlement() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithGoogleSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .google
        expect(subscriptionInfo.price) == .unknown

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .nextBillingDate
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .playStore
    }

    func testInitWithGoogleEntitlementNonRenewing() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithNonRenewingGoogleSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .google
        expect(subscriptionInfo.price) == .unknown

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expires
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .playStore
    }

    func testInitWithGoogleEntitlementExpired() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithExpiredGoogleSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .google
        expect(subscriptionInfo.price) == .unknown

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expired
        expect(expirationOrRenewal.date) == .date("Apr 12, 2000")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .playStore
    }

    func testInitWithPromotionalEntitlement() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithPromotional
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .promotional
        expect(subscriptionInfo.price) == .free

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expires
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .promotional
    }

    func testInitWithPromotionalLifetimeEntitlement() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithLifetimePromotional
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .promotional
        expect(subscriptionInfo.price) == .free

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expires
        expect(expirationOrRenewal.date) == .never

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .promotional
    }

    func testInitWithStripeEntitlement() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithStripeSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .web
        expect(subscriptionInfo.price) == .unknown

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .nextBillingDate
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .stripe
    }

    func testInitWithStripeEntitlementNonRenewing() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithNonRenewingStripeSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .web
        expect(subscriptionInfo.price) == .unknown

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expires
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .stripe
    }

    func testInitWithStripeEntitlementExpired() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithExpiredStripeSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(entitlement: entitlement,
                                                                 dateFormatter: Self.mockDateFormatter))

        expect(subscriptionInfo.title).to(beNil())
        expect(subscriptionInfo.durationTitle).to(beNil())
        expect(subscriptionInfo.explanation) == .web
        expect(subscriptionInfo.price) == .unknown

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expired
        expect(expirationOrRenewal.date) == .date("Apr 12, 2000")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .stripe
    }

    func testLoadingOnlyWithProductInformation() throws {
        let customerInfo = CustomerInfoFixtures.customerInfoWithNonRenewingAppleSubscriptions
        let entitlement = try XCTUnwrap(customerInfo.entitlements.all.first?.value)

        let mockProduct = TestStoreProduct(
            localizedTitle: "Monthly Product",
            price: 6.99,
            localizedPriceString: "$6.99",
            productIdentifier: entitlement.productIdentifier,
            productType: .autoRenewableSubscription,
            localizedDescription: "PRO monthly",
            subscriptionGroupIdentifier: "group",
            subscriptionPeriod: .init(value: 1, unit: .month),
            introductoryDiscount: nil,
            locale: Self.locale
        )

        let testDate = Self.mockDateFormatter.date(from: "Apr 12, 2062")!
        let subscriptionInfo = try XCTUnwrap(PurchaseInformation(product: mockProduct.toStoreProduct(),
                                                                 expirationDate: testDate,
                                                                 dateFormatter: Self.mockDateFormatter))
        expect(subscriptionInfo.title) == "Monthly Product"
        expect(subscriptionInfo.explanation) == .earliestRenewal
        expect(subscriptionInfo.durationTitle) == "1 month"
        expect(subscriptionInfo.price) == .paid("$6.99")

        let expirationOrRenewal = try XCTUnwrap(subscriptionInfo.expirationOrRenewal)
        expect(expirationOrRenewal.label) == .expires
        expect(expirationOrRenewal.date) == .date("Apr 12, 2062")

        expect(subscriptionInfo.productIdentifier) == entitlement.productIdentifier
        expect(subscriptionInfo.store) == .appStore
    }

}