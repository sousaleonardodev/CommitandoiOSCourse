//

import XCTest
import RestaurantDomain
@testable import RestaurantUI

final class RestaurantUITests: XCTestCase {

	func testInitDoesntLoad() {
		let (sut, service) = makeSUT()

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertTrue(service.calledMethod.isEmpty)
	}

	func testViewControllerDidCalledLoad() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertEqual(sut.restaurants.count, 0)
		XCTAssertEqual(service.calledMethod, [.load])
	}

	func testLoadWithReturnedData() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.success(restaurantList()))

		XCTAssertEqual(service.calledMethod, [.load])
		XCTAssertEqual(sut.restaurants.count, 4)
	}

	func testLoadWithError() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.failure(.connectivity))

		XCTAssertEqual(service.calledMethod, [.load])
		XCTAssertEqual(sut.restaurants.count, 0)
	}

	func testLoadUsingRefreshControl() {
		let (sut, service) = makeSUT()

		sut.simulatePullToRefresh()

		XCTAssertEqual(service.calledMethod, [.load, .load])
		XCTAssertEqual(sut.restaurants.count, 0)
	}

	func testViewDidLoadWithLoadingIndicator() {
		let (sut, _) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertTrue(sut.isShowingLoadingIndicator())
	}

	func testLoadFinishedFailure() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.failure(.connectivity))

		XCTAssertFalse(sut.isShowingLoadingIndicator())
	}

	func testLoadFinishedSuccess() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.success(restaurantList()))

		XCTAssertFalse(sut.isShowingLoadingIndicator())
	}

	func testPullToRefreshWithLoadingIndicator() {
		let (sut, _) = makeSUT()

		sut.simulatePullToRefresh()

		XCTAssertTrue(sut.isShowingLoadingIndicator())
	}

	func testPullToRefreshFailureLoadingIndicator() {
		let (sut, service) = makeSUT()

		sut.simulatePullToRefresh()
		service.completionResult(.failure(.connectivity))

		XCTAssertFalse(sut.isShowingLoadingIndicator())
	}

	func testPullToRefreshSuccessLoadingIndicator() {
		let (sut, service) = makeSUT()

		sut.simulatePullToRefresh()
		service.completionResult(.success(restaurantList()))

		XCTAssertFalse(sut.isShowingLoadingIndicator())
	}

	func testShowLoadingIndicatorForAllLifeCycleView() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()

		XCTAssertTrue(sut.isShowingLoadingIndicator())
		service.completionResult(.failure(.connectivity))
		XCTAssertFalse(sut.isShowingLoadingIndicator())

		sut.simulatePullToRefresh()
		XCTAssertTrue(sut.isShowingLoadingIndicator())
		service.completionResult(.success(restaurantList()))
		XCTAssertFalse(sut.isShowingLoadingIndicator())
	}

	func testRenderAllRestaurantsItemCells() {
		let (sut, service) = makeSUT()

		sut.loadViewIfNeeded()
		service.completionResult(.success(restaurantList()))

		XCTAssertEqual(sut.numberOfRows(), 4)

		let cell = sut.tableView(sut.tableView, cellForRowAt: .init(row: 0, section: 1)) as? RestaurantItemCell

		XCTAssertNotNil(cell)
		XCTAssertEqual(cell?.title.text ?? "", "name")
		XCTAssertEqual(cell?.parasols.text ?? "", "Guarda-sois: 11")
		XCTAssertEqual(cell?.distance.text ?? "", "Distância: 1.0")
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
	enum Methods {
		case load
	}

	private(set) var calledMethod: [Methods] = []

	private(set) var completionHandler: ((RestaurantResult) -> Void)?
	func load(completion: @escaping (RestaurantResult) -> Void) {
		calledMethod.append(.load)
		completionHandler = completion
	}

	func completionResult(_ result: RestaurantResult) {
		completionHandler?(result)
	}
}

private extension UIRefreshControl {
	func simulatePullToRefresh() {
		allTargets.forEach { target in
			actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
				(target as NSObject).perform(Selector($0))
			}
		}
	}
}

private extension RestaurantListViewController {
	func simulatePullToRefresh() {
		refreshControl?.simulatePullToRefresh()
	}

	func isShowingLoadingIndicator() -> Bool {
		refreshControl?.isRefreshing ?? false
	}

	func numberOfRows(in section: Int = 0) -> Int {
		tableView(tableView, numberOfRowsInSection: section)
	}
}
