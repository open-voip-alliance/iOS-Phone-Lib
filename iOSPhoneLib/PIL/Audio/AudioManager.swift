//
// Created by Jeremy Norman on 15/02/2021.
//

import Foundation
import AVFoundation
import AVKit

public class AudioManager {
    
    private let voipLib: VoIPLib
    private let audioSession: AVAudioSession
    private let pil: PIL
    private let callActions: CallActions
    
    let dtmf: DtmfPlayer
    
    private lazy var routePickerView: AVRoutePickerView = {
        let routePickerView = AVRoutePickerView()
        routePickerView.isHidden = true
        return routePickerView
    }()
    
    init(pil: PIL, voipLib: VoIPLib, audioSession: AVAudioSession, dtmfPlayer: DtmfPlayer, callActions: CallActions) {
        self.pil = pil
        self.voipLib = voipLib
        self.audioSession = audioSession
        self.dtmf = dtmfPlayer
        self.callActions = callActions
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    public var isMicrophoneMuted: Bool {
        get {
            pil.writeLog("IS MICROPHONE MUTED: \(voipLib.isMicrophoneMuted)")
            return voipLib.isMicrophoneMuted
        }
    }
    
    public var state: AudioState {
        get {
            guard let availableInputs = audioSession.availableInputs else {
                return AudioState(currentRoute: .phone, availableRoutes: [.phone, .speaker], bluetoothDeviceName: nil, isMicrophoneMuted: isMicrophoneMuted)
            }
            
            var routes: [AudioRoute] = [.speaker]
            
            if hasBluetooth() {
                routes.append(.bluetooth)
            }
            
            if hasPhone() {
                routes.append(.phone)
            }
            
            var currentRoute: AudioRoute = .phone
            
            if (!audioSession.currentRoute.outputs.filter({$0.portType == .builtInSpeaker}).isEmpty) {
                currentRoute = .speaker
            }
            
            if (!audioSession.currentRoute.outputs.filter({$0.portType == .bluetoothHFP || $0.portType == .headsetMic}).isEmpty) {
                currentRoute = .bluetooth
            }
            
            return AudioState(currentRoute: currentRoute, availableRoutes: routes, bluetoothDeviceName: findBluetoothName(), isMicrophoneMuted: isMicrophoneMuted)
        }
    }
    
    public func routeAudio(_ route: AudioRoute) {
        guard let availableInputs = audioSession.availableInputs else {
            return
        }
        
        do {
            if route == .phone {
                try audioSession.overrideOutputAudioPort(.none)
            }
            
            if route == .speaker {
                try audioSession.overrideOutputAudioPort(.speaker)
            }
            
            if route == .bluetooth {
                try audioSession.overrideOutputAudioPort(.none)
                var input = availableInputs.filter({$0.portType == .bluetoothHFP}).first
                
                if input == nil {
                    input = availableInputs.filter({$0.portType == .headsetMic}).first
                }
                
                try audioSession.setPreferredInput(input)
            }
            
            try audioSession.setActive(true)
        } catch {
            pil.writeLog("Audio routing failed: \(error.localizedDescription)")
        }        
    }
    
    /// Launch a native UI dialog box that allows the user to choose from a list of inputs.
    public func launchAudioRoutePicker() {
        do {
            try audioSession.overrideOutputAudioPort(.none)
            
            if let routePickerButton = routePickerView.subviews.first(where: { $0 is UIButton }) as? UIButton {
                routePickerButton.sendActions(for: .touchUpInside)
            }
        } catch {
            pil.writeLog("Unable to launch audio route picker")
        }
    }
    
    func onActivateAudioSession() {
        do {
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .duckOthers])
            try audioSession.setActive(true, options: [.notifyOthersOnDeactivation])
        } catch {
            pil.writeLog("Unable to activate audio \(error.localizedDescription)")
        }
        
        routeToDefault()
    }
    
    func onDeactivateAudioSession() {
        do {
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            pil.writeLog("Unable to deactivate audio \(error.localizedDescription)")
        }
    }
    
    private func routeToDefault() {
        if hasBluetooth() {
            routeAudio(.bluetooth)
        } else {
            routeAudio(.phone)
        }
    }
    
    private func hasBluetooth() -> Bool {
        return isAvailable(port: .bluetoothHFP) || isAvailable(port: .headsetMic)
    }
    
    private func hasSpeaker() -> Bool {
        return isAvailable(port: .builtInSpeaker)
    }
    
    private func hasPhone() -> Bool {
        return isAvailable(port: .builtInMic)
    }
    
    private func findBluetoothName() -> String? {
        guard let availableInputs = audioSession.availableInputs else {
            return nil
        }
        
        var name: String? = availableInputs.filter({ $0.portType == .bluetoothHFP }).first?.portName
        
        if name == nil {
            name = availableInputs.filter({ $0.portType == .headsetMic }).first?.portName
        }
        
        return name
    }
    
    private func isAvailable(port: AVAudioSession.Port) -> Bool {
        guard let availableInputs = audioSession.availableInputs else {
            return false
        }
        
        return !availableInputs.filter({$0.portType == port}).isEmpty
    }
    
    public func mute() { callActions.mute() }
    
    public func unmute() { callActions.unmute() }
    
    public func toggleMute() { callActions.toggleMute() }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        if reason == .oldDeviceUnavailable || reason == .newDeviceAvailable {
            routeToDefault()
        }
        
        pil.events.broadcast(event: .audioStateUpdated(state: pil.sessionState))
    }
}
