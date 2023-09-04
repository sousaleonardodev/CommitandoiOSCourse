//

import XCTest
import RestaurantDomain
@testable import RestaurantUI

final class RestaurantUITests: XCTestCase {

	func testInitDoesntLoad() {
		let (sut, service) = makeSUT()

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertEqual(service.loadCount, 0)
	}

	func testViewControllerDidCalledLoad() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertEqual(service.loadCount, 1)
	}

	func testLoadWithReturnedData() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.success(restaurantList()))

		XCTAssertEqual(service.loadCount, 1)
		XCTAssertEqual(sut.restaurants.count, 4)
	}

	func testLoadWithError() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.failure(.connectivity))

		XCTAssertEqual(service.loadCount, 1)
		XCTAssertEqual(sut.restaurants.count, 0)
	}

	func testLoadUsingRefreshControl() {
		let (sut, service) = makeSUT()

		sut.refreshControl?.simulatePullToRefresh()

		XCTAssertEqual(service.loadCount, 2)
		XCTAssertEqual(sut.restaurants.count, 0)
	}

	func testViewDidLoadWithLoadingIndicator() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertTrue(sut.refreshControl?.isRefreshing ?? false)
	}

	func testLoadFinishedFailure() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.failure(.connectivity))

		XCTAssertFalse(sut.refreshControl?.isRefreshing ?? true)
	}

	func testLoadFinishedSuccess() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.success(restaurantList()))

		XCTAssertFalse(sut.refreshControl?.isRefreshing ?? true)
	}

	func testPullToRefreshWithLoadingIndicator() {
		let (sut, _) = makeSUT()

		sut.refreshControl?.simulatePullToRefresh()

		XCTAssertTrue(sut.refreshControl?.isRefreshing ?? false)
	}

	func testPullToRefreshFailureLoadingIndicator() {
		let (sut, service) = makeSUT()

		sut.refreshControl?.simulatePullToRefresh()
		service.completionResult(.failure(.connectivity))

		XCTAssertFalse(sut.refreshControl?.isRefreshing ?? true)
	}

	func testPullToRefreshSuccessLoadingIndicator() {
		let (sut, service) = makeSUT()

		sut.refreshControl?.simulatePullToRefresh()
		service.completionResult(.success(restaurantList()))

		XCTAssertFalse(sut.refreshControl?.isRefreshing ?? true)
	}

	private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RestaurantListViewController, service: RestaurantLoaderSpy) {
		let service = RestaurantLoaderSpy()
		let sut = RestaurantListViewController(service: service)

		trackForMemoryLeaks(sut, file: file, line: line)
		trackForMemoryLeaks(service, file: file, line: line)

		return (sut, service)
	}
}

final class RestaurantLoaderSpy: RestaurantLoader {

	private(set) var loadCount = 0
	private(set) var completionHandler: ((RestaurantResult) -> Void)?
	func load(completion: @escaping (RestaurantResult) -> Void) {
		loadCount += 1
		completionHandler = completion
	}

	func completionResult(_ result: RestaurantResult) {
		completionHandler?(result)
	}
}

extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}
