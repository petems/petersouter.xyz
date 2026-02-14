# Spec 005: Replace go3up with hugo deploy

## Summary

Replace the Docker-based `go3up` S3 upload tool with Hugo's built-in `hugo deploy` command, simplifying the CI pipeline and eliminating an external dependency.

## Motivation

The current deployment pipeline uses a Docker container (`petems/go3up`) to upload the built site to S3. Hugo v0.65.0 introduced a built-in `deploy` command that can push directly to S3, GCS, or Azure Blob Storage with differential sync and CloudFront cache invalidation.

**Current approach drawbacks:**
- Requires pulling a Docker image on every deploy
- Relies on a custom Docker image (`petems/go3up`) that must be maintained
- Needs a separate cache file (`.go3up.txt`) managed via GitHub Actions cache
- Adds ~30s overhead for Docker pull/run
- The `.go3up.json` config file is an additional artifact to maintain

**`hugo deploy` advantages:**
- Built into Hugo -- no additional tools needed
- Native S3 differential sync (compares local vs remote by MD5)
- Built-in CloudFront cache invalidation
- Configuration lives in the Hugo config file (single source of truth)
- Safety limit of 256 max deletes by default (prevents accidental wipes)
- Works with the existing OIDC temporary credentials

## Current State

**`.github/workflows/deploy.yml:79-88`:**
```yaml
- name: Upload to S3 using go3up with OIDC credentials
  run: |
    docker run --rm \
      -v $(pwd):/workspace \
      -w /workspace \
      -e AWS_ACCESS_KEY_ID \
      -e AWS_SECRET_ACCESS_KEY \
      -e AWS_SESSION_TOKEN \
      petems/go3up \
      /usr/local/bin/go3up -source="$SOURCE_DIR" -region="$S3_REGION" -bucket="$S3_BUCKET" --verbose
```

**`.go3up.json`** -- separate deployment config
**`.go3up.txt`** -- cache file for incremental uploads (managed via `actions/cache`)

## Proposed Changes

### 1. Add deployment config to Hugo config

```toml
[deployment]
  [[deployment.targets]]
    name = "production"
    URL = "s3://petersouter.xyz?region=eu-west-1"
    # Uncomment and set if you want automatic CDN cache invalidation:
    # cloudFrontDistributionID = "EXXXXXXXXXX"

  # Long-lived static assets: aggressive caching
  [[deployment.matchers]]
    pattern = "^.+\\.(js|css|png|jpg|jpeg|gif|svg|webp|ico|ttf|woff|woff2|eot)$"
    cacheControl = "max-age=31536000, public, immutable"
    gzip = true

  # HTML pages: short cache, always revalidate
  [[deployment.matchers]]
    pattern = "^.+\\.(html)$"
    cacheControl = "max-age=0, must-revalidate, public"
    gzip = true

  # XML/JSON feeds and data: moderate cache
  [[deployment.matchers]]
    pattern = "^.+\\.(xml|json)$"
    cacheControl = "max-age=3600, public"
    gzip = true
```

### 2. Simplify the GitHub Actions workflow

```diff
      - name: Build site
        run: hugo --destination "$SOURCE_DIR" --minify

-     # go3up configuration files (.go3up.json, .go3up.txt) are in repository root
-     # and will be automatically discovered by go3up
-
-     - name: Restore go3up cache
-       uses: actions/cache@v5
-       with:
-         path: .go3up.txt
-         key: go3up-cache-${{ github.sha }}
-         restore-keys: |
-           go3up-cache-
-
      - name: Configure AWS credentials via OIDC
        uses: aws-actions/configure-aws-credentials@v5
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ env.S3_REGION }}
          role-session-name: github-actions-deploy-${{ github.run_id }}

-     - name: Upload to S3 using go3up with OIDC credentials
-       run: |
-         docker run --rm \
-           -v $(pwd):/workspace \
-           -w /workspace \
-           -e AWS_ACCESS_KEY_ID \
-           -e AWS_SECRET_ACCESS_KEY \
-           -e AWS_SESSION_TOKEN \
-           petems/go3up \
-           /usr/local/bin/go3up -source="$SOURCE_DIR" -region="$S3_REGION" -bucket="$S3_BUCKET" --verbose
-
-     - name: Save go3up cache
-       uses: actions/cache/save@v5
-       if: always()
-       with:
-         path: .go3up.txt
-         key: go3up-cache-${{ github.sha }}
+     - name: Deploy to S3
+       run: hugo deploy --maxDeletes -1
```

### 3. Clean up go3up artifacts

```bash
rm .go3up.json
# .go3up.txt is in .gitignore (or generated at runtime) -- verify and remove if tracked
```

## Files Affected

| File | Change |
|---|---|
| `hugo.toml` (or `config.toml`) | Add `[deployment]` section |
| `.github/workflows/deploy.yml` | Replace go3up Docker steps with `hugo deploy` |
| `.go3up.json` | Delete |
| `.go3up.txt` | Delete (if tracked) |

## Effort Estimate

Medium -- config changes plus CI workflow update. Should be testable with a `--dryRun` flag first.

## Risks

- **IAM permissions**: The existing OIDC IAM role must have `s3:ListBucket`, `s3:GetObject`, `s3:PutObject`, and `s3:DeleteObject` permissions. `go3up` likely required the same, so this should already be in place.
- **Cache-Control headers**: `go3up` may have been setting different cache headers. The new `deployment.matchers` config should be reviewed to match the desired caching strategy.
- **Max deletes safety**: `hugo deploy` defaults to 256 max deletes per invocation. Using `--maxDeletes -1` removes this limit. For safety during initial migration, consider leaving the default and only increasing after verification.
- **CloudFront invalidation**: If not configured, the CDN cache will expire naturally based on TTL. Adding the `cloudFrontDistributionID` requires the IAM role to have `cloudfront:CreateInvalidation` permission.

## Validation

```bash
# Dry run to see what would be uploaded/deleted
hugo deploy --dryRun

# Deploy for real (first time, with delete safety limit)
hugo deploy --maxDeletes 10

# Verify the site is accessible
curl -I https://petersouter.xyz

# Check S3 object metadata (cache-control headers)
aws s3api head-object --bucket petersouter.xyz --key index.html
```

## References

- [Hugo Deploy Docs](https://gohugo.io/hosting-and-deployment/hugo-deploy/)
- [Hugo deploy with GitHub Actions to AWS](https://capgemini.github.io/development/Using-GitHub-Actions-and-Hugo-Deploy-to-Deploy-to-AWS/)
