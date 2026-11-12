import AppKit
import WebKit

final class Fixture: NSObject, WKNavigationDelegate {
    private let view: WKWebView
    private var index = 0
    private let cases = [
        ("https://app.notion.com/library/private", true, true),
        ("https://app.notion.com/p/fixture", false, true),
        ("https://example.invalid/library/private", false, false),
    ]

    init(script: String) {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.userContentController.addUserScript(
            WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true, in: .defaultClient)
        )
        view = WKWebView(frame: NSRect(x: 0, y: 0, width: 800, height: 500), configuration: configuration)
        super.init()
        view.navigationDelegate = self
    }

    func load() {
        view.loadHTMLString("""
        <!doctype html><html lang="zh-CN"><meta charset="utf-8">
        <div role="tablist">
            <div role="tab" id="recents"><span>Recents</span></div>
            <div role="tab" id="favorites" title="Favorites">Favorites</div>
            <div role="tab" id="shared" aria-label="Shared">Shared</div>
            <div role="tab" id="private">Private</div>
            <div role="tab" id="custom">Add a property</div>
            <div role="tab" id="compound"><span>Favorites</span><span> settings</span></div>
        </div>
        <button id="property" aria-haspopup="dialog" aria-label="Add a property">
            <svg aria-hidden="true"><title>Add a property</title></svg><span>Add a property</span>
        </button>
        <section class="notion-page-content">
            <div data-block-id="fixture"><button id="document" aria-haspopup="dialog">Add a property</button></div>
            <div id="editable" contenteditable="true"><button aria-haspopup="dialog">Add a property</button></div>
        </section>
        <div id="title">Favorites</div>
        </html>
        """, baseURL: URL(string: cases[index].0)!)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("""
        const button = document.createElement('button');
        button.id = 'dynamic';
        button.setAttribute('aria-haspopup', 'dialog');
        button.textContent = 'Add a property';
        document.body.appendChild(button);
        void 0;
        """) { [self] _, error in
            if let error { print(error.localizedDescription); exit(1) }
            verify()
        }
    }

    private func verify() {
        let (url, inLibrary, inNotion) = cases[index]
        let recents = inLibrary ? "最近访问" : "Recents"
        let favorites = inLibrary ? "最爱" : "Favorites"
        let shared = inLibrary ? "共享" : "Shared"
        let personal = inLibrary ? "私人" : "Private"
        let add = inNotion ? "添加属性" : "Add a property"
        let expected = [url, recents, favorites, favorites, shared, shared, personal,
                        "Add a property", "Favorites settings", add, add, "Add a property",
                        "Add a property", "Add a property", "Favorites", add]
        view.evaluateJavaScript("""
        (() => {
            const text = selector => document.querySelector(selector).textContent.trim();
            const attribute = (selector, name) => document.querySelector(selector).getAttribute(name);
            return [location.href, text('#recents'), text('#favorites'), attribute('#favorites', 'title'),
                    text('#shared'), attribute('#shared', 'aria-label'), text('#private'), text('#custom'),
                    text('#compound'), text('#property span'), attribute('#property', 'aria-label'),
                    text('#property title'), text('#document'), text('#editable'), text('#title'), text('#dynamic')];
        })()
        """) { [self] value, error in
            guard error == nil, (value as? [String]) == expected else {
                print("FAIL", value ?? "nil", error?.localizedDescription ?? "", "expected", expected)
                exit(1)
            }
            print("PASS", url)
            index += 1
            if index == cases.count { exit(0) }
            load()
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.prohibited)
let script = try String(contentsOfFile: CommandLine.arguments[1], encoding: .utf8)
let fixture = Fixture(script: script)
fixture.load()
DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
    print("Timed out waiting for fixture")
    exit(1)
}
RunLoop.main.run()
