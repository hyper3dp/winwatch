import SwiftUI
import WatchKit
import CoreBluetooth

@main
struct WatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var bleManager = WatchBLEManager()

    var body: some View {
        VVisualStack {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 40))
                .foregroundColor(.green)
            Text("PC Unlocker")
                .font(.headline)
            Text(bleManager.isAdvertising ? "Broadcasting..." : "Stopped")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

class WatchBLEManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    @Published var isAdvertising = false
    
    // MUST match the Guid in your C# .exe file exactly!
    let serviceUUID = CBUUID(string: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0") 
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let service = CBMutableService(type: serviceUUID, primary: true)
            peripheralManager.add(service)
            peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
            isAdvertising = true
        } else {
            isAdvertising = false
        }
    }
}
