//
//  LinphoneManager.swift
//  Pods-SpindleSIPFramework_Example
//
//  Created by Fabian Giger on 14/04/2020.
//

import Foundation
import linphonesw
import AVFoundation

typealias LinphoneCall = linphonesw.Call
public typealias RegistrationCallback = (RegistrationState) -> Void
typealias LinphoneLogLevel = linphonesw.LogLevel

class LinphoneManager: LoggingServiceDelegate {
   
    private(set) var config: VoIPLibConfig?
    var isInitialized: Bool {
        linphoneCore != nil
    }
    var isRegistered: Bool = false
    
    private var linphoneCore: Core!
    private lazy var stateManager: LinphoneStateManager = {
        LinphoneStateManager(manager: self)
    }()
    
    private lazy var registrationListener: RegistrationListener = {
        RegistrationListener(linphoneManager: self)
    }()
    
    private var proxyConfig: ProxyConfig!
    
    private var logging: LoggingService {
        LoggingService.Instance
    }
    
    private var factory: Factory {
        Factory.Instance
    }
    
    var sipRegistrationStatus: SipRegistrationStatus = SipRegistrationStatus.none
    
    var isMicrophoneMuted: Bool {
        return !linphoneCore.micEnabled
    }
    
    var isSpeakerOn: Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: { $0.portType == AVAudioSession.Port.builtInSpeaker })
    }
    
    var pil: PIL {
        get {
            return PIL.shared!
        }
    }
    
    private var ringbackPath: String {
        let ringbackFileName = "ringback"
                
        let customBundle = Bundle(for: Self.self)

        guard let resourceURL = customBundle.resourceURL?.appendingPathComponent("Resources.bundle") else { return "" }

        guard let resourceBundle = Bundle(url: resourceURL) else { return "" }

        guard let ringbackFileURL = resourceBundle.url( forResource: ringbackFileName , withExtension: "wav") else { return "" }
        
        return ringbackFileURL.path
    }
    
    func initialize(config: VoIPLibConfig) -> Bool {
        self.config = config

        if isInitialized {
            log("Linphone already init")
            return true
        }

        do {
            try startLinphone()
            return true
        } catch {
            log("Failed to start Linphone \(error.localizedDescription)")
            linphoneCore = nil
            return false
        }
    }
    
    private func startLinphone() throws {
        factory.enableLogCollection(state: LogCollectionState.Disabled)
        logging.addDelegate(delegate: self)
        logging.logLevel = LinphoneLogLevel.Warning
        linphoneCore = try factory.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
        linphoneCore.addDelegate(delegate: stateManager)
        try applyPreStartConfiguration(core: linphoneCore)
        try linphoneCore.start()
        applyPostStartConfiguration(core: linphoneCore)
        configureCodecs(core: linphoneCore)
    }

    private func applyPreStartConfiguration(core: Core) throws {
        if let transports = core.transports {
            transports.tlsPort = 0
            transports.udpPort = 0
            transports.tcpPort = 0
        }
        core.setUserAgent(name: config?.userAgent, version: nil)
        core.ringback = ringbackPath        
        core.pushNotificationEnabled = false
        core.callkitEnabled = false
        core.ipv6Enabled = false
        core.dnsSrvEnabled = false
        core.dnsSearchEnabled = false
        core.maxCalls = 2
        core.uploadBandwidth = 0
        core.downloadBandwidth = 0
        core.mtu = 1300
        core.guessHostname = true
        core.incTimeout = 60
        core.audioPort = -1
        core.nortpTimeout = 30
        core.avpfMode = AVPFMode.Disabled
        if let stun = config?.stun {
            core.stunServer = stun
        }
        if let natPolicy = core.natPolicy {
            natPolicy.stunEnabled = config?.stun != nil
            natPolicy.upnpEnabled = false
            natPolicy.stunServer = config?.stun ?? ""
            natPolicy.resolveStunServer()
            core.natPolicy = natPolicy
        }
        core.audioJittcomp = 100

        if let transports = linphoneCore.transports {
            transports.tlsPort = -1
            transports.udpPort = 0
            transports.tcpPort = 0
            try linphoneCore.setTransports(newValue: transports)
        }

        try linphoneCore.setMediaencryption(newValue: MediaEncryption.SRTP)
        linphoneCore.mediaEncryptionMandatory = true
    }
    
    func applyPostStartConfiguration(core: Core) {
        core.useInfoForDtmf = true
        core.useRfc2833ForDtmf = true
        core.adaptiveRateControlEnabled = true
        core.echoCancellationEnabled = true
    }
    
    fileprivate func log(_ message: String) {
        logging.message(message: message)
    }
    
    func swapConfig(config: VoIPLibConfig) {
        self.config = config
    }

    internal var registrationCallback: RegistrationCallback? = nil
    
    func register(callback: @escaping RegistrationCallback) {
        do {
            guard let auth = pil.auth else {
                throw InitializationError.noConfigurationProvided
            }

            linphoneCore.removeDelegate(delegate: self.registrationListener)
            linphoneCore.addDelegate(delegate: self.registrationListener)

            self.registrationCallback = callback

            if (!linphoneCore.accountList.isEmpty) {
                log("SIP account not found, re-registering")
                linphoneCore.refreshRegisters()
                return
            }
            
            log("No SIP account found, registering for the first time.")

            let account = try createAccount(core: linphoneCore, auth: auth)
            try linphoneCore.addAccount(account: account)
            try linphoneCore.addAuthInfo(info: createAuthInfo(auth: auth))
            linphoneCore.defaultAccount = account
        } catch (let error) {
            log("Linphone registration failed: \(error)")
            callback(.failed)
        }
    }

    private func createAuthInfo(auth: Auth) throws -> AuthInfo {
        return try factory.createAuthInfo(
            username: auth.username,
            userid: auth.username,
            passwd: auth.password,
            ha1: "",
            realm: "",
            domain: auth.domain
        )
    }

    private func createAccount(core: Core, auth: Auth) throws -> Account {
        let params = try core.createAccountParams()
        try params.setIdentityaddress(newValue: core.interpretUrl(url: "sip:\(auth.username)@\(auth.domain):\(auth.port)")!)
        params.registerEnabled = true
        try params.setServeraddress(newValue: core.interpretUrl(url: "sip:\(auth.domain);transport=tls")!)
        return try linphoneCore.createAccount(params: params)
    }
    
    func unregister() {
        linphoneCore.clearAccounts()
        linphoneCore.clearAllAuthInfo()
        log("Unregister complete")
    }

    func destroy() {
        unregister()
        linphoneCore.removeDelegate(delegate: stateManager)
        linphoneCore.stop()
        log("Linphone destroyed")
        linphoneCore = nil
        isRegistered = false
    }
    
    func terminateAllCalls() {
        do {
           try linphoneCore.terminateAllCalls()
        } catch {
            
        }
    }
    
    func call(to number: String) -> VoIPLibCall? {
        guard let linphoneCall = linphoneCore.invite(url: number) else {return nil}
        let VoIPLibCall = VoIPLibCall.init(linphoneCall: linphoneCall)
        return isInitialized ? VoIPLibCall : nil
    }
    
    func acceptVoIPLibCall(for call: VoIPLibCall) -> Bool {
        do {
            try call.linphoneCall.accept()
            return true
        } catch {
            return false
        }
    }
    
    func endVoIPLibCall(for call: VoIPLibCall) -> Bool {
        do {
            try call.linphoneCall.terminate()
            return true
        } catch {
            return false
        }
    }
    
    private func configureCodecs(core: Core) {
        guard let codecs = config?.codecs else {
            return
        }
        
        linphoneCore?.videoPayloadTypes.forEach { payload in
            _ = payload.enable(enabled: false)
        }
        
        linphoneCore?.audioPayloadTypes.forEach { payload in
            let enable = !codecs.filter { selectedCodec in
                selectedCodec.rawValue.uppercased() == payload.mimeType.uppercased()
            }.isEmpty
            
            _ = payload.enable(enabled: enable)
        }
        
        guard let enabled = linphoneCore?.audioPayloadTypes.filter({ payload in payload.enabled() }).map({ payload in payload.mimeType }).joined(separator: ", ") else {
            log("Unable to log codecs, no core")
            return
        }
        
        log("Enabled codecs: \(enabled)")
    }

    
    func setMicrophone(muted: Bool) {
        linphoneCore.micEnabled = !muted
    }
    
    func setAudio(enabled:Bool) {
        log("Linphone set audio: \(enabled)")
        linphoneCore.activateAudioSession(actived: enabled)
    }
    
    func setHold(call: VoIPLibCall, onHold hold:Bool) -> Bool {
        do {
            if hold {
                log("Pausing VoIPLibCall.")
                try call.pause()
            } else {
                log("Resuming VoIPLibCall.")
                try call.resume()
            }
            return true
        } catch {
            return false
        }
    }
    
    func transfer(call: VoIPLibCall, to number: String) -> Bool {
        do {
            try call.linphoneCall.transfer(referTo: number)
            log("Transfer was successful")
            return true
        } catch (let error) {
            log("Transfer failed: \(error)")
            return false
        }
    }
    
    func beginAttendedTransfer(call: VoIPLibCall, to number:String) -> AttendedTransferSession? {
        guard let destinationVoIPLibCall = self.call(to: number) else {
            log("Unable to make VoIPLibCall for target VoIPLibCall")
            return nil
        }
        
        return AttendedTransferSession(from: call, to: destinationVoIPLibCall)
    }
    
    func finishAttendedTransfer(attendedTransferSession: AttendedTransferSession) -> Bool {
        do {
            try attendedTransferSession.from.linphoneCall.transferToAnother(dest: attendedTransferSession.to.linphoneCall)
            log("Transfer was successful")
            return true
        } catch (let error) {
            log("Transfer failed: \(error)")
            return false
        }
    }
    
    func sendDtmf(call: VoIPLibCall, dtmf: String) {
        do {
            try call.linphoneCall.sendDtmfs(dtmfs: dtmf)
        } catch (let error) {
            log("Sending dtmf failed: \(error)")
            return
        }
    }
    
    /// Provide human readable VoIPLibCall info
    ///
    /// - Parameter VoIPLibCall: the VoIPLibCall object
    /// - Returns: a String with all VoIPLibCall info
    func provideCallInfo(call: VoIPLibCall) -> String {
        let VoIPLibCallInfoProvider = VoIPLibCallInfoProvider(VoIPLibCall: call)
        return VoIPLibCallInfoProvider.provideVoIPLibCallInfo()
    }
    
    func onLogMessageWritten(logService: LoggingService, domain: String, level: LogLevel, message: String) {
        config?.logListener(message)
    }
}

class LinphoneStateManager:CoreDelegate {
    
    private let headersToPreserve = ["Remote-Party-ID", "P-Asserted-Identity"]
    
    let linphoneManager:LinphoneManager
    
    init(manager:LinphoneManager) {
        linphoneManager = manager
    }
    
    func onCallStateChanged(core: Core, call: LinphoneCall, state: LinphoneCall.State, message: String) {
        linphoneManager.log("OnVoIPLibCallStateChanged, state:\(state) with message:\(message).")

        guard let voipLibCall = VoIPLibCall(linphoneCall: call) else {
            linphoneManager.log("Unable to create VoIPLibCall, no remote address")
            return
        }

        guard let delegate = self.linphoneManager.config?.callDelegate else {
            linphoneManager.log("Unable to send events as no VoIPLibCall delegate")
            return
        }

        DispatchQueue.main.async {
            switch state {
                case .OutgoingInit:
                    delegate.outgoingCallCreated(voipLibCall)
                case .IncomingReceived:
                    self.preserveHeaders(linphoneCall: call)
                    delegate.incomingCallReceived(voipLibCall)
                case .Connected:
                    delegate.callConnected(voipLibCall)
                case .End, .Error:
                    delegate.callEnded(voipLibCall)
                case .Released:
                    delegate.callReleased(voipLibCall)
                default:
                    delegate.callUpdated(voipLibCall, message: message)
            }
        }
    }
    
    func onTransferStateChanged(core: Core, transfered: LinphoneCall, VoIPLibCallState: LinphoneCall.State) {
        guard let delegate = self.linphoneManager.config?.callDelegate else {
            linphoneManager.log("Unable to send VoIPLibCall transfer event as no VoIPLibCall delegate")
            return
        }
        
        guard let voipLibVoIPLibCall = VoIPLibCall(linphoneCall: transfered) else {
            linphoneManager.log("Unable to create VoIPLibCall, no remote address")
            return
        }
        
        delegate.attendedTransferMerged(voipLibVoIPLibCall)
    }
    
    /**
            Some headers only appear in the initial invite, this will check for any headers we have flagged to be preserved
     and retain them across all iterations of the LinphoneVoIPLibCall.
     */
    private func preserveHeaders(linphoneCall: LinphoneCall) {
        headersToPreserve.forEach { key in
            let value = linphoneCall.getToHeader(headerName: key)
            linphoneCall.params?.addCustomHeader(headerName: key, headerValue: value)
        }
    }
}

class RegistrationListener : CoreDelegate {
    
    /**
     * The amount of time to wait before determining registration has failed.
     */
    private let registrationTimeoutSecs: Double = 5
    
    /**
     * The time that we will wait before executing the method again to clean-up.
     */
    private let cleanUpDelaySecs: Double = 1
    
    /**
     * It is sometimes possible that a failed registration will occur before a successful one
     * so we will track the time of the first registration update before determining it has
     * failed.
     */
    private var startTime: Double? = nil
    
    private var currentTime: Double {
        get {
            return NSDate().timeIntervalSince1970
        }
    }
    
    private var timer: Timer? = nil
    
    private let linphoneManager: LinphoneManager

    init(linphoneManager: LinphoneManager) {
        self.linphoneManager = linphoneManager
    }

    func onAccountRegistrationStateChanged(core: Core, account: Account, state: linphonesw.RegistrationState, message: String) {
        log("Received registration state change: \(state.rawValue)")
        
        guard let callback = linphoneManager.registrationCallback else {
            log("Callback not set so registration state change has not done anything.")
            return
        }
        
        // If the registration was successful, just immediately invoke the callback and reset
        // all timers.
        if state == linphonesw.RegistrationState.Ok {
            log("Successful, resetting timers.")
            linphoneManager.registrationCallback = nil
            linphoneManager.isRegistered = true
            callback(RegistrationState.registered)
            reset()
            return
        }
        
        // If there is no start time, we want to set it to begin the time.
        let startTime = (self.startTime != nil ? self.startTime : {
            let startTime = currentTime
            self.startTime = startTime
            log("Started registration timer: \(startTime).")
            return startTime
        }())!
        
        if hasExceededTimeout(startTime) {
            linphoneManager.registrationCallback = nil
            linphoneManager.isRegistered = false
            linphoneManager.unregister()
            log("Registration timeout has been exceeded, registration failed.")
            callback(RegistrationState.failed)
            reset()
            return
        }
        
        // Queuing call of this method so we ensure that the callback is eventually invoked
        // even if there are no future registration updates.
        timer = Timer.scheduledTimer(withTimeInterval: cleanUpDelaySecs, repeats: false, block: { _ in
            self.onAccountRegistrationStateChanged(
                core: core,
                account: account,
                state: state,
                message: "Automatically called to ensure callback is executed"
            )
        })
    }
    
    private func hasExceededTimeout(_ startTime: Double) -> Bool {
        return (startTime + registrationTimeoutSecs) < currentTime
    }
    
    private func reset() {
        startTime = nil
        timer?.invalidate()
    }
}
