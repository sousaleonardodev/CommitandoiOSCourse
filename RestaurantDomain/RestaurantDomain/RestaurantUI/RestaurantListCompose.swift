//

import Foundation
import RestaurantDomain

final class RestaurantListCompose {
	static func compose(service: RestaurantLoader) -> RestaurantListViewController {
		let refreshController = RefreshController(service: service)
		let controller = RestaurantListViewController(refreshController: refreshController)

		refreshController.onRefresh = adaptRestaurantItemToCellController(controller: controller)

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
