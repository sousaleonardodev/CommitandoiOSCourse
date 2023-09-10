//

import Foundation
import RestaurantDomain

protocol RestaurantListPresenterInput: AnyObject {
	func onLoadingChange(_ isLoading: Bool)
	func onRestaurantItems(_ items: [RestaurantItem])
}

final class RestaurantListPresenter: RestaurantListPresenterInput {
	weak var view: RestaurantListPresenterOutput?

	func onLoadingChange(_ isLoading: Bool) {
		view?.setLoading(isLoading)
	}

	func onRestaurantItems(_ items: [RestaurantDomain.RestaurantItem]) {
		let cellControllers = adaptRestaurantItemToCellController(items)
		view?.setRestaurantItemsCell(cellControllers)
	}

	private func adaptRestaurantItemToCellController(_ items: [RestaurantItem]) -> [RestaurantItemCellController] {

		items.map {
			RestaurantItemCellController(viewModel: $0)
		}
	}
}

protocol RestaurantListPresenterOutput: AnyObject {
	func setLoading(_ isLoading: Bool)
	func setRestaurantItemsCell(_ items: [RestaurantItemCellController])
}
