//
//  PDFViewerVC.swift
//  Classpath
//
//  Created by coldfin on 4/26/19.
//  Copyright © 2019 coldfin_lb. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewerVC: UIViewController {
    
    var url = URL(string: "sjf'dsafdjk")

    override func viewDidLoad() {
        super.viewDidLoad()

        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.scalesPageToFit = true
        view.addSubview(pdfView)
        
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //guard let path = Bundle.main.url(forResource: "fileName", withExtension: "pdf") else {  }
        
        if let document = PDFDocument(url: url!) {
            pdfView.document = document
        }
        
    }

}
