# Security

## Security objectives

AntiTheft must ensure that only an authenticated owner can issue commands to an enrolled device, that a captured command cannot be replayed, and that status reporting distinguishes transport events from device execution.

## Trust boundaries

- The browser and mobile app are untrusted clients.
- Firebase ID tokens establish identity but do not establish device ownership by themselves.
- FastAPI is the policy enforcement point for ownership, rate limits, command expiry, and audit events.
- FCM/APNs delivery is an untrusted, non-guaranteed transport signal.
- Android/iOS are the authority on whether playback is permitted.

## Planned controls

- Verify short-lived Firebase ID tokens server-side.
- Enroll devices using a one-time, expiring challenge and bind a rotated device credential.
- Store mobile credentials in Keychain/Keystore-backed secure storage.
- Require ownership checks on every device read and command write.
- Assign command UUIDs, expiry timestamps, idempotency keys, and an allowed state transition policy.
- Record redacted audit events for enrollment, token rotation, command request, provider dispatch, acknowledgment, execution, failure, expiry, and revocation.
- Rate-limit by owner, device, command type, and network signal without using IP address as identity.
- Exclude credentials, push tokens, raw authorization headers, personal audio, and detailed device identifiers from logs.

## Command state integrity

Allowed states are `QUEUED`, `SENT`, `ACKNOWLEDGED`, `EXECUTED`, `FAILED`, and `EXPIRED`. `SENT` means the push provider accepted a message; it never means the siren played. Device acknowledgments must be authenticated. Terminal states cannot return to an earlier state.

## Secret handling

- Commit only `.env.example` files with non-production placeholders.
- Use a secrets manager for Firebase service accounts, APNs keys, database credentials, and session secrets.
- Never prefix secrets with `NEXT_PUBLIC_`.
- Use HTTPS outside isolated local development.
- Rotate device credentials and revoke them independently from owner sessions.

## Abuse and privacy

The product is limited to devices the owner has enrolled. It does not perform location tracking in the MVP. Revocation must disable future commands. Audit retention and account deletion periods must be defined before production. Remote siren rate limits and confirmation UX must reduce harassment and accidental activation.

## Reporting vulnerabilities

Do not open a public issue containing exploit details, tokens, or personal data. Establish a private security contact and disclosure process before public release.

