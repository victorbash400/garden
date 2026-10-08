from datetime import datetime, timedelta, timezone
import unittest

from package_macos import validate_profile, validate_manual_bundle


class ProfileValidationTests(unittest.TestCase):
    def test_unexpired_distribution_profile_is_allowed(self):
        validate_profile({
            'ExpirationDate': datetime.now(timezone.utc) + timedelta(days=1),
            'ProvisionsAllDevices': True,
        })

    def test_registered_device_profile_is_rejected(self):
        with self.assertRaises(ValueError):
            validate_profile({
                'ExpirationDate': datetime.now(timezone.utc) + timedelta(days=1),
                'ProvisionedDevices': ['development-mac'],
            })

    def test_expired_distribution_profile_is_rejected(self):
        with self.assertRaises(ValueError):
            validate_profile({
                'ExpirationDate': datetime.now(timezone.utc) - timedelta(days=1),
                'ProvisionsAllDevices': True,
            })

    def test_missing_expiration_is_rejected(self):
        with self.assertRaises(ValueError):
            validate_profile({'ProvisionsAllDevices': True})


class ManualInstallTests(unittest.TestCase):
    def test_profile_free_local_session_build_is_allowed(self):
        validate_manual_bundle({'GardenCredentialMode': 'owner-file'}, {}, False)

    def test_shared_keychain_build_is_rejected(self):
        with self.assertRaises(ValueError):
            validate_manual_bundle({'GardenCredentialMode': 'owner-file'},
                                   {'keychain-access-groups': ['restricted']}, False)

    def test_unmarked_build_is_rejected(self):
        with self.assertRaises(ValueError):
            validate_manual_bundle({}, {}, False)

    def test_profile_is_rejected(self):
        with self.assertRaises(ValueError):
            validate_manual_bundle({'GardenCredentialMode': 'owner-file'}, {}, True)


if __name__ == '__main__':
    unittest.main()
