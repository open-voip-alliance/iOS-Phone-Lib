import Foundation
import linphonesw
import AVFoundation

typealias LinphoneCall = linphonesw.Call
public typealias RegistrationCallback = (RegistrationState) -> Void
typealias LinphoneLogLevel = linphonesw.LogLevel

class LinphoneManager: linphonesw.LoggingServiceDelegate {
   
    private(set) var config: VoIPLibConfig?
    var isInitialized: Bool {
        linphoneCore != nil
    }
    
    private var linphoneCore: Core!
    private lazy var linphoneListener = { LinphoneListener(manager: self) }()
    private lazy var registrationListener = { LinphoneRegistrationListener(manager: self) }()
    
    var isMicrophoneMuted: Bool {
        return !linphoneCore.micEnabled
    }
    
    /**
     * We're going to store the auth object that we used to authenticate with successfully, so we
     * know we need to re-register if it has changed.
     */
    private var lastRegisteredCredentials: Auth? = nil
    
    var pil: PIL {
        return PIL.shared!
    }
    
    init() {
        registrationListener = LinphoneRegistrationListener(manager: self)
        linphoneListener = LinphoneListener(manager: self)
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
        LoggingService.Instance.addDelegate(delegate: self)
        LoggingService.Instance.logLevel = linphonesw.LogLevel.Debug
        
        linphoneCore = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
        linphoneCore.addDelegate(delegate: linphoneListener)
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
        core.setUserAgent(name: pil.app.userAgent, version: nil)
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
        LoggingService.Instance.message(message: message)
    }
    
    internal var registrationCallback: RegistrationCallback? = nil
    
    func register(callback: @escaping RegistrationCallback) {
        do {
            guard let auth = pil.auth else {
                throw InitializationError.noConfigurationProvided
            }
            
            if lastRegisteredCredentials != auth && lastRegisteredCredentials != nil {
                log("Auth appears to have changed, unregistering old.")
                unregister()
            }

            linphoneCore.removeDelegate(delegate: self.registrationListener)
            linphoneCore.addDelegate(delegate: self.registrationListener)

            self.registrationCallback = callback

            if (!linphoneCore.accountList.isEmpty) {
                log("We are already registered, refreshing registration.")
                linphoneCore.refreshRegisters()
                return
            }
            
            log("No valid registrations, registering for the first time.")

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
        return try Factory.Instance.createAuthInfo(
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
        linphoneCore.removeDelegate(delegate: linphoneListener)
        linphoneCore.stop()
        log("Linphone destroyed")
        linphoneCore = nil
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
    
    func acceptCall(for call: VoIPLibCall) -> Bool {
        do {
            try call.linphoneCall.accept()
            return true
        } catch {
            return false
        }
    }
    
    func endCall(for call: VoIPLibCall) -> Bool {
        do {
            try call.linphoneCall.terminate()
            return true
        } catch {
            return false
        }
    }
    
    private func configureCodecs(core: Core) {
        let codecs = [Codec.OPUS]
        
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
            try call.linphoneCall.transferTo(referTo: linphoneCore.createAddress(address: number))
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
    
    func provideCallInfo(call: VoIPLibCall) -> String {
        return CallInfoProvider(VoIPLibCall: call).provide()
    }
    
    func onLogMessageWritten(logService: LoggingService, domain: String, level: LogLevel, message: String) {
        config?.logListener(message)
    }
    
    internal func refreshRegistration() {
        linphoneCore.refreshRegisters()
    }
    
    private var ringbackPath: String {
        let ringbackFileName = "ringback"
        let customBundle = Bundle(for: Self.self)
        guard let resourceURL = customBundle.resourceURL?.appendingPathComponent("Resources.bundle") else { return "" }
        guard let resourceBundle = Bundle(url: resourceURL) else { return "" }
        guard let ringbackFileURL = resourceBundle.url( forResource: ringbackFileName , withExtension: "wav") else { return "" }
        return ringbackFileURL.path
    }
}
