//

import XCTest
import RestaurantDomain

final class LocalRestaurantLoaderGettingTests: XCTestCase {
	func testLoadingRestaurantsReturnedError() {
		let (sut, cache, _) = makeSUT()
		var returnedResult: RestaurantLoader.RestaurantResult?

		sut.load { result in
			returnedResult = result
		}

		let error = NSError(domain: "Loading error", code: -1)
		cache.completionHandlerForLoad(error: error)

		XCTAssertEqual(cache.calledMethods, [.load])
		XCTAssertEqual(returnedResult, .failure(.invalidData))
	}
}

private extension LocalRestaurantLoaderGettingTests {
	func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line
	) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy, timestamp: Date) {
		let cacheClient = CacheClientSpy()
		let currentDate = Date()
		let sut = LocalRestaurantLoader(cacheClient: cacheClient, currentDate: { currentDate })

		trackForMemoryLeaks(cacheClient)
		trackForMemoryLeaks(sut)

		return (sut, cacheClient, currentDate)
	}

	func restaurantList() -> [RestaurantItem] {
		[
			.init(id: UUID(), name: "name", location: "location", distance: 1.0, ratings: 5, parasols: 11),
			.init(id: UUID(), name: "name1", location: "location1", distance: 10.2, ratings: 2, parasols: 10),
			.init(id: UUID(), name: "name2", location: "location2", distance: 20.5, ratings: 3, parasols: 9),
			.init(id: UUID(), name: "name3", location: "location3", distance: 100.8, ratings: 1, parasols: 5)
		]
	}
}
