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

	private func restaurantList() -> [RestaurantItem] {
		[
			.init(id: UUID(), name: "name", location: "location", distance: 1.0, ratings: 5, parasols: 11),
			.init(id: UUID(), name: "name1", location: "location1", distance: 10.2, ratings: 2, parasols: 10),
			.init(id: UUID(), name: "name2", location: "location2", distance: 20.5, ratings: 3, parasols: 9),
			.init(id: UUID(), name: "name3", location: "location3", distance: 100.8, ratings: 1, parasols: 5)
		]
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


final class CacheClientSpy: CacheClient {
	enum Method: Equatable {
		case save(items: [RestaurantItem], timestamp: Date)
		case delete
	}

	private(set) var calledMethods: [Method] = []

	func save(
		_ restaurants: [RestaurantDomain.RestaurantItem],
		timestamp: Date,
		completion: @escaping (Error?) -> Void
	) {
		completionSaveHandler = completion
		calledMethods.append(.save(items: restaurants, timestamp: timestamp))
	}

	func delete(completion: @escaping (Error?) -> Void) {
		completionDeleteHandler = completion
		calledMethods.append(.delete)
	}

	private var completionDeleteHandler: ((Error?) -> Void)?
	func completionHandleForDelete(error: Error? = nil) {
		completionDeleteHandler?(error)
	}

	private var completionSaveHandler: ((Error?) -> Void)?
	func completionHandlerForSave(error: Error? = nil) {
		completionSaveHandler?(error)
	}
}
