//

import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderTests: XCTestCase {
	func testSaveAndDeleteOldCache() {
		let (sut, cache) = makeSUT()
		let restaurants: [RestaurantItem] = [RestaurantItem]()

		sut.save(restaurants, completion: { _ in })

		XCTAssertEqual(cache.deleteCount, 1)
	}

	func testSaveInsertNewDataOnCache() {
		let (sut, cache) = makeSUT()
		let restaurants = restaurantList()

		sut.save(restaurants, completion: { _ in })

		cache.completionHandleForDelete()

		XCTAssertEqual(cache.deleteCount, 1)
		XCTAssertEqual(cache.saveCount, 1)
	}

	private func restaurantList() -> [RestaurantItem] {
		[
			.init(id: UUID(), name: "name", location: "location", distance: Float(1), ratings: 5, parasols: 11),
			.init(id: UUID(), name: "name1", location: "location1", distance: Float(10), ratings: 2, parasols: 10),
			.init(id: UUID(), name: "name2", location: "location2", distance: Float(20), ratings: 3, parasols: 9),
			.init(id: UUID(), name: "name3", location: "location3", distance: Float(100), ratings: 1, parasols: 5)
		]
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {
		let cacheClient = CacheClientSpy()
		let currentDate = Date()
		let sut = LocalRestaurantLoader(cacheClient: cacheClient, currentDate: { currentDate })

		trackForMemoryLeaks(cacheClient)
		trackForMemoryLeaks(sut)

		return (sut, cacheClient)
	}
}


final class CacheClientSpy: CacheClient {
	private(set) var saveCount = 0
	func save(_ restaurants: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
		saveCount += 1
	}

	private(set) var deleteCount = 0
	private var completionHandler: ((Error?) -> Void)?
	func delete(completion: @escaping (Error?) -> Void) {
		deleteCount += 1
		completionHandler = completion
	}

	func completionHandleForDelete(error: Error? = nil) {
		completionHandler?(error)
	}
}
