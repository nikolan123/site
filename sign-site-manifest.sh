#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <private-key-id|fingerprint|email|secret-key-file.asc>" >&2
  exit 1
fi

KEY_INPUT="$1"
KEY_ID="$KEY_INPUT"
MANIFEST_HTML=".well-known/site-manifest.html"
SIGNATURE=".well-known/site-manifest.html.asc"
FILES=(
  "index.html"
  "style.css"
  "games.js"
  "videobg.js"
  ".well-known/pgp-key.txt"
)

commit="$(git rev-parse --short=12 HEAD 2>/dev/null || echo unknown)"
generated="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
verify_cmd='gpg --verify site-manifest.html.asc site-manifest.html'

for f in "${FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing required file: $f" >&2
    exit 1
  fi
done

if [[ -f "$KEY_INPUT" ]]; then
  if ! gpg --batch --yes --import "$KEY_INPUT"; then
    echo "Failed to import secret key file: $KEY_INPUT" >&2
    exit 1
  fi
  imported_fpr="$(gpg --batch --with-colons --import-options show-only --import "$KEY_INPUT" | awk -F: '$1=="fpr"{print $10; exit}')"
  if [[ -z "$imported_fpr" ]]; then
    echo "Could not detect fingerprint from key file: $KEY_INPUT" >&2
    exit 1
  fi
  KEY_ID="$imported_fpr"
fi

rows=""
for f in "${FILES[@]}"; do
  sum="$(shasum -a 256 "$f" | awk '{print $1}')"
  rows+="            <tr><td><code>${f}</code></td><td><code>${sum}</code></td></tr>\n"
done

cat > "$MANIFEST_HTML" <<HTML
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Signed Site Manifest - Niko</title>
    <link rel="stylesheet" href="/style.css">
</head>

<body>
    <p><a href="/">Back to homepage</a></p>
    <h1>Signed Site Manifest</h1>
    <p>Download this HTML page, its <code>.asc</code> signature, and my public key. Then run the import and verify commands below. If GPG says the signature is good, this version of my website was signed by my key and the checksums here can be trusted.</p>

    <div class="identity-card">
        <h3 class="section-title">Manifest Metadata</h3>
        <p class="identity-tech"><b>Generated (UTC):</b> <code>${generated}</code></p>
        <p class="identity-tech"><b>Commit:</b> <a href="https://github.com/nikolan123/site/commit/${commit}"><code>${commit}</code></a></p>
        <p class="identity-tech"><b>Signing key input:</b> <code>${KEY_ID}</code></p>
        <div class="identity-links">
            <a class="identity-download" href="/.well-known/site-manifest.html" download="site-manifest.html">Download This HTML Manifest</a>
            <a class="identity-download" href="/.well-known/site-manifest.html.asc" download="site-manifest.html.asc">Download HTML Signature</a>
            <a class="identity-download" href="/.well-known/pgp-key.txt" download="nikolan-pub.asc">Download PGP Public Key</a>
        </div>
    </div>

    <div class="identity-card">
        <h3 class="section-title">SHA256 Checksums</h3>
        <table class="manifest-table">
            <thead>
                <tr>
                    <th>File</th>
                    <th>SHA256</th>
                </tr>
            </thead>
            <tbody>
$(printf "%b" "$rows")
            </tbody>
        </table>
    </div>

    <div class="identity-card">
        <h3 class="section-title">Import Key</h3>
        <p class="identity-tech"><code>gpg --import nikolan-pub.asc</code></p>
    </div>

    <div class="identity-card">
        <h3 class="section-title">Verify Signature</h3>
        <p class="identity-tech"><code>${verify_cmd}</code></p>
    </div>
</body>

</html>
HTML

if ! gpg --list-secret-keys "$KEY_ID" >/dev/null 2>&1; then
  echo "No secret key found for: $KEY_INPUT" >&2
  echo "Generated $MANIFEST_HTML but could not sign it." >&2
  exit 1
fi

gpg --batch --yes --armor \
  --local-user "$KEY_ID" \
  --output "$SIGNATURE" \
  --detach-sign "$MANIFEST_HTML"

echo "Wrote $MANIFEST_HTML"
echo "Wrote $SIGNATURE"
echo "Done. Publish the HTML manifest and detached signature."
