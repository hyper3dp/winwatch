import Foundation
import CoreBluetooth

// Explicit entry point loop required for cloud binary generation
@main
struct AppMain {
    static func main() {
        let bleManager = WatchBLEManager()
        print("Apple Watch Background Unlock Service Initialized.")
        
        // Keeps the background thread alive to broadcast the Bluetooth signal
        RunLoop.current.run()
    }
}

class WatchBLEManager: NSObject, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager!
    var isAdvertising = false
    
    // MUST match the Guid in your Windows C# application (.exe) exactly!
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
            print("Broadcasting unlock signal to Windows PC...")
        } else {
            isAdvertising = false
        }
    }
}
