# Garden macOS preview

This is the standard Garden build connected to the hosted backend. Email signup requires the verification code sent to your inbox. There is no separate judge authentication mode.

## Install

Download the DMG, copy Garden.app to Applications and launch it there. Follow INSTALL.txt in the disk image. If macOS blocks it, use System Settings > Privacy & Security > Open Anyway. This preview uses Apple Development signing and is not notarized. It does not contain a device-restricted provisioning profile. No Flutter, Xcode, Apple Developer registration or local backend is needed to run it.

Finder mounting requires macOS 15.4 or later, macFUSE and approval for its File System Extension and Garden background activity. The account setup modal links to the required controls. Garden browsing and account setup are available before mounting.

## Authentication and deletion

Serverpod provides hosted email authentication and verification. Cloud file bytes use the configured S3 storage. Ordinary app and Finder sessions are stored in private files under Application Support with owner-only permissions, rather than Keychain. Software running as your Mac user can access them; sign out when finished. Touch ID session storage is unavailable in this build. Passkey setup still requires compatible Apple signing; use email/password for this preview.

Settings > Account > Delete account requires your email as confirmation. Successful deletion removes owned drives and their cloud objects, aborts pending multipart uploads, removes identity and revokes authentication. The email is then reusable. Files in drives owned by other people remain. If cloud cleanup fails, deletion is resumable and the email is retained until cleanup succeeds.

## Validation on 8 October 2026

- Hosted ordinary email signup, verification, password login and drive creation passed.
- A disposable account uploaded cloud data, started a pending multipart upload and was deleted. Cloud reads and pending upload writes subsequently returned 404; its old session and password login were rejected. Ordinary signup with the same email passed again.
- Installed the disk image into /Applications and launched the standard app. Setup links, ordered checklist and drive creation passed. Its signed helper mounted a fresh drive. PNG, MP4, WAV and Markdown files saved through that mount matched independent backend reads byte for byte. The PNG opened in Preview and the MP4 opened in QuickTime.
- Native private-file storage, frontend account deletion and backend deletion failure/retry tests passed. Release bundle signatures and disk-image verification passed.
- Published v0.1.0-preview.1, downloaded its actual GitHub assets, verified SHA256SUMS.txt and the DMG checksum, installed that download and relaunched with the saved account. All four setup checklist steps showed Done; the deletion confirmation was inspected and cancelled.

This machine already had macFUSE installed and approved. Approval on a second, clean Mac is not verified. Existing development builds can leave an older helper registered; quit development builds before testing the release. Do not force-unmount a drive with unsaved changes.
