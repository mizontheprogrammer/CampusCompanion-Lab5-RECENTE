import UIKit

private enum DefaultsKey {
    static let studentName = "studentName"
    static let notificationsEnabled = "notificationsEnabled"
    static let selectedRoleIndex = "selectedRoleIndex"
}

class ViewController: UIViewController {

    @IBOutlet private weak var campusImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var notifySwitch: UISwitch!
    @IBOutlet private weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var eventDatePicker: UIDatePicker!
    @IBOutlet private weak var guestStepper: UIStepper!
    @IBOutlet private weak var guestCountLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Campus Companion"
        titleLabel.text = "Campus Companion"
        // Exact sRGB blue sampled from the supplied reference image.
        let referenceBlue = UIColor(red: 0, green: 148.0 / 255.0, blue: 1, alpha: 1)
        view.tintColor = referenceBlue
        campusImageView.backgroundColor = referenceBlue
        campusImageView.layer.cornerRadius = 45
        campusImageView.clipsToBounds = true
        campusImageView.tintColor = .white
        campusImageView.image = UIImage(systemName: "graduationcap.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 48, weight: .regular))?
            .withAlignmentRectInsets(.zero)
        campusImageView.contentMode = .center
        nameTextField.layer.borderWidth = 0.5
        nameTextField.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 1))
        nameTextField.leftViewMode = .always
        campusImageView.accessibilityLabel = "Graduation cap"
        eventDatePicker.minimumDate = Calendar.current.startOfDay(for: Date())
        guestStepper.minimumValue = 0
        guestStepper.maximumValue = 10
        guestStepper.stepValue = 1
        guestStepper.value = max(0, guestStepper.value)
        updateGuestCountLabel()

        nameTextField.text = UserDefaults.standard.string(forKey: DefaultsKey.studentName) ?? ""
        notifySwitch.isOn = UserDefaults.standard.bool(forKey: DefaultsKey.notificationsEnabled)
        roleSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(
            forKey: DefaultsKey.selectedRoleIndex
        )
    }

    @IBAction private func getStartedButtonTapped(_ sender: UIButton) {
        subtitleLabel.text = "Let's get started!"
    }

    @IBAction private func guestStepperChanged(_ sender: UIStepper) {
        updateGuestCountLabel()
    }

    @IBAction private func resetPreferencesButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: DefaultsKey.studentName)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.removeObject(forKey: DefaultsKey.selectedRoleIndex)

        nameTextField.resignFirstResponder()
        nameTextField.text = ""
        notifySwitch.isOn = false
        roleSegmentedControl.selectedSegmentIndex = 0
        subtitleLabel.text = "Your Campus, In Your Pocket"
    }

    @IBAction private func exploreButtonTapped(_ sender: UIButton) {
        nameTextField.resignFirstResponder()

        let enteredName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        UserDefaults.standard.set(enteredName, forKey: DefaultsKey.studentName)
        UserDefaults.standard.set(notifySwitch.isOn, forKey: DefaultsKey.notificationsEnabled)
        UserDefaults.standard.set(
            roleSegmentedControl.selectedSegmentIndex,
            forKey: DefaultsKey.selectedRoleIndex
        )

        performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowDetailSegue",
              let destination = segue.destination as? DetailViewController else {
            return
        }

        let enteredName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        destination.studentName = enteredName.isEmpty ? "Student" : enteredName
        destination.notificationsEnabled = notifySwitch.isOn
        destination.selectedRole = roleSegmentedControl.selectedSegmentIndex == 0
            ? "Student"
            : "Faculty"
        destination.preferredEventDate = eventDatePicker.date
        destination.numberOfGuests = max(0, Int(guestStepper.value))
    }

    private func updateGuestCountLabel() {
        let count = max(0, Int(guestStepper.value))
        guestCountLabel.text = "Guests: \(count)"
    }
}
