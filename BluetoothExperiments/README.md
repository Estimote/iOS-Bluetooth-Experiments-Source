#  Notes

### Background mode tips
- https://wojciechkulik.pl/xamarin-ios/bluetooth-low-energy-background-mode-on-ios
- https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html
- Capturing Bluetooth events, macOS as proxy — https://developer.apple.com/videos/play/wwdc2019/901/ @28:30 and https://www.bluetooth.com/blog/a-new-way-to-debug-iosbluetooth-applications/
- "PacketLogger" tool in "Additional Xcode 11 tools": https://developer.apple.com/download/more/?=additional%20tools
- ...

### Caveats
- `CBCentralManagerScanOptionAllowDuplicatesKey` is ignored in background.
- Background execution is different when a phone is connected to USB port etc.
- Limit of 10 seconds for execution of your code in background.
- …
