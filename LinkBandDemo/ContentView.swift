//
//  ContentView.swift
//  LinkBandDemo
//
//  
//  LinkBand 디바이스와의 Bluetooth 연결 및 센서 데이터 수집을 위한 메인 UI 화면
//  BluetoothKitViewModel을 통해 디바이스 관리와 데이터 수집 기능을 제공합니다.
//

import Foundation
import SwiftUI
import CoreBluetooth
import UniformTypeIdentifiers

/// LinkBand 디바이스 제어 및 센서 데이터 모니터링을 위한 메인 뷰
/// 연결 상태에 따라 적응형 UI를 제공하며, 실시간 센서 데이터 표시와 배치 데이터 수집 기능을 포함합니다.
struct ContentView: View {
    /// Bluetooth 디바이스 연결과 센서 데이터 관리를 담당하는 ViewModel
    @StateObject private var bluetoothKitViewModel = BluetoothKitViewModel()
    /// 기록된 파일 목록 화면 표시 상태
    @State private var showingRecordedFiles = false

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 20) {
                    // 디바이스 연결 상태 카드
                    statusCardSection
                    
                    // 연결된 경우에만 표시되는 센서 데이터 및 제어 섹션
                    if bluetoothKitViewModel.isConnected {
                        connectedContentSections
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filesButton
                }
            }
            // Bluetooth 비활성화 알림
            .alert("Bluetooth가 꺼져 있습니다", isPresented: $bluetoothKitViewModel.isBluetoothDisabled) {
                Button("설정", action: openBluetoothSettings)
                Button("닫기", role: .cancel) { }
            } message: {
                Text("센서 디바이스를 스캔하고 연결하려면 Bluetooth를 켜주세요.")
            }
            // 기록된 파일 목록 화면
            .sheet(isPresented: $showingRecordedFiles) {
                RecordedFilesView(bluetoothKit: bluetoothKitViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // iPad에서도 일관된 스타일 유지
    }
    
    // MARK: - View Components
    
    /// 디바이스 연결 상태와 기본 제어를 표시하는 상태 카드 섹션
    private var statusCardSection: some View {
        EnhancedStatusCardView(bluetoothKit: bluetoothKitViewModel)
            .frame(maxWidth: .infinity)
    }
    
    /// 디바이스 연결 시 표시되는 센서 데이터 및 제어 섹션들
    @ViewBuilder
    private var connectedContentSections: some View {
        // 실시간 센서 데이터 표시
        SensorDataView(bluetoothKit: bluetoothKitViewModel)
            .frame(maxWidth: .infinity)
        
        // 배치 데이터 수집 설정 및 제어
        SimplifiedBatchDataCollectionView(bluetoothKit: bluetoothKitViewModel)
            .frame(maxWidth: .infinity)
        
        // 디바이스 제어 (모드 변경 등)
        ControlsView(bluetoothKit: bluetoothKitViewModel)
            .frame(maxWidth: .infinity)
    }
    
    /// 기록된 파일 목록을 여는 툴바 버튼
    private var filesButton: some View {
        Button(action: { showingRecordedFiles = true }) {
            Image(systemName: "folder.fill")
                .font(.title3)
        }
    }
    
    // MARK: - Computed Properties
    
    /// 연결 및 스캔 상태에 따른 동적 네비게이션 타이틀
    private var navigationTitle: String {
        switch (bluetoothKitViewModel.isConnected, bluetoothKitViewModel.isScanning) {
        case (true, _): return "LinkBand 데이터"
        case (false, true): return "스캔 중..."
        case (false, false): return "LinkBand 블루투스 스캐너"
        }
    }
    
    // MARK: - Private Methods
    
    /// iOS 설정 앱의 Bluetooth 페이지를 열어주는 메서드
    private func openBluetoothSettings() {
        guard let settingsUrl = URL(string: "App-Prefs:Bluetooth") else { return }
        UIApplication.shared.open(settingsUrl)
    }
}

#Preview {
    ContentView()
}
