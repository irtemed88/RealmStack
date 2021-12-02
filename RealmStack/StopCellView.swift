import SwiftUI

struct StopCellView: View {

    struct ViewModel {
        let index: Int
        let stop: Stop
        let route: Route
    }
    let viewModel: ViewModel

    var body: some View {
        HStack {
            Text("\(viewModel.index).")
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(viewModel.stop.street.prefix(10))

                Text(viewModel.stop.city.prefix(10))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if viewModel.stop.count > 1 {
                Text("\(viewModel.stop.count) Packages")
            }
            
            if viewModel.route.selectedStopID == viewModel.stop._id {
                Image(systemName: "star")
            }
        }
    }
}
