# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated testing and deployment.

## Workflows

### test.yml - Continuous Testing

**Triggers:**
- Push to `master` branch
- Pull requests targeting `master` branch

**What it does:**
1. Checks out the code
2. Sets up Node.js 20 with npm caching
3. Installs dependencies (`npm ci`)
4. Runs Jest tests (`npm test`)
5. Generates coverage report (`npm run test:coverage`)
6. Uploads coverage to Codecov (on master branch pushes)

**Purpose:** Ensures all JavaScript tests pass before code is merged or deployed. This validates the talks page filtering logic works correctly.

### deploy.yml - Production Deployment

**Triggers:**
- Push to `master` branch only

**What it does:**
1. **Test Job:**
   - Runs Jest tests to ensure code quality
   - Blocks deployment if tests fail

2. **Build and Deploy Job** (runs after test job passes):
   - Checks out code with submodules
   - Sets up Hugo 0.155.3
   - Builds the static site
   - Configures AWS credentials via OIDC
   - Uploads to S3 using go3up
   - Caches go3up state for faster future deployments

**Purpose:** Deploys the website to production (S3/CloudFront) only after tests pass.

### deploy-vercel-preview.yml - Preview Deployments

**Triggers:**
- Pull requests

**What it does:**
- Deploys preview versions of the site to Vercel
- Allows reviewing changes before merging

### compress-images-cron.yml - Image Optimization

**Triggers:**
- Scheduled (cron)
- Manual workflow dispatch

**What it does:**
- Compresses images to reduce file sizes
- Improves site performance

### calibreapp-image-actions.yml - Image Optimization

**Triggers:**
- Pull requests with image changes

**What it does:**
- Automatically optimizes images in pull requests
- Uses Calibre Image Actions

## Test Configuration

The test workflows use:
- **Node.js 20**: LTS version for stability
- **npm ci**: Clean install for reproducible builds
- **Jest**: JavaScript testing framework
- **Coverage reporting**: Tracks code coverage over time

## Secrets Required

### AWS Deployment
- `AWS_ROLE_ARN`: IAM role ARN for OIDC authentication to AWS
  - Example: `arn:aws:iam::ACCOUNT_ID:role/petersouter-website-github-actions-role`
  - Configured in repository secrets

### Optional
- `CODECOV_TOKEN`: Token for uploading coverage reports to Codecov
  - Only needed if Codecov is configured
  - Coverage upload continues even if this fails

## Testing Locally

You can run the same tests that CI runs:

```bash
# Install dependencies
npm ci

# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode (development)
npm run test:watch
```

## Debugging Failed Workflows

### Test Failures

1. Check the "Run Jest tests" step output in the Actions tab
2. Look for which specific test failed
3. Run the test locally: `npm test`
4. Fix the issue and push again

### Deployment Failures

1. Check if tests passed (they run first)
2. Check AWS credentials are valid
3. Check S3 bucket permissions
4. Review go3up logs in the deployment step

## CI Best Practices

✅ **Tests run on every PR** - Catches issues early
✅ **Tests block deployment** - Prevents broken code in production
✅ **Fast feedback** - Tests complete in ~30 seconds
✅ **Cached dependencies** - npm packages cached for speed
✅ **Coverage tracking** - Monitors test coverage over time

## Adding New Tests

When you add new JavaScript functionality:

1. Write tests in `tests/` directory
2. Run tests locally: `npm test`
3. Create a pull request
4. CI will automatically run tests
5. Tests must pass before merging
6. Deployment to production runs tests again as final check

## Workflow Dependencies

```
test.yml (PR/Push)
   ↓
deploy.yml (Master only)
   ├─→ test (job)
   └─→ build-and-deploy (job, needs: test)
```

The `deploy.yml` workflow ensures tests pass before deploying, providing two layers of protection:
1. Tests run on PRs before merging
2. Tests run again before production deployment

## Status Badges

You can add status badges to your README:

```markdown
![Tests](https://github.com/petems/petersouter.xyz/workflows/Run%20Tests/badge.svg)
![Deploy](https://github.com/petems/petersouter.xyz/workflows/Deploy%20to%20S3/badge.svg)
```

## Monitoring

- **GitHub Actions tab**: View all workflow runs
- **Pull request checks**: See test status on PRs
- **Email notifications**: Get notified of failures (configure in GitHub settings)
- **Codecov dashboard**: Track coverage trends over time
