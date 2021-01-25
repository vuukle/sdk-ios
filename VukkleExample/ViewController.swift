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

final class ViewController: UIViewController {
    
    @IBOutlet weak var containerwkWebViewWithScript: UIView!
    @IBOutlet weak var containerForTopPowerBar: UIView!
    @IBOutlet weak var containerForBottomPowerBar: UIView!
    
    @IBOutlet weak var someTextLabel: UILabel!
    @IBOutlet weak var heightWKWebViewWithScript: NSLayoutConstraint!
    @IBOutlet weak var conteinerWKWebViewWithScriptHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var wkWebViewWithScript: WKWebView!
    var wkWebViewForTopPowerBar: WKWebView!
    var wkWebViewForBottonPowerBar: WKWebView!
    
    private var configuration = WKWebViewConfiguration()
    var newWebviewPopupWindow: WKWebView?
    var isKeyboardOpened = false
    
    var isFromNewViewController = false
    var activityView = UIActivityIndicatorView()
    var activityBackgroundView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "VUUKLE"
        registerNotification()
        setWKWebViewConfigurations()
        configureWebView()
        askCameraAccess()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        heightWKWebViewWithScript.constant = CGFloat(VUUKLE_COMENT_INITIAL_HEIGHT)
        if isFromNewViewController {
            reloadWebView()
        }
        // Added this Observer for detect wkWebView's scrollview contentSize height updates
        wkWebViewWithScript.scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wkWebViewWithScript.scrollView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }

    //Register for keyboard notification
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    // Set wkwebview configurations
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
    }
    
    // configure web view
    @objc func configureWebView() {
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
        startActivityIndicator()
        addWKWebViewForScript()
        addWKWebViewForTopPowerBar()
        addWKWebViewForBottomPowerBar()
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

//     stop activity indicator
    func stopActivityIndicator() {
        activityView.isHidden = true
        activityView.stopAnimating()
        activityBackgroundView.isHidden = true
    }
    
    func reloadWebView() {
        isFromNewViewController.toggle()
        wkWebViewWithScript.reload()
        wkWebViewForBottonPowerBar.reload()
        wkWebViewForTopPowerBar.reload()
        containerwkWebViewWithScript.frame = wkWebViewWithScript.frame
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
    
    // Create WebView for Comment Box
    private func addWKWebViewForScript() {
        
        wkWebViewWithScript = WKWebView(frame: containerwkWebViewWithScript.bounds, configuration: configuration)
        wkWebViewWithScript.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.containerwkWebViewWithScript.addSubview(wkWebViewWithScript)

        wkWebViewWithScript.navigationDelegate = self
        wkWebViewWithScript.uiDelegate = self
        
        wkWebViewWithScript.scrollView.layer.masksToBounds = false
        wkWebViewWithScript.scrollView.delegate = self
        
        wkWebViewWithScript.scrollView.isScrollEnabled = false
        wkWebViewWithScript.isMultipleTouchEnabled = false
        wkWebViewWithScript.contentMode = .scaleAspectFit

        containerwkWebViewWithScript.layoutIfNeeded()
        containerwkWebViewWithScript.layoutSubviews()
        self.view.layoutSubviews()
        self.view.layoutIfNeeded()
        wkWebViewWithScript.scrollView.bouncesZoom = false
        
        if let url = URL(string: VUUKLE_IFRAME) {
            wkWebViewWithScript.load(URLRequest(url: url))
        }
    }
    
    // Create WebView for Top PowerBar
    private func addWKWebViewForTopPowerBar() {
        
        wkWebViewForTopPowerBar = WKWebView(frame: containerForTopPowerBar.bounds, configuration: configuration)
        wkWebViewForTopPowerBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.containerForTopPowerBar.addSubview(wkWebViewForTopPowerBar)
        
        wkWebViewForTopPowerBar.uiDelegate = self
        wkWebViewForTopPowerBar.navigationDelegate = self
        
        if let url = URL(string: VUUKLE_POWERBAR) {
            wkWebViewForTopPowerBar.load(URLRequest(url: url))
        }
    }
    
    // Create WebView for Bottom PowerBar
    private func addWKWebViewForBottomPowerBar() {
        print("addWKWebViewForBottomPowerBar")
        wkWebViewForBottonPowerBar = WKWebView(frame: containerForBottomPowerBar.bounds, configuration: configuration)
        wkWebViewForBottonPowerBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.containerForBottomPowerBar.addSubview(wkWebViewForBottonPowerBar)
        
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
                        self.heightWKWebViewWithScript.constant = scroll.contentSize.height
                }
            }
        }
    }
    
    private func openNewWindow(newURL: String) {
        isFromNewViewController = true
        for url in VUUKLE_URLS {
            if newURL.hasPrefix(VUUKLE_MAIL_SHARE) {
                let mailSubjectBody = parsMailSubjextAndBody(mailto: newURL)
                sendEmail(subject: mailSubjectBody.subject, body: mailSubjectBody.body)
                return
            } else if newURL.hasPrefix(url) {
                self.openNewsWindow(withURL: newURL)
                return
            }
        }
    }
    
    // Redirect to new page for social web share
    func createAlertController(appName: String, appStoreId: String, navigationURLString: String) {
        let ac = UIAlertController(title: "You don't have \(appName) in your device?", message: "Please download it!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
       
        let okAction = UIAlertAction(title: "Download", style: .default) { (action) in
            if let url = URL(string: "itms-apps://itunes.apple.com/app/\(appStoreId)") {
                UIApplication.shared.open(url)
            }
        }
        let openInWeb = UIAlertAction(title: "Open in web", style: .default) { (action) in
            self.openWebSocialSharePage(withURL: navigationURLString)
        }
        
        if appName == VUUKLE_WHATSAPP_NAME || appName == VUUKLE_MESSENGER_NAME || appName == VUUKLE_TELEGRAM_NAME {
           
        } else {
            ac.addAction(openInWeb)
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
            } else {
                createAlertController(appName: name, appStoreId: id, navigationURLString: navigationURLString)
            }
        }
    }
    
    
    func openApllicationForShare(navigationURLString: String, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        if  (navigationURLString.contains(VUUKLE_WHATSAPP_SHARE)) {
            openApplication(appName: VUUKLE_WHATSAPP_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_WHATSAPP_NAME, id: VUUKLE_WHATSAPP_APPSTORE_ID)
            decisionHandler(.cancel)

        }  else if  (navigationURLString.contains(VUUKLE_REDDIT_SHARE)) {
            openApplication(appName: VUUKLE_REDDIT_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_REDDIT_NAME, id: VUUKLE_REDDIT_APPSTORE_ID)
            decisionHandler(.cancel)

        } else if (navigationURLString.contains(VUUKLE_TELEGRAM_SHARE)) {
            openApplication(appName: VUUKLE_TELEGRAM_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_TELEGRAM_NAME, id: VUUKLE_TELEGRAM_APPSTORE_ID)
            decisionHandler(.cancel)

        } else if (navigationURLString.contains(VUUKLE_FB_SHARE)) {
            openApplication(appName: VUUKLE_FACEBOOK_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_FACEBOOK_NAME, id: VUUKLE_FACEBOOK_APPSTORE_ID)
            decisionHandler(.cancel)
 
        } else if (navigationURLString.contains(VUUKLE_MESSENGER_SHARE)) {
            openApplication(appName: VUUKLE_MESSENGER_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_MESSENGER_NAME, id: VUUKLE_MESSENGER_APPSTORE_ID)
            decisionHandler(.cancel)

        } else if (navigationURLString.contains(VUUKLE_LINKEDIN_SHARE)) {
            openApplication(appName: VUUKLE_LINKEDIN_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_LINKEDIN_NAME, id: VUUKLE_LINKEDIN_APPSTORE_ID)
            decisionHandler(.cancel)

        } else if (navigationURLString.contains(VUUKLE_TWITTER_SHARE)) {
            openApplication(appName: VUUKLE_TWITTER_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_TWITTER_NAME, id: VUUKLE_TWITTER_APPSTORE_ID)
            decisionHandler(.cancel)
        } else if (navigationURLString.contains(VUUKLE_PINTEREST_SHARE)) {
            openApplication(appName: VUUKLE_PINTEREST_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_PINTEREST_NAME, id: VUUKLE_PINTEREST_APPSTORE_ID)
            decisionHandler(.cancel)
        } else if (navigationURLString.contains(VUUKLE_FLIPBOARD_SHARE)) {
            openApplication(appName: VUUKLE_FLIPBOARD_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_FLIPBOARD_NAME, id: VUUKLE_FLIPBOARD_APPSTORE_ID)
            decisionHandler(.cancel)
        } else if (navigationURLString.contains(VUUKLE_TUMBLR_SHARE)) {
            openApplication(appName: VUUKLE_TUMBLR_DEVICE_URL, navigationURLString: navigationURLString, name: VUUKLE_TUMBLR_NAME, id: VUUKLE_TUMBL_APPSTORE_ID)
            decisionHandler(.cancel)
        } else   {
            decisionHandler(.allow)
        }
    }
    
    func openNewsWindow(withURL: String) {
        if withURL == VUUKLE_SOCIAL_LOGIN_GOOGLE {
            configuration.applicationNameForUserAgent = VUUKLE_GOOGLE_CONFIG
        }
        
        if let newsWindow = storyboard?.instantiateViewController(withIdentifier: VuukleNewViewController.id) as?  VuukleNewViewController {
            newsWindow.wkWebView = self.wkWebViewWithScript
            newsWindow.configuration = self.configuration
            newsWindow.urlString = withURL
            self.navigationController?.pushViewController(newsWindow, animated: true)
        }
    }
    
    // open social networks on a web page, not in an application
    // witout passing webView conffigurations
    func openWebSocialSharePage(withURL: String) {
        isFromNewViewController = false
        var urlString = withURL
        if urlString == VUUKLE_SOCIAL_LOGIN_GOOGLE {
            configuration.applicationNameForUserAgent = VUUKLE_GOOGLE_CONFIG
        }
        
        if withURL.hasSuffix("%2F") {
            urlString = String(withURL.dropLast(3))
        }
        
        if let newsWindow = storyboard?.instantiateViewController(withIdentifier: WuukleWebSocialPageViewController.id) as?  WuukleWebSocialPageViewController {
            newsWindow.urlString = urlString
            self.navigationController?.pushViewController(newsWindow, animated: true)
        }
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

extension ViewController: WKNavigationDelegate,  WKUIDelegate {
    // MARK: - WKNavigationDelegate methods
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        wkWebViewWithScript.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
        })
        
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                if webView == self.wkWebViewWithScript {
                    self.stopActivityIndicator()
                }
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
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let ac = UIAlertController(title: nil, message: "\(message)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            completionHandler(true)
        }
        
        ac.addAction(cancelAction)
        ac.addAction(okAction)
        present(ac, animated: true, completion: nil)
        
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {

        webView.load(navigationAction.request)

        webView.evaluateJavaScript("window.open = function(open) { return function (url, name, features) { window.location.href = url; return window; }; } (window.open);", completionHandler: nil)
        
        webView.evaluateJavaScript("window.close = function() { window.location.href = 'myapp://closewebview'; }", completionHandler: nil)
        
        return nil
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {

        let navigationURLString = navigationAction.request.url?.absoluteString ?? ""
        
        if navigationURLString.hasPrefix(VUUKLE_MAIL_TO_SHARE) || navigationURLString.hasPrefix(VUUKLE_MAIL_SHARE) {
            let mailSubjectBody = parsMailSubjextAndBody(mailto: navigationURLString)
            sendEmail(subject: mailSubjectBody.subject, body: mailSubjectBody.body)
            decisionHandler(.allow)
        } else if navigationURLString.hasPrefix(VUUKLE_SOCIAL_LOGIN) ||
            navigationURLString.hasPrefix(VUUKLE_NEWS_BASE_URL) {
            openNewWindow(newURL: navigationURLString)
            decisionHandler(.cancel)
        } else if (navigationURLString == VUUKLE_BASE) ||
                    navigationURLString.hasPrefix(VUUKLE_STATS_URL) || navigationURLString.hasPrefix(VUUKLE_PRIVACY)  {
            openWebSocialSharePage(withURL: navigationURLString)
            decisionHandler(.cancel)
        } else {
            openApllicationForShare(navigationURLString: navigationURLString, decisionHandler: decisionHandler)
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        completionHandler(.performDefaultHandling, nil)
    }
    
    func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        
        decisionHandler(true)
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        conteinerWKWebViewWithScriptHeightConstraint.constant = wkWebViewWithScript.scrollView.contentOffset.y
        wkWebViewWithScript.setNeedsLayout()
    }
}
