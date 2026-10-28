import SwiftUI
import WebKit
import SafariServices

@main
struct RetroTubeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

final class WebViewModel: ObservableObject {
    let webView: WKWebView

    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var progress = 0.0
    @Published var isLoading = false

    private var progressObservation: NSKeyValueObservation?
    private var backObservation: NSKeyValueObservation?
    private var forwardObservation: NSKeyValueObservation?
    private var loadingObservation: NSKeyValueObservation?

    init() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never

        progressObservation = webView.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.progress = view.estimatedProgress
            }
        }
        backObservation = webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.canGoBack = view.canGoBack
            }
        }
        forwardObservation = webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.canGoForward = view.canGoForward
            }
        }
        loadingObservation = webView.observe(\.isLoading, options: [.initial, .new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.isLoading = view.isLoading
            }
        }

        loadHome()
    }

    func loadHome() {
        guard let url = URL(string: "https://m.youtube.com/") else { return }
        webView.load(URLRequest(url: url))
    }

    func reload() {
        if isLoading {
            webView.stopLoading()
        } else {
            webView.reload()
        }
    }
}

struct ContentView: View {
    @StateObject private var model = WebViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.red)

                Text("RetroTube")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    model.reload()
                } label: {
                    Image(systemName: model.isLoading ? "xmark" : "arrow.clockwise")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(model.isLoading ? "Stop loading" : "Reload")
            }
            .padding(.horizontal, 14)
            .background(Color(red: 0.10, green: 0.10, blue: 0.11))

            if model.isLoading {
                ProgressView(value: model.progress)
                    .progressViewStyle(.linear)
                    .tint(.red)
                    .frame(height: 2)
            }

            WebView(webView: model.webView)
                .background(Color.black)

            HStack(spacing: 0) {
                toolbarButton("chevron.left", label: "Back", enabled: model.canGoBack) {
                    model.webView.goBack()
                }
                toolbarButton("chevron.right", label: "Forward", enabled: model.canGoForward) {
                    model.webView.goForward()
                }
                toolbarButton("house.fill", label: "Home", enabled: true) {
                    model.loadHome()
                }
                toolbarButton("safari", label: "Open in Safari", enabled: true) {
                    guard let url = model.webView.url else { return }
                    openURL(url)
                }
            }
            .padding(.vertical, 7)
            .background(Color(red: 0.10, green: 0.10, blue: 0.11))
        }
        .background(Color.black.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private func toolbarButton(
        _ symbol: String,
        label: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .medium))
                Text(label)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .disabled(!enabled)
        .foregroundColor(enabled ? .white : .gray)
        .accessibilityLabel(label)
    }
}

struct WebView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            let scheme = url.scheme?.lowercased() ?? ""
            if ["http", "https", "about", "blob", "data"].contains(scheme) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
