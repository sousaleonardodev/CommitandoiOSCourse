//

import XCTest
import RestaurantDomain

final class LocalRestaurantLoaderGettingTests: XCTestCase {
	func testLoadingRestaurantsReturnedError() {
		let (sut, cache, _) = makeSUT()

		assert(sut, completion: .failure(.invalidData)) {
			let error = NSError(domain: "Loading error", code: -1)
			cache.completionHandlerForLoad(state: .failure(error: error))
		}
	}

	func testLoadingRestaurantSuccessEmptyReturn() {
		let (sut, cache, _) = makeSUT()

		assert(sut, completion: .success([])) {
			cache.completionHandlerForLoad(state: .empty)
		}
	}

	func testLoadingSuccessWithWithinExpiringDate() {
		let (sut, cache, date) = makeSUT()
		let oneDayOlderDate = date.adding(days: -1).adding(seconds: 1)
		let items = restaurantList()

		assert(sut, completion: .success(items)) {
			cache.completionHandlerForLoad(state: .success(items: items, timestamp: oneDayOlderDate))
		}

		XCTAssertEqual(cache.calledMethods, [.load])
	}
}

private extension Date {
	func adding(days: Int) -> Date {
		Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}

	func adding(seconds: TimeInterval) -> Date {
		self + seconds
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

	private func assert(
		_ sut: LocalRestaurantLoader,
		completion result: RestaurantLoader.RestaurantResult?,
		when action: () -> Void,
		file: StaticString = #file,
		line: UInt = #line
	) {
		let restaurants = restaurantList()
		var returnedResult: RestaurantLoader.RestaurantResult?

		sut.load { result in
			returnedResult = result
		}

		action()

		XCTAssertEqual(returnedResult, result)
	}
}
