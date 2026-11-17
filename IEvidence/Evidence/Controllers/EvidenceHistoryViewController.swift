
import UIKit

class EvidenceHistoryViewController: UIViewController {

    // MARK: - Properties

    var caseNumber: String = ""

    private var historyRecords: [ChainOfCustodyModel] = []

    private let tableView = UITableView()

    private let emptyLabel = UILabel()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Evidence History"
        view.backgroundColor = .systemGroupedBackground

        setupUI()
        setupConstraints()
        loadHistory()
    }

    // MARK: - UI Setup

    private func setupUI() {

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "HistoryCell"
        )

        tableView.backgroundColor = .clear

        view.addSubview(tableView)

        emptyLabel.text = "No history records available."
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyLabel)
    }

    // MARK: - Constraints

    private func setupConstraints() {

        NSLayoutConstraint.activate([

            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            emptyLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),

            emptyLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            )
        ])
    }

    // MARK: - Load History

    private func loadHistory() {

        historyRecords = ChainOfCustodyStorage.shared
            .fetchRecords(forCaseNumber: caseNumber)

        emptyLabel.isHidden = !historyRecords.isEmpty

        tableView.reloadData()
    }

    // MARK: - Format Date

    private func formattedDate(_ date: Date) -> String {

        let formatter = DateFormatter()

        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return formatter.string(from: date)
    }
}

// MARK: - Table View

extension EvidenceHistoryViewController:
    UITableViewDataSource,
    UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        return historyRecords.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryCell",
            for: indexPath
        )

        let record = historyRecords[indexPath.row]

        var content = cell.defaultContentConfiguration()

        content.text = record.action

        content.secondaryText = """
        Performed by: \(record.performedBy)
        Date: \(formattedDate(record.date))
        Details: \(record.details)
        """

        content.secondaryTextProperties.numberOfLines = 0

        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }
}
