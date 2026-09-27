import SwiftUI
import WatchConnectivity

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var status: String = "Not connected"

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        } else {
            status = "WCSession not supported"
        }
    }

    func sendUnlock() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["command": "unlock"], replyHandler: { reply in
                DispatchQueue.main.async {
                    self.status = "Reply: \(reply)"
                }
            }, errorHandler: { error in
                DispatchQueue.main.async {
                    self.status = "Send error: \(error.localizedDescription)"
                }
            })
        } else {
            DispatchQueue.main.async {
                self.status = "iPhone not reachable"
            }
        }
    }

    // MARK: - WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            if let e = error {
                self.status = "Activation error: \(e.localizedDescription)"
                return
            }
            self.status = (activationState == .activated) ? "Connected" : "Inactive"
        }
    }

    #if os(watchOS)
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.status = session.isReachable ? "Reachable" : "Not reachable"
        }
    }
    #endif
}

@main
struct WatchUnlockerApp: App {
    @StateObject private var sessionManager = WatchSessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var sessionManager: WatchSessionManager

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))

            Button(action: {
                sessionManager.sendUnlock()
            }) {
                Text("Unlock PC")
            }
            .buttonStyle(.borderedProminent)

            Text(sessionManager.status)
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
