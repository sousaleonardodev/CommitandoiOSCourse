//

import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderTests: XCTestCase {
	func testSaveAndDeleteOldCache() {
		let currentDate = Date()
		let cache = CacheClientSpy()
		let sut = LocalRestaurantLoader(cacheClient: cache, currentDate: { currentDate })
		let restaurants: [RestaurantItem] = [RestaurantItem]()

		sut.save(restaurants, completion: { _ in })

		XCTAssertEqual(cache.deleteCount, 1)
	}
}


final class CacheClientSpy: CacheClient {
	func save(_ restaurants: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {

	}

	private(set) var deleteCount = 0
	func delete(completion: @escaping (Error?) -> Void) {
		deleteCount += 1
	}
}
