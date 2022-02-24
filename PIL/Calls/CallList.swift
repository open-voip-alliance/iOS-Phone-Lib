//
//  CallList.swift
//  PIL
//
//  Created by Chris Kontos on 04/08/2021.
//

import Foundation

class CallList {
    
    var callArray = [VoipLibCall]()
    
    let maxCalls: Int
    
    init(maxCalls: Int) {
        self.maxCalls = maxCalls
    }
    
    func add(call: VoipLibCall) -> Bool {
        if callExists(call: call) || callArray.count >= maxCalls {
            print("Call could not be added on CallList")
            return false
        }
        
        print("Call has been added to CallList")
        callArray.append(call)
        return true
    }
    
    func remove(call: VoipLibCall) -> VoipLibCall? {
        if let index = findIndexOf(call: call) {
            callArray.remove(at: index)
            
            print("Call has been removed from CallList")
            return call
        }
        print("Call could not be found on CallList")
        return nil
    }
    
    private func findIndexOf(call: VoipLibCall) -> Int? {
        let index = callArray.firstIndex(where: { $0.callHash == call.callHash})
        return index
    }
    
    private func callExists(call: VoipLibCall) -> Bool {
        for listedCall in callArray {
            if listedCall.callHash == call.callHash {
                return true
            }
        }
        return false
    }
    
}
