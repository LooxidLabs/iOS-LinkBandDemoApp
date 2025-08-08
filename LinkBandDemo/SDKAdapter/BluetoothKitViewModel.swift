import SwiftUI
import BluetoothKit
import Combine

// MARK: - Connection Status Text Configuration

/// 연결 상태별 표시 텍스트를 커스터마이징할 수 있는 구조체
public struct ConnectionStatusTexts {
    /// 연결 안됨 상태 텍스트
    public var disconnected: String
    /// 스캔 중 상태 텍스트
    public var scanning: String
    /// 연결 중 상태 텍스트 (디바이스 이름을 매개변수로 받음)
    public var connecting: (String) -> String
    /// 연결됨 상태 텍스트 (디바이스 이름을 매개변수로 받음)
    public var connected: (String) -> String
    /// 재연결 중 상태 텍스트 (디바이스 이름을 매개변수로 받음)
    public var reconnecting: (String) -> String
    /// 실패 상태 텍스트 (에러 메시지를 매개변수로 받음)
    public var failed: (String) -> String
    
    /// 새로운 ConnectionStatusTexts 인스턴스를 생성합니다.
    public init(
        disconnected: String,
        scanning: String,
        connecting: @escaping (String) -> String,
        connected: @escaping (String) -> String,
        reconnecting: @escaping (String) -> String,
        failed: @escaping (String) -> String
    ) {
        self.disconnected = disconnected
        self.scanning = scanning
        self.connecting = connecting
        self.connected = connected
        self.reconnecting = reconnecting
        self.failed = failed
    }
    
    /// 기본 한국어 텍스트를 반환하는 정적 메서드
    public static func defaultKorean() -> ConnectionStatusTexts {
        return ConnectionStatusTexts(
            disconnected: "연결 안됨",
            scanning: "스캔 중...",
            connecting: { "\($0)에 연결 중..." },
            connected: { "\($0)에 연결됨" },
            reconnecting: { "\($0)에 재연결 중..." },
            failed: { "실패: \($0)" }
        )
    }
}

// MARK: - SDK 변환 확장 (internal 사용)

/// EEGData와 SDK EEGReading 간의 변환을 담당하는 내부 확장
internal extension EEGData {
    /// SDK의 EEGReading을 EEGData로 변환하는 이니셜라이저
    /// - Parameter reading: 변환할 SDK EEGReading 객체
    init(from reading: EEGReading) {
        self.init(
            channel1: reading.channel1,
            channel2: reading.channel2,
            ch1Raw: Int(reading.ch1Raw),
            ch2Raw: Int(reading.ch2Raw),
            leadOff: reading.leadOff,
            timestamp: reading.timestamp
        )
    }
}

/// PPGData와 SDK PPGReading 간의 변환을 담당하는 내부 확장
internal extension PPGData {
    /// SDK의 PPGReading을 PPGData로 변환하는 이니셜라이저
    /// - Parameter reading: 변환할 SDK PPGReading 객체
    init(from reading: PPGReading) {
        self.init(
            red: Int(reading.red),
            ir: Int(reading.ir),
            timestamp: reading.timestamp
        )
    }
}

/// AccelerometerData와 SDK AccelerometerReading 간의 변환을 담당하는 내부 확장
internal extension AccelerometerData {
    /// SDK의 AccelerometerReading을 AccelerometerData로 변환하는 이니셜라이저
    /// - Parameter reading: 변환할 SDK AccelerometerReading 객체
    init(from reading: AccelerometerReading) {
        self.init(
            x: Int(reading.x),
            y: Int(reading.y),
            z: Int(reading.z),
            timestamp: reading.timestamp
        )
    }
}

/// BatteryData와 SDK BatteryReading 간의 변환을 담당하는 내부 확장
internal extension BatteryData {
    /// SDK의 BatteryReading을 BatteryData로 변환하는 이니셜라이저
    /// - Parameter reading: 변환할 SDK BatteryReading 객체
    init(from reading: BatteryReading) {
        self.init(
            level: Int(reading.level),
            timestamp: reading.timestamp
        )
    }
}

/// DeviceInfo와 SDK BluetoothDevice 간의 변환을 담당하는 내부 확장
internal extension DeviceInfo {
    /// SDK의 BluetoothDevice를 DeviceInfo로 변환하는 이니셜라이저
    /// - Parameter device: 변환할 SDK BluetoothDevice 객체
    /// - Note: 현재는 임시 UUID를 생성하며, SDK에서 proper identifier 제공이 필요합니다.
    init(from device: BluetoothDevice) {
        // peripheral.identifier에 접근할 수 없으므로 name을 UUID로 사용
        // 실제로는 BluetoothKit에서 proper UUID를 제공해야 함
        self.init(
            id: UUID(), // 임시 UUID 생성 - SDK에서 proper identifier 제공 필요
            name: device.name
        )
    }
}

/// SensorKind와 SDK SensorType 간의 변환을 담당하는 내부 확장
internal extension SensorKind {
    /// SensorKind를 SDK SensorType으로 변환하는 계산 프로퍼티
    var sdkType: SensorType {
        switch self {
        case .eeg: return .eeg
        case .ppg: return .ppg
        case .accelerometer: return .accelerometer
        case .battery: return .battery
        }
    }
    
    /// SDK SensorType을 SensorKind로 변환하는 정적 메서드
    /// - Parameter sdkType: 변환할 SDK SensorType
    /// - Returns: 해당하는 SensorKind 값
    static func from(_ sdkType: SensorType) -> SensorKind {
        switch sdkType {
        case .eeg: return .eeg
        case .ppg: return .ppg
        case .accelerometer: return .accelerometer
        case .battery: return .battery
        }
    }
}

/// DeviceConnectionState와 SDK ConnectionState 간의 변환을 담당하는 내부 확장
internal extension DeviceConnectionState {
    /// DeviceConnectionState를 SDK ConnectionState로 변환하는 계산 프로퍼티
    var sdkState: ConnectionState {
        switch self {
        case .disconnected: return .disconnected
        case .scanning: return .scanning
        case .connecting: return .connecting("Unknown Device")
        case .connected: return .connected("Unknown Device")
        case .reconnecting: return .reconnecting("Unknown Device")
        case .failed: return .failed(NSError(domain: "AdapterError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
        }
    }
    
    /// SDK ConnectionState를 DeviceConnectionState로 변환하는 정적 메서드
    /// - Parameter sdkState: 변환할 SDK ConnectionState
    /// - Returns: 해당하는 DeviceConnectionState 값
    static func from(_ sdkState: ConnectionState) -> DeviceConnectionState {
        switch sdkState {
        case .disconnected: return .disconnected
        case .scanning: return .scanning
        case .connecting(_): return .connecting
        case .connected(_): return .connected
        case .reconnecting(_): return .reconnecting
        case .failed(_): return .failed
        }
    }
}

/// AccelMode와 SDK AccelerometerMode 간의 변환을 담당하는 내부 확장
internal extension AccelMode {
    /// AccelMode를 SDK AccelerometerMode로 변환하는 계산 프로퍼티
    var sdkMode: AccelerometerMode {
        switch self {
        case .raw: return .raw
        case .motion: return .motion
        }
    }
    
    /// SDK AccelerometerMode를 AccelMode로 변환하는 정적 메서드
    /// - Parameter sdkMode: 변환할 SDK AccelerometerMode
    /// - Returns: 해당하는 AccelMode 값
    static func from(_ sdkMode: AccelerometerMode) -> AccelMode {
        switch sdkMode {
        case .raw: return .raw
        case .motion: return .motion
        }
    }
}

/// CollectionModeKind와 SDK BatchDataConfigurationManager.CollectionMode 간의 변환을 담당하는 내부 확장
internal extension CollectionModeKind {
    /// CollectionModeKind를 SDK CollectionMode로 변환하는 계산 프로퍼티
    var sdkMode: BatchDataConfigurationManager.CollectionMode {
        switch self {
        case .sampleCount: return .sampleCount
        case .seconds: return .seconds
        case .minutes: return .minutes
        }
    }
    
    /// SDK CollectionMode를 CollectionModeKind로 변환하는 정적 메서드
    /// - Parameter sdkMode: 변환할 SDK CollectionMode
    /// - Returns: 해당하는 CollectionModeKind 값
    static func from(_ sdkMode: BatchDataConfigurationManager.CollectionMode) -> CollectionModeKind {
        switch sdkMode {
        case .sampleCount: return .sampleCount
        case .seconds: return .seconds
        case .minutes: return .minutes
        }
    }
}

/// BluetoothKit SDK를 SwiftUI에서 사용할 수 있도록 래핑하는 ViewModel
/// 기존 UI/UX를 그대로 유지하면서 순수 비즈니스 로직과 UI를 분리합니다.
@MainActor
class BluetoothKitViewModel: ObservableObject, BluetoothKitDelegate {
    
    // MARK: - Published Properties (UI 바인딩용)
    
    /// 스캔 중 발견된 Bluetooth 디바이스 목록
    @Published public var scannedDevices: [DeviceInfo] = []
    
    /// 현재 연결 상태의 사용자 친화적인 설명
    @Published public var connectionStatusDescription: String = "연결 안됨"
    
    // MARK: - Connection Status Text Customization
    
    /// 연결 상태별 표시 텍스트 설정
    /// 
    /// 이 프로퍼티를 수정하여 연결 상태 텍스트를 다른 언어나 스타일로 커스터마이징할 수 있습니다.
    ///
    /// ## 예시
    /// ```swift
    /// // 영어로 변경
    /// viewModel.connectionStatusTexts = ConnectionStatusTexts(
    ///     disconnected: "Disconnected",
    ///     scanning: "Scanning...",
    ///     connecting: { "Connecting to \($0)..." },
    ///     connected: { "Connected to \($0)" },
    ///     reconnecting: { "Reconnecting to \($0)..." },
    ///     failed: { "Failed: \($0)" }
    /// )
    /// 
    /// // 중국어로 변경
    /// viewModel.connectionStatusTexts = ConnectionStatusTexts(
    ///     disconnected: "未连接",
    ///     scanning: "扫描中...",
    ///     connecting: { "正在连接 \($0)..." },
    ///     connected: { "已连接 \($0)" },
    ///     reconnecting: { "重新连接 \($0)..." },
    ///     failed: { "失败: \($0)" }
    /// )
    /// 
    /// // 커스텀 스타일
    /// viewModel.connectionStatusTexts = ConnectionStatusTexts(
    ///     disconnected: "🔌 연결 없음",
    ///     scanning: "🔍 디바이스 찾는 중...",
    ///     connecting: { "⚡ \($0) 연결 시도 중..." },
    ///     connected: { "✅ \($0) 연결 성공!" },
    ///     reconnecting: { "🔄 \($0) 재연결 중..." },
    ///     failed: { "❌ 오류: \($0)" }
    /// )
    /// ```
    @Published public var connectionStatusTexts: ConnectionStatusTexts = .defaultKorean() {
        didSet {
            updateConnectionStatusDescription()
        }
    }
    
    /// 라이브러리가 현재 디바이스를 스캔 중인지 여부
    @Published public var isScanning: Bool = false
    
    /// 데이터 기록이 현재 활성화되어 있는지 여부
    @Published public var isRecording: Bool = false
    
    /// auto-reconnection이 현재 활성화되어 있는지 여부
    @Published public var isAutoReconnectEnabled: Bool = true
    
    /// 가장 최근의 EEG (뇌전도) 읽기값
    @Published public var latestEEGReading: EEGData?
    
    /// 가장 최근의 PPG (광전 용적 맥파) 읽기값
    @Published public var latestPPGReading: PPGData?
    
    /// 가장 최근의 가속도계 읽기값
    @Published public var latestAccelerometerReading: AccelerometerData?
    
    /// 가장 최근의 배터리 레벨 읽기값
    @Published public var latestBatteryReading: BatteryData?
    
    /// 기록된 파일 목록
    @Published public var recordedFiles: [URL] = []
    
    /// Bluetooth가 비활성화되어 있는지 여부
    @Published public var isBluetoothDisabled: Bool = false
    
    /// 현재 연결 상태
    @Published public var connectionState: DeviceConnectionState = .disconnected {
        didSet {
            updateConnectionStatusDescription()
        }
    }
    
    /// 가속도계 모드 (원시값 vs 움직임)
    @Published public var accelerometerMode: AccelMode = .raw {
        didSet {
            // 값이 실제로 변경되었을 때만 SDK 인스턴스 업데이트
            guard oldValue != accelerometerMode else { return }
            bluetoothKit.accelerometerMode = accelerometerMode.sdkMode
        }
    }
    
    // MARK: - SDK Instance
    
    /// 실제 비즈니스 로직을 담당하는 BluetoothKit 인스턴스
    internal let bluetoothKit: BluetoothKit
    
    // MARK: - Private Properties
    
    /// SDK에서 받은 BluetoothDevice 객체들을 저장 (연결용)
    private var sdkDevices: [BluetoothDevice] = []
    
    // MARK: - Initialization
    
    /// 새로운 BluetoothKitViewModel 인스턴스를 생성합니다.
    public init() {
        self.bluetoothKit = BluetoothKit()
        
        // 델리게이트 설정
        bluetoothKit.delegate = self
        
        // 초기 상태 동기화
        syncInitialState()
    }
    
    // MARK: - Public Interface (SDK 메서드들을 래핑)
    
    /// Bluetooth 디바이스 스캔을 시작합니다.
    public func startScan() {
        try? bluetoothKit.startScan()
    }
    
    /// Bluetooth 디바이스 스캔을 중지합니다.
    public func stopScan() {
        try? bluetoothKit.stopScan()
    }
    
    /// 특정 Bluetooth 디바이스에 연결합니다.
    public func connect(to device: DeviceInfo) {
        // DeviceInfo에 해당하는 SDK BluetoothDevice를 찾아서 연결
        if let sdkDevice = sdkDevices.first(where: { $0.name == device.name }) {
            try? bluetoothKit.connect(to: sdkDevice)
        }
    }
    
    /// 현재 연결된 디바이스에서 연결을 해제합니다.
    public func disconnect() {
        try? bluetoothKit.disconnect()
    }
    
    /// 센서 데이터를 파일로 기록하기 시작합니다.
    public func startRecording() {
        try? bluetoothKit.startRecording()
    }
    
    /// 센서 데이터 기록을 중지합니다.
    public func stopRecording() {
        try? bluetoothKit.stopRecording()
    }
    
    /// 현재 디바이스에 연결되어 있는지 확인합니다.
    /// - Returns: 연결 상태 (true: 연결됨, false: 연결되지 않음)
    public var isConnected: Bool {
        return bluetoothKit.isConnected
    }
    
    /// 자동 재연결 기능을 설정합니다.
    /// - Parameter enabled: 자동 재연결 활성화 여부
    public func setAutoReconnect(enabled: Bool) {
        try? bluetoothKit.setAutoReconnect(enabled: enabled)
    }
    
    /// 기록이 저장되는 디렉토리를 가져옵니다.
    /// - Returns: 기록 파일들이 저장되는 URL 경로
    public var recordingsDirectory: URL {
        return bluetoothKit.recordingsDirectory
    }
    
    // MARK: - BatchDataConfigurationViewModel Factory
    
    /// BatchDataConfigurationViewModel을 생성합니다 (SDK 인스턴스 직접 노출 없이)
    /// - Returns: 새로운 BatchDataConfigurationViewModel 인스턴스
    /// - Note: 팩토리 패턴을 사용하여 SDK 인스턴스를 안전하게 전달합니다.
    public func createBatchDataConfigurationViewModel() -> BatchDataConfigurationViewModel {
        return BatchDataConfigurationViewModel(bluetoothKit: bluetoothKit)
    }
    
    // MARK: - Private Methods
    
    /// SDK의 초기 상태를 ViewModel에 동기화합니다.
    private func syncInitialState() {
        // 초기값들을 SDK에서 가져와서 설정
        // scannedDevices는 delegate를 통해 업데이트되므로 여기서 설정하지 않음
        isScanning = bluetoothKit.isScanning
        isRecording = bluetoothKit.isRecording
        isAutoReconnectEnabled = bluetoothKit.isAutoReconnectEnabled
        latestEEGReading = bluetoothKit.latestEEGReading.map { EEGData(from: $0) }
        latestPPGReading = bluetoothKit.latestPPGReading.map { PPGData(from: $0) }
        latestAccelerometerReading = bluetoothKit.latestAccelerometerReading.map { AccelerometerData(from: $0) }
        latestBatteryReading = bluetoothKit.latestBatteryReading.map { BatteryData(from: $0) }
        recordedFiles = bluetoothKit.recordedFiles
        isBluetoothDisabled = bluetoothKit.isBluetoothDisabled
        connectionState = DeviceConnectionState.from(bluetoothKit.connectionState)
        accelerometerMode = AccelMode.from(bluetoothKit.accelerometerMode)
        
        // 연결 상태 텍스트는 커스터마이징된 설정을 사용
        updateConnectionStatusDescription()
    }
    
    /// 연결 상태 텍스트를 업데이트합니다.
    private func updateConnectionStatusDescription() {
        connectionStatusDescription = formatConnectionStatus(connectionState)
    }
    
    /// 연결 상태를 사용자 친화적인 텍스트로 변환합니다.
    private func formatConnectionStatus(_ state: DeviceConnectionState) -> String {
        // SDK의 원본 ConnectionState에서 디바이스 이름과 에러 정보 추출
        let sdkState = bluetoothKit.connectionState
        
        switch state {
        case .disconnected:
            return connectionStatusTexts.disconnected
        case .scanning:
            return connectionStatusTexts.scanning
        case .connecting:
            let deviceName = extractDeviceName(from: sdkState) ?? "디바이스"
            return connectionStatusTexts.connecting(deviceName)
        case .connected:
            let deviceName = extractDeviceName(from: sdkState) ?? "디바이스"
            return connectionStatusTexts.connected(deviceName)
        case .reconnecting:
            let deviceName = extractDeviceName(from: sdkState) ?? "디바이스"
            return connectionStatusTexts.reconnecting(deviceName)
        case .failed:
            let errorMessage = extractErrorMessage(from: sdkState) ?? "연결 오류"
            return connectionStatusTexts.failed(errorMessage)
        }
    }
    
    /// SDK ConnectionState에서 디바이스 이름을 추출합니다.
    private func extractDeviceName(from state: ConnectionState) -> String? {
        switch state {
        case .connecting(let deviceName):
            return deviceName
        case .connected(let deviceName):
            return deviceName
        case .reconnecting(let deviceName):
            return deviceName
        default:
            return nil
        }
    }
    
    /// SDK ConnectionState에서 에러 메시지를 추출합니다.
    private func extractErrorMessage(from state: ConnectionState) -> String? {
        switch state {
        case .failed(let error):
            return error.localizedDescription
        default:
            return nil
        }
    }
}

// MARK: - BluetoothKitDelegate Implementation

extension BluetoothKitViewModel {
    
    /// 디바이스가 발견되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didDiscoverDevice device: BluetoothDevice) {
        // 개별 디바이스 발견은 didUpdateDevices에서 처리됨
    }
    
    /// 디바이스 목록이 업데이트되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateDevices devices: [BluetoothDevice]) {
        scannedDevices = devices.map { DeviceInfo(from: $0) }
        sdkDevices = devices // SDK 디바이스 저장
    }
    
    /// 연결 상태가 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateConnectionStatus status: String) {
        // SDK에서 제공하는 텍스트는 무시하고, 커스터마이징된 텍스트 사용
        // connectionState 변경 시 자동으로 updateConnectionStatusDescription()이 호출됨
    }
    
    /// 스캔 상태가 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateScanningState isScanning: Bool) {
        self.isScanning = isScanning
    }
    
    /// 기록 상태가 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateRecordingState isRecording: Bool) {
        self.isRecording = isRecording
    }
    
    /// 자동 재연결 설정이 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateAutoReconnectState isEnabled: Bool) {
        self.isAutoReconnectEnabled = isEnabled
    }
    
    /// EEG 센서 데이터가 업데이트되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateEEGReading reading: EEGReading?) {
        latestEEGReading = reading.map { EEGData(from: $0) }
    }
    
    /// PPG 센서 데이터가 업데이트되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdatePPGReading reading: PPGReading?) {
        latestPPGReading = reading.map { PPGData(from: $0) }
    }
    
    /// 가속도계 센서 데이터가 업데이트되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateAccelerometerReading reading: AccelerometerReading?) {
        latestAccelerometerReading = reading.map { AccelerometerData(from: $0) }
    }
    
    /// 배터리 센서 데이터가 업데이트되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateBatteryReading reading: BatteryReading?) {
        latestBatteryReading = reading.map { BatteryData(from: $0) }
    }
    
    /// 기록된 파일 목록이 업데이트되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateRecordedFiles files: [URL]) {
        recordedFiles = files
    }
    
    /// Bluetooth 상태가 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateBluetoothDisabled isDisabled: Bool) {
        isBluetoothDisabled = isDisabled
    }
    
    /// 연결 상태가 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateConnectionState state: ConnectionState) {
        connectionState = DeviceConnectionState.from(state)
    }
    
    /// 가속도계 모드가 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateAccelerometerMode mode: AccelerometerMode) {
        // 값이 실제로 다를 때만 업데이트 (무한 루프 방지)
        let newMode = AccelMode.from(mode)
        guard accelerometerMode != newMode else { return }
        accelerometerMode = newMode
    }
    
    /// 배치 모니터링 상태가 변경되었을 때 호출
    func bluetoothKit(_ kit: BluetoothKit, didUpdateBatchMonitoringState isActive: Bool) {
        // BatchDataConfigurationViewModel이 있다면 상태 업데이트
        // 이는 런타임에 동적으로 처리됨
    }
} 
