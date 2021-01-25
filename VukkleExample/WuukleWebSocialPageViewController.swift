//  WuukleWebSocialPageViewController.swift
//  VukkleExample
//
//  Created by Narek Dallakyan on 20.01.21.
//  Copyright © 2021 MAC_7. All rights reserved.
//

import UIKit
import UIKit
import WebKit
import AVFoundation
import MessageUI

class WuukleWebSocialPageViewController: UIViewController {
    
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var contentViewForWKWebView: UIView!
    
    @IBOutlet weak var scrollContentViewHeightConstraint: NSLayoutConstraint!
    
    static let id = "WuukleWebSocialPageViewController"
    
    var wkWebView: WKWebView!
    var configuration = WKWebViewConfiguration()
    var activityView = UIActivityIndicatorView()
    var activityBackgroundView = UIView()
    
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
        setWKWebViewConfigurations()
        addWKWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        edgesForExtendedLayout = []
        wkWebView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        scrollContentViewHeightConstraint.constant = self.view.frame.height
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
        //Code the lines to hide the keyboard and the extra lines you want to execute before keyboard hides.
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
    
    func setWKWebViewConfigurations() {
        let thePreferences = WKPreferences()
        thePreferences.javaScriptCanOpenWindowsAutomatically = true
        thePreferences.javaScriptEnabled = true
        configuration.preferences = thePreferences
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"

        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController: WKUserContentController = WKUserContentController()

        userContentController.addUserScript(script)
        configuration.userContentController = userContentController
        
        configuration.processPool = WKProcessPool()
        let cookies = HTTPCookieStorage.shared.cookies ?? [HTTPCookie]()
        cookies.forEach({ if #available(iOS 11.0, *) {
            configuration.websiteDataStore.httpCookieStore.setCookie($0, completionHandler: nil)
        } else {
            
        } })

        if urlString == VUUKLE_SOCIAL_LOGIN_GOOGLE {
            configuration.applicationNameForUserAgent = VUUKLE_GOOGLE_CONFIG
        }
    }
    
    private func addWKWebView() {
        
        wkWebView = WKWebView(frame: contentViewForWKWebView.bounds, configuration: configuration)
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentViewForWKWebView.addSubview(wkWebView)
        
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
        
        self.startActivityIndicator()
    }

    func startActivityIndicator() {
        activityBackgroundView.frame = self.view.frame
        activityBackgroundView.backgroundColor = .white
        activityBackgroundView.isHidden = false

        activityView.center = activityBackgroundView.center
        activityBackgroundView.addSubview(activityView)
        activityView.isHidden = false
        activityView.startAnimating()

        self.view.addSubview(activityBackgroundView)
    }

    func stopActivityIndicator() {
        activityView.isHidden = true
        activityView.stopAnimating()
        activityBackgroundView.isHidden = true
        wkWebView.isHidden = false
    }
    
    // Observer for detect wkWebView's scrollview contentSize height updates
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let scroll = object as? UIScrollView {
                if scroll.contentSize.height > 0 && !isKeyboardOpened {
                    if wkWebView.isLoading  {
                        scrollContentViewHeightConstraint.constant = scroll.contentSize.height
                    }
                }
            }
        }
    }
}

extension WuukleWebSocialPageViewController: WKNavigationDelegate, WKUIDelegate  {
    
    // MARK: WKNavigationDelegate methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        scrollContentViewHeightConstraint.constant = self.view.frame.height
        stopActivityIndicator()
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
        decisionHandler(.allow)
        return
    }
    
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
            
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}

