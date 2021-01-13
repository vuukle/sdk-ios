//
//  VuukleNewsViewController.swift
//  VukkleExample
//
//  Created by Nrek Dallakyan on 11/22/20.
//  Copyright © 2020 MAC_7. All rights reserved.
//

import UIKit
import WebKit

class VuukleNewViewController: UIViewController {
    
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var contentViewForWKWebView: UIView!
    
    @IBOutlet weak var scrollContentViewHeightConstraint: NSLayoutConstraint!
    
    
    var wkWebView: WKWebView!
    var configuration = WKWebViewConfiguration()
    var activityView = UIActivityIndicatorView()
    
    var urlString = ""
    var isLoadedSettings = false
    var backButton: UIBarButtonItem?
    var forwardButton: UIBarButtonItem?
    var cookies: [HTTPCookie] = []
    var isKeyboardOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        addNewButtonsOnNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        edgesForExtendedLayout = []
        scrollContentViewHeightConstraint.constant = self.view.frame.height
        addWKWebView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        wkWebView.scrollView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
        
    //Register for keyboard notification
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    //Hide keyboard
    @objc func keyboardHide() {
        //Code the lines to hide the keyboard and the extra lines you      want to execute before keyboard hides.
        self.perform(#selector(keyboardHided), with: nil, afterDelay: 1)
    }
    
    @objc func keyboardHided() {
        isKeyboardOpened = false
    }
    
    //Show keyboard
    @objc func keyboardShow() {
        //Code the lines you want to execute before keyboard pops up.
        isKeyboardOpened = true
    }

    func addNewButtonsOnNavigationBar() {
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        if #available(iOS 13.0, *) {
            let backButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.left")!.withTintColor(.blue, renderingMode: .alwaysTemplate),
                style: .plain,
                target: self.wkWebView,
                action: #selector(WKWebView.goBack))
            self.backButton = backButton
        }
        if #available(iOS 13.0, *) {
            let forwardButton = UIBarButtonItem(
                image: UIImage(systemName: "arrow.right")!.withTintColor(.blue, renderingMode: .alwaysTemplate),
                style: .plain,
                target: self.wkWebView,
                action: #selector(WKWebView.goForward))
            self.forwardButton = forwardButton
        }
        
        navigationItem.rightBarButtonItems = [self.forwardButton!, self.backButton!]
    }
    
    @objc func configureWebView() {
        wkWebView.reload()
    }
    
    private func addWKWebView() {
        
        configuration.processPool = WKProcessPool()
        let cookies = HTTPCookieStorage.shared.cookies ?? [HTTPCookie]()
        cookies.forEach({ if #available(iOS 11.0, *) {
            configuration.websiteDataStore.httpCookieStore.setCookie($0, completionHandler: nil)
        } else {
            
        } })
   
        wkWebView = WKWebView(frame: contentViewForWKWebView.frame, configuration: configuration)
        contentViewForWKWebView.addSubview(wkWebView)
        wkWebView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.scrollView.layer.masksToBounds = false
        
        wkWebView.topAnchor.constraint(equalTo: self.scrollContentView.topAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: self.scrollContentView.bottomAnchor).isActive = true
        wkWebView.leftAnchor.constraint(equalTo: self.scrollContentView.leftAnchor).isActive = true
        wkWebView.rightAnchor.constraint(equalTo: self.scrollContentView.rightAnchor).isActive = true
        
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        self.wkWebView.isHidden = true
        self.view.backgroundColor = .white
        
        if urlString == VUUKLE_SETTINGS {
            isLoadedSettings = true
        } else {
            isLoadedSettings = false
        }
        if let url = URL(string: urlString) {
            wkWebView.load(URLRequest(url: url))
        }
        
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.isHidden = false
        activityView.startAnimating()
    }
    
    // Observer for detect wkWebView's scrollview contentSize height updates
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let scroll = object as? UIScrollView {
                if scroll.contentSize.height > 0 && !isKeyboardOpened {
                print("scroll.contentSize.height = \(scroll.contentSize.height)")
                    print("scrollContentViewHeightConstraint.constant = \(scrollContentViewHeightConstraint.constant)")
                    scrollContentViewHeightConstraint.constant = scroll.contentSize.height
                }
            }
        }
    }

}

extension VuukleNewViewController:  WKNavigationDelegate, WKUIDelegate  {
    
    // MARK: WKNavigationDelegate methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish navigation in VuukleNewViewController")
        scrollContentViewHeightConstraint.constant = self.view.frame.height

        activityView.isHidden = true
        activityView.stopAnimating()
        self.wkWebView.isHidden = false
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { (height, error) in
                    
                })
            }
        })
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        scrollContentViewHeightConstraint.constant = self.view.frame.height
        webView.load(navigationAction.request)
        webView.evaluateJavaScript("window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);", completionHandler: nil)
        webView.evaluateJavaScript("window.close = function() { window.location.href = 'myapp://closewebview'; }", completionHandler: nil)
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        present(alertController, animated: true)
        alertController.addTextField(configurationHandler: nil)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (okAction) in
            completionHandler(alertController.textFields?.first?.text)
        }))
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {

        if navigationAction.navigationType == .other {
            if (navigationAction.request.url?.absoluteString.contains(VUUKLE_SOCIAL_LOGIN_SUCCESS))! {
                if isLoadedSettings {
                    wkWebView.goBack()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        decisionHandler(.allow)
        return
    }
   
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        completionHandler(true)
    }
}
