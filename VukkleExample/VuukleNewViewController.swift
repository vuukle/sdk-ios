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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        edgesForExtendedLayout = []
        scrollContentViewHeightConstraint.constant = self.view.frame.height
        addWKWebView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        wkWebView.scrollView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    
    deinit {
        print("deinit in")
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
    
    // Ask user to download application alert
    func createAlertController(appName: String, appStoreId: String) {
        let ac = UIAlertController(title: "You don't have \(appName) in your device?", message: "Please download it!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/\(appStoreId)") {
                UIApplication.shared.open(url)
//                self.navigationController?.popViewController(animated: true)
            }
        }
        
        ac.addAction(cancelAction)
        ac.addAction(okAction)
        present(ac, animated: true, completion: nil)
    }
    
    // open or download application
    func openApplication(appName: String, navigationURLString: String, name: String, id: String) {
        if let urlString = URL(string: navigationURLString) {
            
            let appUrl = URL(string: "\(appName)")
            if UIApplication.shared.canOpenURL(appUrl!) {
                UIApplication.shared.open(urlString)
//                self.navigationController?.popViewController(animated: true)
            } else {
                createAlertController(appName: name, appStoreId: id)
            }
        }
    }
    
    func openApllicationForShare(navigationURLString: String, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        if  (navigationURLString.contains(VUUKLE_WHATSAPP_PROFILE_SHARE)) {
            openApplication(appName: "whatsapp://", navigationURLString: navigationURLString, name: "WhatsApp", id: "id310633997")
            decisionHandler(.cancel)

        } else if (navigationURLString.contains(VUUKLE_TG_SHARE)) {
            openApplication(appName: "telegram://", navigationURLString: navigationURLString, name: "Telegram", id: "id686449807")
            decisionHandler(.cancel)

        } else if (navigationURLString.contains(VUUKLE_FB_SHARE)) {
            openApplication(appName: "fb://", navigationURLString: navigationURLString, name: "Facebook", id: "id284882215")
            decisionHandler(.cancel)
 
        }  else if (navigationURLString.contains(VUUKLE_LINKEDIN_SHARE)) {
            openApplication(appName: "LinkedIn://", navigationURLString: navigationURLString, name: "LinkedIn", id: "id288429040")
            decisionHandler(.cancel)

        } else if (navigationURLString.contains(VUUKLE_TWITTER_SHARE)) {
            openApplication(appName: "twitter://", navigationURLString: navigationURLString, name: "Twitter", id: "id333903271")
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
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
        wkWebView.allowsBackForwardNavigationGestures = true
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
        
        startActivityIndicator()
    }
    
    // Observer for detect wkWebView's scrollview contentSize height updates
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let scroll = object as? UIScrollView {
                if scroll.contentSize.height > 0 && !isKeyboardOpened {
                    //                print("scroll.contentSize.height = \(scroll.contentSize.height)")
                    //                    print("scrollContentViewHeightConstraint.constant = \(scrollContentViewHeightConstraint.constant)")
                    if wkWebView.isLoading  {
                        scrollContentViewHeightConstraint.constant = scroll.contentSize.height
                    }
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
        
        stopActivityIndicator()
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { (height, error) in
                    
                })
            }
        })
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("1 in VuukleNewViewController")
    
        scrollContentViewHeightConstraint.constant = self.view.frame.height
        webView.load(navigationAction.request)
        webView.evaluateJavaScript("window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);", completionHandler: nil)
        
        webView.evaluateJavaScript("window.close = function() { window.location.href = 'myapp://closewebview'; }", completionHandler: nil)
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("2 in VuukleNewViewController")
        
        let alertController = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        present(alertController, animated: true)
        alertController.addTextField(configurationHandler: nil)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (okAction) in
            completionHandler(alertController.textFields?.first?.text)
        }))
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        print("3 in VuukleNewViewController")
        let navigationURLString = navigationAction.request.url?.absoluteString ?? ""

//        if navigationAction.navigationType == .other {
//            if (navigationURLString.contains(VUUKLE_SOCIAL_LOGIN_SUCCESS)) {
//                if isLoadedSettings {
//                    wkWebView.goBack()
//                } else {
//                    self.navigationController?.popViewController(animated: true)
//                }
//                decisionHandler(.allow)
//            } else if  (navigationURLString.contains(VUUKLE_WHATSAPP_SHARE)) {
//                openApplication(appName: "whatsapp://", navigationURLString: navigationURLString, name: "WhatsApp", id: "id310633997")
//                decisionHandler(.cancel)
//
//            }  else if  (navigationURLString.contains(VUUKLE_REDDIT_SHARE)) {
//                openApplication(appName: "reddit://", navigationURLString: navigationURLString, name: "Reddit", id: "id1064216828")
//                decisionHandler(.cancel)
//
//            } else if (navigationURLString.contains(VUUKLE_TG_SHARE)) {
//                openApplication(appName: "telegram://", navigationURLString: navigationURLString, name: "Telegram", id: "id686449807")
//                decisionHandler(.cancel)
//
//            } else {
//                decisionHandler(.allow)
//            }
//        } else if navigationAction.navigationType == .backForward {
//            wkWebView.goBack()
//            decisionHandler(.allow)
//        } else {
//            decisionHandler(.allow)
//        }
        
        
        
        
        
        
        ///////////////////////////////////////////////////////////////
        
        
        
        
        if (navigationURLString.contains(VUUKLE_SOCIAL_LOGIN_SUCCESS)) {
            if isLoadedSettings {
                wkWebView.goBack()
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            decisionHandler(.allow)
        } else {
            openApllicationForShare(navigationURLString: navigationURLString, decisionHandler: decisionHandler)
        }
        return
    }
    
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        print("4 in VuukleNewViewController")
        
        return true
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("5 in VuukleNewViewController")
        
        completionHandler(true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("7 in VuukleNewViewController")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("8 in VuukleNewViewController")
        
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("9 in VuukleNewViewController")
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("10 in VuukleNewViewController")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("11 in VuukleNewViewController")
        
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("error == \(error.localizedDescription)")
        print("12 in VuukleNewViewController")
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("13 in VuukleNewViewController")
        completionHandler(.performDefaultHandling, nil)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        print("14 in VuukleNewViewController")
    }
    
    func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        print("15 in VuukleNewViewController")
    }
}
