//
//  Subscription.swift
//  ClassPath
//
//  Created by coldfin_lb on 1/20/18.
//  Copyright © 2018 Coldfin. All rights reserved.
//

import Foundation

public struct SubscribedProduct{
    
    static let productIDsNonRenewing: Set<ProductIdentifier> = ["com.lifestyle.classpath.sevendays","com.lifestyle.classpath.2weeks"]
    
    public static let store = IAPHelper(productIds: SubscribedProduct.productIDsNonRenewing
        .union(SubscribedProduct.productIDsNonRenewing))
    
    public static func resourceName(for productIdentifier: String) -> String? {
        return productIdentifier.components(separatedBy: ".").last
    }
    public static func clearProducts() {
        store.purchasedProducts.removeAll()
    }
    
    public static func handlePurchase(productID: String) {
        if productIDsNonRenewing.contains(productID), productID.contains("oneDay") {
            handleMonthlySubscription(months: 1)
        } else if productIDsNonRenewing.contains(productID), productID.contains("3days") {
            handleMonthlySubscription(months: 6)
        } else if productIDsNonRenewing.contains(productID), productID.contains("14days") {
            handleMonthlySubscription(months: 12)
        }
    }
    
    private static func handleMonthlySubscription(months: Int) {
        
    }
}
