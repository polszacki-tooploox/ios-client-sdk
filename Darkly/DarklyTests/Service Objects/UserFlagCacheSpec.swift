//
//  LDFlagCacheSpec.swift
//  DarklyTests
//
//  Created by Mark Pokorny on 11/6/17. +JMJ
//  Copyright © 2017 LaunchDarkly. All rights reserved.
//

import Quick
import Nimble
import Foundation
@testable import Darkly

final class UserFlagCacheSpec: QuickSpec {
    override func spec() {
        var subject: UserFlagCache!
        var mockFlagCollectionStore: FlagCollectionCachingMock!
        beforeEach {
            mockFlagCollectionStore = FlagCollectionCachingMock()
            mockFlagCollectionStore.retrieveFlagsReturnValue = [:]
            subject = UserFlagCache(flagCollectionStore: mockFlagCollectionStore)
        }

//        describe("store and retrieve flags using user defaults") {
//            var userStub: LDUser!
//            var retrievedFlags: [String: Any]?
//            beforeEach {
//                userStub = LDUser.stub()
//                subject = UserFlagCache(flagCollectionStore: mockFlagCollectionStore)
//                subject.cacheFlags(for: userStub)
//
//                retrievedFlags = subject.retrieveFlags(for: userStub)
//            }
//            it("retrieves flags that have matching key") {
//                expect(retrievedFlags == userStub.flagStore.featureFlags).to(beTrue())
//            }
//            afterEach {
//                subject.keyedValueStoreForTesting.removeObject(forKey: LDFlagCache.flagCacheKey)
//            }
//        }

//        describe("convert user cache to flag cache") {
//            var userStub: LDUser!
//            beforeEach {
//                userStub = LDUser.stub()
//            }
//            context("when the user is stored as a dictionary") {
//                beforeEach {
//                    mockStore.storeUserAsDictionary(user: userStub)
//
//                    subject.convertUserCacheToFlagCache()
//                }
//                it("stores the user's flags") {
//                    expect(mockStore.lastUpdated(for: userStub)).toNot(beNil())
//                    expect(mockStore.flags(for: userStub)).toNot(beNil())
//                    guard let userFlags = mockStore.flags(for: userStub) else { return }
//                    expect(userFlags == userStub!.flagStore.featureFlags).to(beTrue())
//                }
//            }
//            context("when the user is stored as data") {
//                beforeEach {
//                    mockStore.storeUserAsData(user: userStub)
//
//                    subject.convertUserCacheToFlagCache()
//                }
//                it("stores the user's flags") {
//                    expect(mockStore.lastUpdated(for: userStub)).toNot(beNil())
//                    expect(mockStore.flags(for: userStub)).toNot(beNil())
//                    guard let userFlags = mockStore.flags(for: userStub) else { return }
//                    expect(userFlags == userStub!.flagStore.featureFlags).to(beTrue())
//                }
//            }
//        }

//        describe("retrieveLatest") {
//            var retrievedFlags: [String: Any]?
//            context("when there are no cached flags") {
//                beforeEach {
//                    retrievedFlags = subject.retrieveLatest()
//                }
//                it("returns nil") {
//                    expect(retrievedFlags).to(beNil())
//                }
//            }
//            context("when there are cached flags") {
//                var latestFlags: [String: Any]?
//                beforeEach {
//                    let userStubs = mockStore.stubAndStoreUserFlags(count: 3)
//                    latestFlags = userStubs.last?.flagStore.featureFlags
//
//                    retrievedFlags = subject.retrieveLatest()
//                }
//                it("retrieves the flags with the latest last updated time") {
//                    expect(retrievedFlags == latestFlags).to(beTrue())
//                }
//            }
//        }

        describe("retrieve flags") {
            context("when the user flags exist in the flag collection store") {
                var mockUser: LDUser!
                var mockUserFlags: UserFlags!
                var retrievedFlags: UserFlags?
                beforeEach {
                    mockUser = LDUser.stub()
                    mockUserFlags = UserFlags(user: mockUser)
                    mockFlagCollectionStore.retrieveFlagsReturnValue = [mockUser.key: mockUserFlags]

                    retrievedFlags = subject.retrieveFlags(for: mockUser)
                }
                it("returns the user flags") {
                    expect(retrievedFlags) == mockUserFlags
                }
            }
            context("when the user flags do not exist in the flag collection store") {
                var mockUser: LDUser!
                var retrievedFlags: UserFlags?
                beforeEach {
                    mockUser = LDUser.stub()
                    retrievedFlags = subject.retrieveFlags(for: mockUser)
                }
                it("returns nil for user flags") {
                    expect(retrievedFlags).to(beNil())
                    expect(mockFlagCollectionStore.retrieveFlagsCallCount) == 1
                }
            }
//            context("when flag store is full and an older flag set has been removed") {
//                var userStubs: [LDUser]!
//                var retrievedFlags: [String: Any]?
//                beforeEach {
//                    userStubs = [LDUser.stub()] + mockStore.stubAndStoreUserFlags(count: subject.maxCachedValues)
//                }
//                it("retrieves the flags present in the flag store") {
//                    for index in 0..<userStubs.count {
//                        retrievedFlags = subject.retrieveFlags(for: userStubs[index])
//                        if index == 0 {
//                            expect(retrievedFlags).to(beNil())
//                        }
//                        else {
//                            expect(retrievedFlags == userStubs[index].flagStore.featureFlags).to(beTrue())
//                        }
//                    }
//                }
//            }
        }

        describe("store flags") {
            var mockUser: LDUser!
            var userFlags: UserFlags!
            context("when the user flags are not already stored") {
                beforeEach {
                    mockUser = LDUser.stub()
                    userFlags = UserFlags(user: mockUser)

                    subject.cacheFlags(for: mockUser)
                }
                it("stores user flags") {
                    expect(mockFlagCollectionStore.storeFlagsReceivedFlags).toNot(beNil())
                    guard let storedCollection = mockFlagCollectionStore.storeFlagsReceivedFlags else { return }
                    expect(storedCollection[mockUser.key]).toNot(beNil())
                    guard let storedFlags = storedCollection[mockUser.key] else { return }
                    expect(storedFlags) == userFlags
                }
            }
            context("when the user flags are already stored") {
                var mockFlagStore: LDFlagMaintainingMock!
                var changedFlags: [String: Any]!
                var changedUserFlags: UserFlags!
                beforeEach {
                    mockUser = mockFlagCollectionStore.stubAndStoreUserFlags(count: 1).first!
                    mockFlagStore = mockUser.flagStore as? LDFlagMaintainingMock

                    changedFlags = mockFlagStore.featureFlags
                    changedFlags["newKey"] = true
                    mockFlagStore.featureFlags = changedFlags!
                    changedUserFlags = UserFlags(user: mockUser)

                    subject.cacheFlags(for: mockUser)
                }
                it("stores user flags") {
                    expect(mockFlagCollectionStore.storeFlagsReceivedFlags).toNot(beNil())
                    guard let storedCollection = mockFlagCollectionStore.storeFlagsReceivedFlags else { return }
                    expect(storedCollection[mockUser.key]).toNot(beNil())
                    guard let storedFlags = storedCollection[mockUser.key] else { return }
                    expect(storedFlags) == changedUserFlags
                }
            }
//            context("when the flag store is full") {
//                var userStubs: [LDUser]!
//                var storedFlags: [String: Any]?
//                beforeEach {
//                    userStubs = mockStore.stubAndStoreUserFlags(count: subject.maxCachedValues) + [LDUser.stub()]
//
//                    subject.storeFlags(for: userStubs.last!)
//                }
//                it("retrieves the flags present in the flag store") {
//                    for index in 0..<userStubs.count {
//                        storedFlags = mockStore.flags(for: userStubs![index])
//                        if index == 0 {
//                            expect(storedFlags).to(beNil())
//                        }
//                        else {
//                            expect(storedFlags == userStubs[index].flagStore.featureFlags).to(beTrue())
//                        }
//                    }
//                }
//            }
        }
    }
}

//extension UserFlagCache {
//    var keyedValueStoreMock: KeyedValueStoringMock? { return keyedValueStoreForTesting as? KeyedValueStoringMock }
//}

extension FlagCollectionCachingMock {
    func stubAndStoreUserFlags(count: Int) -> [LDUser] {
        var userStubs = [LDUser]()
        //swiftlint:disable:next empty_count
        guard count > 0 else { return userStubs }
        while userStubs.count < count { userStubs.append(LDUser.stub()) }
        var cachedFlags = [String: UserFlags]()
        userStubs.forEach { (user) in cachedFlags[user.key] = UserFlags(user: user) }
        retrieveFlagsReturnValue = cachedFlags
        return userStubs
    }
}

//extension KeyedValueStoringMock {
//
//    func storeUserAsDictionary(user: LDUser) {
//        let userDictionaries = [user.key: user.jsonDictionaryWithConfig]
//        dictionaryReturnValue = userDictionaries
//    }
//
//    func storeUserAsData(user: LDUser) {
//        let userData = [user.key: NSKeyedArchiver.archivedData(withRootObject: LDUserWrapper(user: user))]
//        dictionaryReturnValue = userData
//    }
//
//    func lastUpdated(for user: LDUser) -> Date? {
//        return cachedFlags(for: user)?.lastUpdated
//    }
//
//    func flags(for user: LDUser) -> [String: Any]? {
//        return cachedFlags(for: user)?.flags
//    }
//
//    private func cachedFlags(for user: LDUser) -> UserFlags? {
//        guard let receivedArguments = setReceivedArguments, receivedArguments.forKey == UserFlagCache.flagCacheKey,
//            let flagStore = receivedArguments.value as? [String: Any],
//            let userFlagDictionary = flagStore[user.key] as? [String: Any]
//        else { return nil }
//        return UserFlags(dictionary: userFlagDictionary)
//    }
//}

extension Dictionary where Key == String, Value == LDUser {
    fileprivate mutating func removeOldest() {
        guard !self.isEmpty else { return }
        guard let oldestPair = self.max(by: { (pair1, pair2) -> Bool in pair1.value.lastUpdated > pair2.value.lastUpdated }) else { return }
        self.removeValue(forKey: oldestPair.key)
    }
}