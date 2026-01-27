# GitHub Actions AWS Credentials for S3 Website Deployment

This Terraform configuration creates secure AWS credentials for GitHub Actions to deploy a static website to S3.

## Security Improvements

### 🔐 OIDC (OpenID Connect) Authentication
- **No long-lived access keys** - Uses temporary credentials via OIDC
- **Repository-scoped access** - Only works for the specified GitHub repository
- **Automatic credential rotation** - Credentials are generated fresh for each workflow run

### 🛡️ Least Privilege Principle
- **Minimal S3 permissions** - Only the actions needed for website deployment
- **Optional CloudFront invalidation** - Separate policy for CDN cache invalidation
- **Resource-specific access** - Limited to specific S3 bucket

## Architecture

```
GitHub Actions → OIDC Provider → IAM Role → S3 Bucket
```

1. **GitHub OIDC Provider** - Trusted identity provider for GitHub Actions
2. **IAM Role** - Assumes temporary credentials with specific permissions
3. **IAM Policies** - Define exact permissions for S3 deployment

## Usage

### 1. Deploy the Terraform Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 2. Configure GitHub Actions Workflow

Add this to your `.github/workflows/deploy.yml`:

```yaml
name: Deploy to S3

on:
  push:
    branches: [ main ]

permissions:
  id-token: write   # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: eu-west-1
      
      - name: Build website
        run: |
          # Your build commands here
          npm run build
      
      - name: Deploy to S3
        run: |
          aws s3 sync dist/ s3://petersouter.xyz --delete
          
          # Optional: Invalidate CloudFront cache
          if [ -n "$CLOUDFRONT_DISTRIBUTION_ID" ]; then
            aws cloudfront create-invalidation \
              --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
              --paths "/*"
          fi
        env:
          CLOUDFRONT_DISTRIBUTION_ID: ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }}
```

### 3. Set GitHub Secrets

Add these secrets to your GitHub repository:

- `AWS_ROLE_ARN`: The ARN of the IAM role (output from Terraform)
- `CLOUDFRONT_DISTRIBUTION_ID`: Your CloudFront distribution ID (if using CDN)

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for resources | `eu-west-1` |
| `s3_bucket_name` | S3 bucket name | `petersouter.xyz` |
| `project_name` | Project name for resource naming | `petersouter-website` |
| `environment` | Environment name | `production` |
| `github_repository` | GitHub repo in format `owner/repo` | `petersouter/petersouter.xyz` |
| `enable_cloudfront_invalidation` | Enable CloudFront invalidation | `false` |
| `cloudfront_distribution_id` | CloudFront distribution ID | `""` |

## Outputs

- `github_actions_role_arn`: ARN of the IAM role for GitHub Actions
- `github_actions_role_name`: Name of the IAM role

## Permissions Granted

### S3 Permissions
- `s3:ListBucket` - List bucket contents
- `s3:GetBucketLocation` - Get bucket region
- `s3:PutObject` - Upload files
- `s3:PutObjectAcl` - Set object permissions
- `s3:GetObject` - Read files
- `s3:DeleteObject` - Delete files

### Optional CloudFront Permissions
- `cloudfront:CreateInvalidation` - Create cache invalidation
- `cloudfront:GetInvalidation` - Check invalidation status
- `cloudfront:ListInvalidations` - List invalidations

## Migration from CircleCI

### Before (CircleCI with IAM User)
- ❌ Long-lived access keys
- ❌ Manual credential management
- ❌ Broader permissions than needed
- ❌ Security risk if keys are compromised

### After (GitHub Actions with OIDC)
- ✅ Temporary credentials
- ✅ Automatic credential rotation
- ✅ Repository-scoped access
- ✅ Minimal required permissions
- ✅ No credential storage needed

## Security Best Practices

1. **Repository-specific access** - The role only works for the specified GitHub repository
2. **Temporary credentials** - No long-lived access keys to manage or rotate
3. **Least privilege** - Only the minimum permissions needed for deployment
4. **Audit trail** - All access is logged in CloudTrail
5. **Conditional access** - Access is restricted to specific repository and branch patterns

## Troubleshooting

### Common Issues

1. **"Access Denied" errors**
   - Verify the GitHub repository name matches exactly
   - Check that the workflow has `id-token: write` permission

2. **Role assumption fails**
   - Ensure the OIDC provider thumbprints are current
   - Verify the role ARN is correct in GitHub secrets

3. **S3 upload fails**
   - Check that the S3 bucket name is correct
   - Verify the bucket exists and is accessible

### Updating OIDC Thumbprints

GitHub occasionally updates their OIDC provider certificates. To update:

```bash
# Get current thumbprints
curl -s https://token.actions.githubusercontent.com/.well-known/openid_configuration | jq -r '.jwks_uri' | xargs curl -s | jq -r '.keys[].x5c[0]' | base64 -d | openssl x509 -fingerprint -noout
```

Then update the `thumbprint_list` in the OIDC provider resource.
