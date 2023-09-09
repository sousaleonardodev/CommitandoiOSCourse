//

import Foundation
import RestaurantDomain

final class RestaurantListCompose {
	static func compose(service: RestaurantLoader) -> RestaurantListViewController {
		let viewModel = RestaurantListViewModel(service: service)
		let refreshController = RefreshController(viewModel: viewModel)
		let controller = RestaurantListViewController(refreshController: refreshController)

		viewModel.onRestaurantItem = adaptRestaurantItemToCellController(controller: controller)

		return controller
	}

	static func adaptRestaurantItemToCellController(controller: RestaurantListViewController)  -> ([RestaurantItem]) -> Void {
		return { [weak controller] items in
			controller?.restaurantCollection = items.map { item in
				RestaurantItemCellController(viewModel: item)
			}
		}
	}
}
