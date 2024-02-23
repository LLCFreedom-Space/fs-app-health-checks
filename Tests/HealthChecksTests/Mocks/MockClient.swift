//
//  MockClient.swift
//  
//
//  Created by Mykhailo Bondarenko on 23.02.2024.
//

import Vapor

struct MockClient: Client {
    var eventLoop: EventLoop
    var clientResponse: ClientResponse
    
    func send(_ request: ClientRequest) -> EventLoopFuture<ClientResponse> {
        self.eventLoop.makeSucceededFuture(self.clientResponse)
    }
    
    func delegating(to eventLoop: EventLoop) -> Client {
        self
    }
}

extension ClientResponse: @unchecked Sendable {}
