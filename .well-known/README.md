# `.well-known/` — App Link domain verification

These two files are how iOS and Android verify that `offunit.app` and the OFFUNIT
app belong to the same owner. Without them, a shared post link opens the website
instead of the app, no matter what `app.json` declares.

Both are served as static files by GitHub Pages. **`.nojekyll` at the repo root is
load-bearing** — Jekyll skips directories beginning with a dot, so without it this
entire folder is silently never published.

## Both values are filled in (21 Sep 2026)

### `apple-app-site-association`
Team ID `M2YNC96YX8`, from developer.apple.com/account → Membership details, giving
`M2YNC96YX8.com.mabulayla.offunit`. Both `ios.bundleIdentifier` and `android.package`
in `frontend/app.json` are `com.mabulayla.offunit`, so one identifier covers both files.

Apple requirements that are easy to get wrong:
- **No file extension.** Not `.json`.
- Must be served as `application/json`. GitHub Pages does not set this for an
  extensionless file, so **verify after deploying** (see below). If the content
  type is wrong, host these two files behind Cloudflare instead — the same
  workaround already used for `media.offunitcdn.com`.
- **No redirects.** Apple's fetcher does not follow them, so `www` → apex or
  `http` → `https` on this path will fail verification silently.

### `assetlinks.json`
The fingerprint here starts `C1:75:CB:95:` and is the **Play App Signing**
certificate, not the EAS upload key. Google re-signs the app after upload, so the
upload key's fingerprint verifies nothing — and on this app the two genuinely
differ, the upload key being the one that starts `A3:E5:72:C2:`. Putting that
second one here would fail verification while looking entirely plausible.

It was taken from the **Digital Asset Links JSON** snippet that Play Console
generates on the App signing page (Test and release → Setup → App integrity), which
is the unambiguous source: Play builds that snippet from the app signing key itself.

## Verifying after deploy

```
curl -sI https://offunit.app/.well-known/apple-app-site-association | grep -i content-type
curl -s  https://offunit.app/.well-known/assetlinks.json
```

Google also publishes a checker:
`https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://offunit.app&relation=delegate_permission/common.handle_all_urls`

Note both files must be live **before** users install the build that declares the
domains — iOS caches the association at install time.
