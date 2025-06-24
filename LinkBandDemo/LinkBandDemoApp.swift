//
//  LinkBandDemoApp.swift
//  LinkBandDemo
//
//  
//  LooxidLabs LinkBand 디바이스와의 Bluetooth 연결 및 센서 데이터 수집을 시연하는 iOS 앱
//  BluetoothKit SDK를 사용하여 EEG, PPG, 가속도계, 배터리 데이터를 실시간으로 수집하고 
//  배치 데이터 수집 기능을 제공합니다.
//

import SwiftUI

/// LinkBand 데모 앱의 메인 진입점
/// SwiftUI의 App 프로토콜을 준수하여 앱의 생명주기와 기본 창 구성을 관리합니다.
@main
struct LinkBandDemoApp: App {
    /// 앱의 메인 화면 구성을 정의합니다.
    /// ContentView를 루트 뷰로 하는 단일 창 그룹으로 구성됩니다.
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
