# Testing Documentation

## Overview

This document describes the testing setup for the petersouter.xyz website, specifically for the conference talks filtering functionality.

## What Was Implemented

### 1. Extracted JavaScript (`static/js/talks-filter.js`)

The JavaScript code for filtering talks was extracted from the inline `<script>` tag in the partial template to a separate file. This provides several benefits:

- **Testability**: Functions can be unit tested in isolation
- **Maintainability**: Easier to update and debug
- **Reusability**: Could be used in other pages if needed
- **Separation of Concerns**: Keeps logic separate from presentation

The extracted code includes:
- `toggleFilterGroup()`: Collapse/expand filter sections
- `toggleFilter()`: Add/remove individual filters
- `clearFilters()`: Reset all active filters
- `shouldShowTalk()`: Core filtering logic (pure function)
- `applyFilters()`: Apply filters to DOM
- Helper functions for testing: `resetFilters()`, `getActiveFilters()`

### 2. Jest Configuration

**Files created:**
- `package.json`: NPM dependencies and test scripts
- `jest.config.js`: Jest configuration with jsdom environment
- `.gitignore`: Updated to ignore `coverage/` directory

**Dependencies installed:**
- `jest`: Testing framework
- `jest-environment-jsdom`: DOM simulation for testing
- `@types/jest`: TypeScript type definitions

### 3. Comprehensive Test Suite (`tests/talks-filter.test.js`)

**30 tests covering:**

#### Core Filtering Logic (11 tests)
- No filters active (show all)
- Single filter types (year, conference, topic)
- Multiple filters with AND logic
- Topic matching (at least one topic must match)
- Whitespace trimming in topics
- Empty topics handling

#### Filter Management (12 tests)
- Adding filters (`toggleFilter`)
- Removing filters (toggle off)
- Multiple filters of same type
- Clearing all filters
- Resetting filter state
- Active/inactive CSS classes

#### DOM Integration (7 tests)
- Showing/hiding talk items
- Updating visible count
- Collapsing/expanding filter groups
- Missing DOM element handling
- Multiple talk filtering combinations

#### Edge Cases (4 tests)
- Empty topic strings
- Special characters (e.g., "CI/CD", "Infrastructure as Code")
- Case sensitivity in filter matching
- Graceful degradation

### 4. Updated Partial Template

`layouts/partials/talks-list.html` now uses:
```html
<script src="/js/talks-filter.js"></script>
```

Instead of inline JavaScript, keeping the template clean and the logic testable.

## Test Results

All 30 tests pass successfully:

```
Test Suites: 1 passed, 1 total
Tests:       30 passed, 30 total
Time:        ~0.4-1.0s
```

### Code Coverage

```
-----------------|---------|----------|---------|---------|-------------------
File             | % Stmts | % Branch | % Funcs | % Lines | Uncovered Line #s
-----------------|---------|----------|---------|---------|-------------------
All files        |     100 |    95.45 |     100 |     100 |
 talks-filter.js |     100 |    95.45 |     100 |     100 | 142
-----------------|---------|----------|---------|---------|-------------------
```

**Excellent coverage:**
- 100% Statement coverage
- 100% Function coverage
- 100% Line coverage
- 95.45% Branch coverage (only the module.exports check is uncovered)

## Running Tests

### Basic Commands

```bash
# Run all tests
npm test

# Run tests in watch mode (for development)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

### Advanced Usage

```bash
# Run specific test file
npx jest talks-filter.test.js

# Run tests matching a pattern
npx jest -t "shouldShowTalk"

# Run with verbose output
npx jest --verbose

# Update snapshots (if using snapshot testing)
npx jest -u
```

## Integration with Hugo

The JavaScript file is served from the `/static/js/` directory, which Hugo automatically copies to the `public/` directory during build.

**Hugo build verification:**
```bash
hugo server
# Site builds successfully with 273 pages in ~557ms
```

## CI/CD Integration

### GitHub Actions (Configured)

Tests are automatically run via GitHub Actions on:
- Every pull request to `master`
- Every push to `master`
- Before production deployments

**Workflows:**
- `.github/workflows/test.yml` - Runs tests on PRs and pushes
- `.github/workflows/deploy.yml` - Runs tests before deployment

See `.github/workflows/README.md` for detailed documentation.

**Status:** Tests run in ~30 seconds and must pass before deployment.

To check test status:
1. Go to the GitHub Actions tab in the repository
2. View the "Run Tests" workflow for PR/push status
3. View the "Deploy to S3" workflow for deployment status

## Test Structure

### Arrange-Act-Assert Pattern

Each test follows a clear structure:

```javascript
it('should do something', () => {
  // Arrange: Set up test data and DOM
  const talkData = {
    year: '2026',
    conference: 'Config Management Camp',
    topics: ['CI/CD', 'Testing']
  };

  // Act: Execute the function
  const result = shouldShowTalk(talkData, filters);

  // Assert: Verify the result
  expect(result).toBe(true);
});
```

### Test Organization

Tests are organized into logical groups:
- `shouldShowTalk`: Core filtering algorithm
- `toggleFilter`: Filter management
- `clearFilters`: Reset functionality
- `applyFilters`: DOM updates
- `toggleFilterGroup`: UI interactions
- `Edge Cases`: Boundary conditions
- `resetFilters`: Test utilities

## Future Enhancements

Potential testing improvements:

1. **E2E Tests**: Add Playwright/Cypress tests for full user workflows
2. **Visual Regression**: Screenshot testing for UI consistency
3. **Performance Tests**: Measure filtering speed with large datasets
4. **Accessibility Tests**: Verify ARIA labels and keyboard navigation
5. **Cross-Browser Tests**: Test in different browsers (via BrowserStack)

## Debugging

### Running Jest in Debug Mode

```bash
# Node.js debugging
node --inspect-brk node_modules/.bin/jest --runInBand

# VS Code launch.json
{
  "type": "node",
  "request": "launch",
  "name": "Jest Debug",
  "program": "${workspaceFolder}/node_modules/.bin/jest",
  "args": ["--runInBand", "--no-cache"],
  "console": "integratedTerminal",
  "internalConsoleOptions": "neverOpen"
}
```

### Common Issues

**Tests fail with DOM errors:**
- Ensure `jest-environment-jsdom` is installed
- Check `testEnvironment: 'jsdom'` in `jest.config.js`

**Module not found errors:**
- Run `npm install` to ensure all dependencies are installed
- Check file paths in `require()` statements

**Coverage is lower than expected:**
- Run `npm run test:coverage` to see detailed coverage report
- Check `coverage/lcov-report/index.html` for visual coverage report

## Maintenance

### Adding New Features

When adding new filtering features:

1. Write the test first (TDD approach)
2. Implement the feature in `static/js/talks-filter.js`
3. Ensure the function is exported for testing
4. Run tests: `npm test`
5. Verify coverage: `npm run test:coverage`
6. Update documentation

### Updating Tests

When changing filter behavior:

1. Update corresponding tests first
2. Modify the implementation
3. Ensure all tests pass
4. Check for regressions in related functionality
5. Update this documentation if behavior changes significantly

## Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [jsdom Documentation](https://github.com/jsdom/jsdom)
- [Testing JavaScript Best Practices](https://testingjavascript.com/)
- [Jest Cheat Sheet](https://github.com/sapegin/jest-cheat-sheet)

## Questions?

For questions or issues with the test suite:

1. Check the test output for specific error messages
2. Review the test file: `tests/talks-filter.test.js`
3. Check the source code: `static/js/talks-filter.js`
4. Refer to this documentation and the `tests/README.md`
