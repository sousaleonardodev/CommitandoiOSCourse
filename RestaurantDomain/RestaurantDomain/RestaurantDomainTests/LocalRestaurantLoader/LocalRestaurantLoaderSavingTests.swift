//

import XCTest
import RestaurantDomain

final class LocalRestaurantLoaderSavingTests: XCTestCase {
	func testSaveAndDeleteOldCache() {
		let (sut, cache, _) = makeSUT()
		assert(sut, completion: nil) {}

		XCTAssertEqual(cache.calledMethods, [.delete])
	}

	func testSaveInsertNewDataOnCache() {
		let (sut, cache, date) = makeSUT()
		let restaurants = restaurantList()

		sut.save(restaurants, completion: { _ in })

		cache.completionHandleForDelete()

		XCTAssertEqual(cache.calledMethods, [.delete, .save(items: restaurants, timestamp: date)])
	}

	func testSaveFailAfterDeletingOldCache() {
		let (sut, cache, _) = makeSUT()
		let error = NSError(domain: "error testing", code: -1)

		assert(sut, completion: error) {
			cache.completionHandleForDelete(error: error)
		}
	}

	func testSaveFail() {
		let (sut, cache, _) = makeSUT()
		let error = NSError(domain: "error saving", code: -1)

		assert(sut, completion: error) {
			cache.completionHandleForDelete()
			cache.completionHandlerForSave(error: error)
		}
	}

	func testSaveSuccessAfetSaveNewcache() {
		let (sut, cache, _) = makeSUT()

		assert(sut, completion: nil) {
			cache.completionHandleForDelete()
			cache.completionHandlerForSave()
		}
	}

	func testSaveNonInsertedAfterDelloc() {
		let cache = CacheClientSpy()
		var sut: LocalRestaurantLoader? = LocalRestaurantLoader(cacheClient: cache, currentDate: { Date() } )

		var returnedError: Error?
		sut?.save([RestaurantItem]()) { error in
			returnedError = error
		}

		sut = nil
		cache.completionHandleForDelete()

		XCTAssertNil(returnedError)
	}

	func testSaveDeallocAfterSuccessfulDeleting() {
		let cache = CacheClientSpy()
		var sut: LocalRestaurantLoader? = LocalRestaurantLoader(cacheClient: cache, currentDate: { Date() } )

		var returnedError: Error?
		sut?.save([RestaurantItem]()) { error in
			returnedError = error
		}

		cache.completionHandleForDelete()
		sut = nil

		cache.completionHandlerForSave()

		XCTAssertNil(returnedError)
	}

	private func assert(
		_ sut: LocalRestaurantLoader,
		completion error: NSError?,
		when action: () -> Void,
		file: StaticString = #file,
		line: UInt = #line
	) {
		let restaurants = restaurantList()
		var returnedError: Error?

		sut.save(restaurants) { error in
			returnedError = error
		}

		action()

		XCTAssertEqual(returnedError as? NSError, error)
	}

	private func makeSUT(
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
}
