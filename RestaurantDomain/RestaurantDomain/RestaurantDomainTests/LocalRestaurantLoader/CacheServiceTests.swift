//

import XCTest
@testable import RestaurantDomain

final class CacheServiceTests: XCTestCase {

	override func setUp() {
		super.setUp()
		try? FileManager.default.removeItem(at: validManagerURL())
	}

	func testSaveValue() {
		let sut = makeSUT()
		let items = restaurantList()
		let timestamp = Date()

		let returnedError = insert(sut, items: items, timestamp: timestamp)

		XCTAssertNil(returnedError)
	}

	func testSaveAndReturnLastValue() {
		let sut = makeSUT()
		let firstTimeItems = restaurantList()
		let firstTimeTimestamp = Date()

		insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)

		let secondTimeItems = restaurantList()
		let secondTimeTimestamp = Date()

		insert(sut, items: secondTimeItems, timestamp: secondTimeTimestamp)

		assert(sut, completion: .success(items: secondTimeItems, timestamp: secondTimeTimestamp))
	}

	func testSaveReturnErrorWithInvalidURL() {
		let invalidURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
		let sut = makeSUT(managerURL: invalidURL)
		let items = restaurantList()

		let returnedError = insert(sut, items: items, timestamp: Date())

		XCTAssertNotNil(returnedError)
	}

	func testDeleteEmptyCache() {
		let sut = makeSUT()

		assert(sut, completion: .empty)

		var returnedError: Error? = delete(sut)

		XCTAssertNil(returnedError)
		assert(sut, completion: .empty)
	}

	func testDeleteWithCachedValues() {
		let sut = makeSUT()
		let items = restaurantList()
		let timestamp = Date()

		insert(sut, items: items, timestamp: timestamp)
		assert(sut, completion: .success(items: items, timestamp: timestamp))

		delete(sut)

		assert(sut, completion: .empty)
	}

	func testDeleteReturnedEmptyAfterInsertingNewDate() {
		let sut = makeSUT()
		let items = restaurantList()
		let timestamp = Date()

		insert(sut, items: items, timestamp: timestamp)

		delete(sut)

		assert(sut, completion: .empty)
	}

	private func assert(
		_ sut: CacheClient,
		completion result: LoadResultState,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let expectation = XCTestExpectation(description: "assert expectation")

		sut.load { returnedResult in
			switch (result, returnedResult) {
			case (.empty, .empty), (.failure, .failure):
				break
			case let (.success(items: items, timestamp: timestamp), .success(items: returnedItems, timestamp: returnedTimestamp)):
				XCTAssertEqual(items, returnedItems, file: file, line: line)
				XCTAssertEqual(timestamp, returnedTimestamp, file: file, line: line)

			default:
				XCTFail("Expected: \(result), got: \(returnedResult)", file: file, line: line)
			}

			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 0.5)
	}

	private func validManagerURL() -> URL {
		let path = type(of: self)

		return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(path)")
	}

	private func makeSUT(managerURL: URL? = nil) -> CacheClient {
		return CacheService(managerURL: managerURL ?? validManagerURL())
	}

	@discardableResult
	private func insert(_ sut: CacheClient, items: [RestaurantItem], timestamp: Date) -> Error? {
		let expectation = XCTestExpectation(description: "filemanager wait")
		var returnedError: Error?

		sut.save(items, timestamp: timestamp) { error in
			returnedError = error
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 0.5)

		return returnedError
	}

	@discardableResult
	private func delete(_ sut: CacheClient) -> Error? {
		let expectation = XCTestExpectation(description: "delete expectation")

		var returnedError: Error?
		sut.delete { error in
			returnedError = error
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 0.5)
		return returnedError
	}
}
