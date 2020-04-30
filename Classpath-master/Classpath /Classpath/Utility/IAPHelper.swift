/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import StoreKit
import Firebase

var list_id = String()

var ref = Database.database().reference()
public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class IAPHelper: NSObject  {
    
    // MARK: - Properties
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    public var purchasedProducts = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    // MARK: - Initializers
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        purchasedProducts = Set(productIds.filter { UserDefaults.standard.bool(forKey: $0) })
        
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API
extension IAPHelper {

  public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest!.delegate = self
    productsRequest!.start()
  }

  public func buyProduct(_ product: SKProduct) {
    print(product.productIdentifier)
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }

  public func isPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
    return purchasedProducts.contains(productIdentifier)
  }

  public class func canMakePayments() -> Bool {
    return SKPaymentQueue.canMakePayments()
  }

  public func restorePurchases() {
    // Restore Consumables and Non-Consumables from Apple
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
}

// MARK: - SKProductsRequestDelegate
extension IAPHelper: SKProductsRequestDelegate {
  
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

    let products = response.products
    print("Loaded list of products...")
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()

    for prod in products {
      print("Found product: \(prod.productIdentifier) \(prod.localizedTitle) \(prod.price.floatValue)")
    }
  }

  public func request(_ request: SKRequest, didFailWithError error: Error) {
    print("Failed to load list of products.")
    print("Error: \(error.localizedDescription)")
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }

  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

// MARK: - SKPaymentTransactionObserver
extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        
        let parameter = defaults.value(forKeyPath: "listvalue") as! NSMutableDictionary
        ref = Database.database().reference()
        
        ref.child(nodeListings).child(list_id)
        let childUpdates = ["/\(nodeListings)/\(list_id)": parameter]
        ref.updateChildValues(childUpdates)
        
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        defaults.set("complete", forKey: "redirect")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "paymentcomplete"), object: nil)
    }
    
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        SKPaymentQueue.default().finishTransaction(transaction)
        defaults.set("Fail", forKey: "redirect")
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        
    }
}
