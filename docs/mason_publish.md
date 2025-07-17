# Mason Publish

We use this workflow to publish a brick to [brickhub.dev](https://brickhub.dev/).

## Steps

The Mason Publish workflow consists of the following steps:

1. **Git Checkout** - Checkout the repository code
2. **Setup Dart** - Install and configure Dart SDK
3. **Install Mason** - Install Mason CLI globally
4. **Setup Mason Credentials** - Configure authentication for publishing
5. **Dry Run** - Validate the brick before publishing
6. **Publish** - Publish the brick to brickhub.dev

## Inputs

### `working_directory`

**Optional** The path to the root of the Mason brick.

**Default:** `"."`

### `mason_version`

**Optional** Which Mason version to use (e.g. `0.1.0-dev.50`). If not specified, the latest version will be installed.

**Default:** `""`

### `dart_sdk`

**Optional** The Dart SDK version to use.

**Default:** `"stable"`

### `runs_on`

**Optional** An optional operating system on which to run the workflow.

**Default:** `"ubuntu-latest"`

### `timeout_minutes`

**Optional** The maximum time in minutes to allow the workflow to run.

**Default:** `10`

## Secrets

### `mason_credentials`

**Required** The mason credentials needed for publishing.

#### How to obtain Mason credentials:

1. **Login to Mason** first by running:
   ```bash
   mason login
   ```

2. **Find your credentials file** in the following locations:

   | Operating System | Location |
   |------------------|----------|
   | **macOS** | `~/Library/Application\ Support/mason/mason-credentials.json` |
   | **Linux** | `~/.config/mason/mason-credentials.json` |
   | **Windows** | `%APPDATA%/mason/mason-credentials.json` |

3. **Read the credentials file**:
   ```bash
   # For macOS:
   cat ~/Library/Application\ Support/mason/mason-credentials.json
   
   # For Linux:
   cat ~/.config/mason/mason-credentials.json
   
   # For Windows:
   type %APPDATA%/mason/mason-credentials.json
   ```

4. **Copy the entire JSON content** and add it as a secret in your GitHub repository:
   - Go to your repository **Settings**
   - Navigate to **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Name: `MASON_CREDENTIALS`
   - Value: Paste the entire JSON content from the credentials file

{
#### Example credentials file content:
```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsIYTBhNDRlM2RmY2RhMTM4Mzc3NDU5Zjli...",
  "refresh_token": "AMf-vByrMFQa7HBaIcRyIdbkiCeKEFdsYYIxoVnBAYEkumm3hn0i...",
  "expires_at": "2025-07-16T19:15:37.444356Z",
  "token_type": "Bearer"
}
```

**Note:** This is the actual format of Mason credentials. The entire JSON object should be copied exactly as it appears in your credentials file.

## Example Usage

We recommend using [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) for safely storing and reading the credentials.

### Basic usage:
```yaml
name: Publish Mason Brick

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    uses: egortabula/egortabula_workflows/.github/workflows/mason_publish.yml@v1
    secrets:
      mason_credentials: ${{ secrets.MASON_CREDENTIALS }}
```

### Advanced usage with custom settings:
```yaml
name: Publish Mason Brick

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    uses: egortabula/egortabula_workflows/.github/workflows/mason_publish.yml@v1
    with:
      working_directory: 'packages/my_mason_brick'
      mason_version: '0.1.0-dev.50'
      dart_sdk: 'stable'
      runs_on: 'ubuntu-latest'
      timeout_minutes: 15
    secrets:
      mason_credentials: ${{ secrets.MASON_CREDENTIALS }}
```

## Troubleshooting

### Common Issues:

1. **Authentication failed**
   - Ensure your `mason_credentials` secret contains valid JSON
   - Verify you're logged in to Mason CLI locally before extracting credentials
   - Check that the token hasn't expired

2. **Brick validation failed**
   - Ensure your `brick.yaml` file is properly configured
   - Check that all required files are present
   - Verify the brick structure follows Mason conventions

3. **Credentials file not found**
   - Run `mason login` first to generate the credentials file
   - Check the correct path for your operating system
   - Ensure you have proper permissions to read the file

### Notes:

- The workflow uses `~/.config/mason/mason-credentials.json` path internally, which works reliably across different Linux distributions
- The `mason publish --dry-run` step helps catch issues before actual publishing
- The workflow will fail fast if credentials are invalid or missing
