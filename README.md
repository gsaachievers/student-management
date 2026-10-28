# GrowStrong Achievers — Student Management

Weekly student scheduler for Lucknow and Noida, Monday–Sunday, 10 AM–8 PM in one-hour slots. Click a slot to see students. Staff share a dedicated Supabase Auth email/password.

## Student registration

Register a student once with name, age, and their usual batch. Use “Additional batch (optional)” for exceptions. To add batches later, select the existing student in the Student dropdown. Removing a batch keeps the student record, which remains available in that dropdown. Identical selected slots are combined. Same-name students can be registered separately after confirmation.

## Activate the app

1. Create a dedicated staff user in Supabase Authentication → Users. Keep their email/password private.
2. Replace `REPLACE_WITH_STAFF_USER_UUID` in `supabase.sql` with that user's UUID. Run the entire script in Supabase SQL Editor. The script runs in a transaction and is safe to rerun for this schema. It creates new tables; it does not migrate the old single-batch table or merge any existing students automatically.
3. Enter the Supabase project URL and publishable/anon key in `config.js`. Never put a staff password or service-role/secret key in GitHub.
4. Open GitHub repository Settings → Pages. Select “Deploy from a branch”, `main`, `/ (root)`, then Save.
5. Open https://gsaachievers.github.io/student-management/ after Pages finishes deploying and sign in using the dedicated staff account.

GitHub Pages serves public application code. Student records remain behind Supabase authentication and row-level policies restricted to the allowlisted staff account. Unrelated authenticated accounts cannot read or change students. The account itself cannot add staff memberships. Both centers are available to the shared account.

Changes load when signing in, switching centers, and saving. Reload to see changes from other devices. Concurrent batch edits are rejected rather than overwriting another device's update. This is a recurring timetable, not dated attendance. Staff share one identity, so changes are not attributable to individual staff.

## Validation

JavaScript syntax and timetable/batch behavior can be checked locally. Database setup, login and shared-device persistence require your Supabase configuration and must be verified after activation. No student data or credentials are included in this repository.
