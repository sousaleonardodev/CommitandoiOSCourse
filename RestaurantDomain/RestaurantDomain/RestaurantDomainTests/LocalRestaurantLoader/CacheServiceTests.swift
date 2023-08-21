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
		let sut = makeSUT(managerURL: invalidManagerURL())
		let items = restaurantList()

		let returnedError = insert(sut, items: items, timestamp: Date())

		XCTAssertNotNil(returnedError)
	}

	func testDeleteEmptyCache() {
		let sut = makeSUT()

		assert(sut, completion: .empty)

		let returnedError: Error? = delete(sut)

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

	func testDeleteWithInvalidURL() {
		let sut = makeSUT(managerURL: invalidManagerURL())

		let returnedError = delete(sut)

		XCTAssertNotNil(returnedError)
	}

	func testLoadWithEmptyCache() {
		let sut = makeSUT()

		assert(sut, completion: .empty)
	}

	func testLoadWithEmptyCacheCalledTwice() {
		let sut = makeSUT()

		assert(sut, completion: .empty)
		assert(sut, completion: .empty)
	}

	func testLoadWithCache() {
		let sut = makeSUT()
		let items = restaurantList()
		let timestamp = Date()

		insert(sut, items: items, timestamp: timestamp)

		assert(sut, completion: .success(items: items, timestamp: timestamp))
	}

	func testLoadWithInvalidData() {
		let sut = makeSUT()
		let error = NSError(domain: "load test", code: -1)

		try? "invalidData".write(to: validManagerURL(), atomically: false, encoding: .utf8)
		assert(sut, completion: .failure(error: error))
	}

	func testSaveWithSerialTasks() {
		let sut = makeSUT()
		let items = restaurantList()
		let timestamp = Date()

		var serialTasks = [XCTestExpectation]()

		let firstTask = XCTestExpectation(description: "First task")
		sut.save(items, timestamp: timestamp) { _ in
			serialTasks.append(firstTask)
			firstTask.fulfill()
		}

		let secondTask = XCTestExpectation(description: "second task")
		sut.delete { _ in
			serialTasks.append(secondTask)
			secondTask.fulfill()
		}

		let thirdTask = XCTestExpectation(description: "third task")
		sut.save(items, timestamp: timestamp) { _ in
			serialTasks.append(thirdTask)
			thirdTask.fulfill()
		}

		wait(for: [firstTask, secondTask, thirdTask], timeout: 0.5)
		XCTAssertEqual(serialTasks, [firstTask, secondTask, thirdTask])
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

	private func invalidManagerURL() -> URL {
		FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
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

		wait(for: [expectation], timeout: 3.0)
		return returnedError
	}
}
