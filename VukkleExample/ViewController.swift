//
//  ViewController.swift
//  VukkleExample
//
//  Created by MAC_7 on 12/21/17.
//  Copyright © 2017 MAC_7. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import MessageUI

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var containerForWKWebView: UIView!
    @IBOutlet weak var containerwkWebViewWithScript: UIView!
    @IBOutlet weak var containerForTopPowerBar: UIView!
    @IBOutlet weak var containerForBottomPowerBar: UIView!
    
    @IBOutlet weak var someTextLabel: UILabel!
    @IBOutlet weak var heightWKWebViewWithScript: NSLayoutConstraint!
    @IBOutlet weak var heightWKWebViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightScrollView: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var wkWebViewWithScript: WKWebView!
    private var wkWebViewWithEmoji: WKWebView!
    private var wkWebViewForTopPowerBar: WKWebView!
    private var wkWebViewForBottonPowerBar: WKWebView!
    
    private let configuration = WKWebViewConfiguration()
    private var scriptWebViewHeight: CGFloat = 0
    var newWebviewPopupWindow: WKWebView?
    var isKeyboardOpened = false
    let name = "Ross"
    let email = "email@sda"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "VUUKLE"
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.configureWebView), name: NSNotification.Name("updateWebViews"), object: nil)
        
        configureWebView()
        askCameraAccess()
    }

    @objc func configureWebView() {
        addWKWebViewForScript()
        addWKWebViewForEmoji()
        addWKWebViewForTopPowerBar()
        addWKWebViewForBottomPowerBar()
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

    
    // Ask permission to use camera For adding photo in the comment box
    func askCameraAccess() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                // access granted
            } else {
                // access not granted
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        wkWebViewWithScript.scrollView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
    
    // Create WebView for Comment Box
    private func addWKWebViewForScript() {
        
        let thePreferences = WKPreferences()
        thePreferences.javaScriptCanOpenWindowsAutomatically = true
        thePreferences.javaScriptEnabled = true
        configuration.preferences = thePreferences
        
        wkWebViewWithScript = WKWebView(frame: .zero, configuration: configuration)
        wkWebViewWithScript.navigationDelegate = self
        wkWebViewWithScript.uiDelegate = self
        self.containerwkWebViewWithScript.addSubview(wkWebViewWithScript)
        
        wkWebViewWithScript.translatesAutoresizingMaskIntoConstraints = false
        wkWebViewWithScript.scrollView.layer.masksToBounds = false
        wkWebViewWithScript.scrollView.delegate = self
        
        wkWebViewWithScript.topAnchor.constraint(equalTo: self.containerwkWebViewWithScript.topAnchor).isActive = true
        wkWebViewWithScript.bottomAnchor.constraint(equalTo: self.containerwkWebViewWithScript.bottomAnchor).isActive = true
        wkWebViewWithScript.leftAnchor.constraint(equalTo: self.containerwkWebViewWithScript.leftAnchor).isActive = true
        wkWebViewWithScript.rightAnchor.constraint(equalTo: self.containerwkWebViewWithScript.rightAnchor).isActive = true
        
        // Added this Observer for detect wkWebView's scrollview contentSize height updates
        wkWebViewWithScript.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        wkWebViewWithScript.scrollView.isScrollEnabled = false
        wkWebViewWithScript.isMultipleTouchEnabled = false
        wkWebViewWithScript.contentMode = .scaleAspectFit
        wkWebViewWithScript.scrollView.bouncesZoom = false
        //self.heightWKWebViewWithScript.constant = scriptWebViewHeight
        
        if let url = URL(string: VUUKLE_IFRAME) {
            wkWebViewWithScript.load(URLRequest(url: url))
        }
    }
    
    // Create WebView for Emoji
    private func addWKWebViewForEmoji() {
        
        wkWebViewWithEmoji = WKWebView(frame: .zero, configuration: configuration)
        self.containerForWKWebView.addSubview(wkWebViewWithEmoji)
        
        wkWebViewWithEmoji.translatesAutoresizingMaskIntoConstraints = false
        wkWebViewWithEmoji.topAnchor.constraint(equalTo: self.containerForWKWebView.topAnchor).isActive = true
        wkWebViewWithEmoji.bottomAnchor.constraint(equalTo: self.containerForWKWebView.bottomAnchor).isActive = true
        wkWebViewWithEmoji.leftAnchor.constraint(equalTo: self.containerForWKWebView.leftAnchor).isActive = true
        wkWebViewWithEmoji.rightAnchor.constraint(equalTo: self.containerForWKWebView.rightAnchor).isActive = true
        
        if let url = URL(string: VUUKLE_EMOTES) {
            wkWebViewWithEmoji.load(URLRequest(url: url))
        }
    }
    
    // Create WebView for Top PowerBar
    private func addWKWebViewForTopPowerBar() {
        
        wkWebViewForTopPowerBar = WKWebView(frame: .zero, configuration: configuration)
        self.containerForTopPowerBar.addSubview(wkWebViewForTopPowerBar)
        
        wkWebViewForTopPowerBar.translatesAutoresizingMaskIntoConstraints = false
        wkWebViewForTopPowerBar.topAnchor.constraint(equalTo: self.containerForTopPowerBar.topAnchor).isActive = true
        wkWebViewForTopPowerBar.bottomAnchor.constraint(equalTo: self.containerForTopPowerBar.bottomAnchor).isActive = true
        wkWebViewForTopPowerBar.leftAnchor.constraint(equalTo: self.containerForTopPowerBar.leftAnchor).isActive = true
        wkWebViewForTopPowerBar.rightAnchor.constraint(equalTo: self.containerForTopPowerBar.rightAnchor).isActive = true
        wkWebViewForTopPowerBar.uiDelegate = self
        wkWebViewForTopPowerBar.navigationDelegate = self
        
        if let url = URL(string: VUUKLE_POWERBAR) {
            wkWebViewForTopPowerBar.load(URLRequest(url: url))
        }
    }
    
    // Create WebView for Bottom PowerBar
    private func addWKWebViewForBottomPowerBar() {
        
        wkWebViewForBottonPowerBar = WKWebView(frame: .zero, configuration: configuration)
        self.containerForBottomPowerBar.addSubview(wkWebViewForBottonPowerBar)
        
        wkWebViewForBottonPowerBar.translatesAutoresizingMaskIntoConstraints = false
        wkWebViewForBottonPowerBar.topAnchor.constraint(equalTo: self.containerForBottomPowerBar.topAnchor).isActive = true
        wkWebViewForBottonPowerBar.bottomAnchor.constraint(equalTo: self.containerForBottomPowerBar.bottomAnchor).isActive = true
        wkWebViewForBottonPowerBar.leftAnchor.constraint(equalTo: self.containerForBottomPowerBar.leftAnchor).isActive = true
        wkWebViewForBottonPowerBar.rightAnchor.constraint(equalTo: self.containerForBottomPowerBar.rightAnchor).isActive = true
        wkWebViewForBottonPowerBar.uiDelegate = self
        wkWebViewForBottonPowerBar.navigationDelegate = self
        if let url = URL(string: VUUKLE_POWERBAR) {
            wkWebViewForBottonPowerBar.load(URLRequest(url: url))
        }
    }
    
    // Observer for detect wkWebView's scrollview contentSize height updates
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let scroll = object as? UIScrollView {
                if scroll.contentSize.height > 0 && !isKeyboardOpened {
                    print("scroll.contentSize.height = \(scroll.contentSize.height)")
                    self.heightWKWebViewWithScript.constant = scroll.contentSize.height
                    scriptWebViewHeight = scroll.contentSize.height
                }
            }
        }
    }
    
    // MARK: - Clear cookie
    
    private func clearAllCookies() {
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
    }
    
    private func clearCookiesFromSpecificUrl(yourUrl: String) {
        let cookieStorage: HTTPCookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: URL(string: yourUrl)!)
        for cookie in cookies! {
            cookieStorage.deleteCookie(cookie as HTTPCookie)
        }
    }
    
    private func openNewWindow(newURL: String) {
        
        for url in VUUKLE_URLS {
            if newURL.hasPrefix(VUUKLE_MAIL_SHARE) {
                let mailSubjectBody = parsMailSubjextAndBody(mailto: newURL)
                sendEmail(subject: mailSubjectBody.subject, body: mailSubjectBody.body)
                return
            } else if newURL.hasPrefix(VUUKLE_MESSENGER_SHARE) {
                let messengerUrlString = replaceLinkSymboles(text: newURL)
                guard let messengerUrl = URL(string: messengerUrlString) else { return }
                UIApplication.shared.open(messengerUrl)
                return
            } else if newURL.hasPrefix(url) {
                wkWebViewWithScript.load(URLRequest(url: URL(string: "about:blank")!))
                self.openNewsWindow(withURL: newURL)
                return
            }
        }
    }
    
    // MARK: - WKNavigationDelegate methods
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("BASE URL = \(webView.url?.absoluteString ?? "")")
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { (height, error) in
                    // You can detect webView's scrollView contentSize height
                    if webView == self.wkWebViewWithScript {
                        self.heightWKWebViewWithScript.constant = (height as? CGFloat) ?? 0.0
                        self.scriptWebViewHeight = height as! CGFloat
                    }
                })
            }
        })
    }
    
    // MARK: - WKUIDelegate methods
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        present(alertController, animated: true)
        alertController.addTextField(configurationHandler: nil)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (okAction) in
            completionHandler(alertController.textFields?.first?.text)
        }))
    }
    
    func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        
        let vc = UIViewController()
        
        return vc
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if (navigationAction.request.url?.absoluteString ?? "").hasPrefix(VUUKLE_MAIL_TO_SHARE) {
            let mailSubjectBody = parsMailSubjextAndBody(mailto: navigationAction.request.url?.absoluteString ?? "")
            sendEmail(subject: mailSubjectBody.subject, body: mailSubjectBody.body)
        } else {
            for url in VUUKLE_URLS {
                if (navigationAction.request.url?.absoluteString ?? "").contains(url) {
                    openNewWindow(newURL: navigationAction.request.url?.absoluteString ?? "")
                    break
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow, preferences)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        //self.openNewsWindow(withURL: navigationResponse.response.url?.absoluteString ?? "")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        return true
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("createWebViewWith")
        openNewWindow(newURL: navigationAction.request.url?.absoluteString ?? "")
        
        webView.evaluateJavaScript("window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);", completionHandler: nil)
        
        webView.evaluateJavaScript("window.close = function() { window.location.href = 'myapp://closewebview'; }", completionHandler: nil)
        
        return nil
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        print("BASE URL = \(webView.url?.absoluteString ?? "")")
        self.heightWKWebViewWithScript.constant = scriptWebViewHeight
        if navigationAction.navigationType == .linkActivated {
            openNewWindow(newURL: navigationAction.request.url?.absoluteString ?? "")
            decisionHandler(.allow)
            return
        } else if navigationAction.navigationType == .other {
                openNewWindow(newURL: navigationAction.request.url?.absoluteString ?? "")
        }
        decisionHandler(.allow)
        return
    }
   
    func openNewsWindow(withURL: String) {
        let newsWindow = VuukleNewViewController()
        newsWindow.wkWebView = self.wkWebViewWithScript
        newsWindow.configuration = self.configuration
        newsWindow.urlString = withURL
    
        self.navigationController?.pushViewController(newsWindow, animated: true)
    }
    
}

// MARK: - SEND EMAIL Metods
extension ViewController: MFMailComposeViewControllerDelegate {
    
    func sendEmail(subject: String, body: String) {
        let recipientEmail = ""
        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            present(mail, animated: true)
            
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            let newMailto = (emailUrl.absoluteString).replacingOccurrences(of: "%20", with: "")
            UIApplication.shared.open(URL(string: newMailto)!)
        }
    }
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
    
    // Get Subject and Body from mailto url.
    func parsMailSubjextAndBody(mailto: String) -> (subject: String, body: String) {
        
        let newMailto = replaceLinkSymboles(text: mailto)
        
        let subjectStartIndex = newMailto.firstIndex(of: "=")!
        let subjectEndIndex = newMailto.firstIndex(of: "&")!
        var subject = String(newMailto[subjectStartIndex..<subjectEndIndex])
        let bodyStartIndex = newMailto.lastIndex(of: "=")!
        var body = String(newMailto[bodyStartIndex...])
        subject.removeFirst()
        body.removeFirst()
        
        return (subject: subject, body: body)
    }
    
    func replaceLinkSymboles(text: String) -> String {
        var newText = text.replacingOccurrences(of: "%20", with: " ")
        newText = newText.replacingOccurrences(of: "%3A", with: ":")
        newText = newText.replacingOccurrences(of: "%2F", with: "/")
        return newText
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}