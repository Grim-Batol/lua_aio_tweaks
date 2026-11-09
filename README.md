# AIO Tweaks

A collection of small quality-of-life tweaks for AIO and TLK. Each script adds one focused improvement that can be enabled and maintained independently.

## Scripts

| Script | Description | What it enables |
| --- | --- | --- |
| `enter_gossip_code.moon` | Adds Enter-key support to gossip code boxes. | Players can submit a code by pressing **Enter** instead of clicking **Accept**. |
| `postbox_open_all.moon` | Adds an **Open all** button to the mailbox. | Collects mail money and attachments with a short delay, skipping GM and COD mail. |

More tweaks will be listed here as they are added.

## Build and releases

The GitHub Actions workflow compiles every `.moon` file in the repository root to Lua 5.1, checks the generated Lua files, and packages them into a ZIP archive. Each workflow run uploads the archive as a downloadable artifact. Every push to `main` also updates the **Latest build** release and its ZIP on the repository page.

To publish a separate versioned GitHub Release with its own archive, push a version tag that starts with `v`, such as `v1.0.0`.

The repository's GitHub Actions workflow permissions must allow read and write access to repository contents so the workflow can update the `latest` tag and release.
