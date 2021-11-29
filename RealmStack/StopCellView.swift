import SwiftUI

struct StopCellView: View {

    struct ViewModel {
        let index: Int
        let stop: Stop
    }
    let viewModel: ViewModel

    var body: some View {
        HStack {

            if viewModel.stop.isSelected {
                Image(systemName: "star")
            }
            
            Text("\(viewModel.index).")
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(viewModel.stop.street.prefix(10))

                Text(viewModel.stop.city.prefix(10))
                    .foregroundColor(.secondary)
            }
        }

    }
}
