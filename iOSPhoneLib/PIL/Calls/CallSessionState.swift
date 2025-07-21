//
//  CallSessionState.swift
//  PIL
//
//  Created by Chris Kontos on 03/05/2021.
//

import Foundation

public class CallSessionState {
    
    public var activeCall: AppCall?
    public var inactiveCall: AppCall?
    public var audioState: AudioState
    
    init(activeCall: AppCall?, inactiveCall: AppCall?, audioState: AudioState){
        self.activeCall = activeCall
        self.inactiveCall = inactiveCall
        self.audioState = audioState
    }
}
