# Talks Filter Tests

This directory contains unit tests for the conference talks filtering functionality.

## Overview

The talks page (`/talks/`) uses JavaScript to filter conference talks by year, conference, and topic. These tests ensure the filtering logic works correctly.

## Test Coverage

The test suite covers:

- **Filter Logic (`shouldShowTalk`)**: Tests the core filtering algorithm
  - Single filter types (year, conference, topic)
  - Multiple filters (AND logic)
  - Edge cases (empty topics, special characters, whitespace)

- **Filter Management**:
  - `toggleFilter`: Adding and removing filters
  - `clearFilters`: Resetting all filters
  - `applyFilters`: Applying filters to DOM elements

- **UI Interaction**:
  - `toggleFilterGroup`: Collapsing/expanding filter sections
  - Visible count updates
  - CSS class toggling

- **Edge Cases**:
  - Missing DOM elements
  - Empty data
  - Special characters in filter values
  - Case sensitivity

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode (auto-rerun on changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

## Test Results

All 30 tests pass successfully:

- 11 tests for `shouldShowTalk` logic
- 3 tests for `toggleFilter` functionality
- 2 tests for `clearFilters`
- 7 tests for `applyFilters`
- 2 tests for `toggleFilterGroup`
- 4 edge case tests
- 1 test for `resetFilters`

## Files

- `talks-filter.test.js`: Main test suite
- `../static/js/talks-filter.js`: Source code being tested
- `../jest.config.js`: Jest configuration
- `../package.json`: Test dependencies and scripts

## Test Framework

- **Jest**: JavaScript testing framework
- **jsdom**: Simulates browser DOM for testing

## Coverage

Run `npm run test:coverage` to generate a coverage report. The report will be saved in the `coverage/` directory and will show:

- Line coverage
- Branch coverage
- Function coverage
- Statement coverage

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Install dependencies
  run: npm install

- name: Run tests
  run: npm test
```

## Adding New Tests

When adding new filtering features:

1. Add the new function to `static/js/talks-filter.js`
2. Export the function for testing
3. Add corresponding tests to `talks-filter.test.js`
4. Run `npm test` to verify
5. Run `npm run test:coverage` to check coverage

## Test Structure

Each test follows the Arrange-Act-Assert pattern:

```javascript
it('should do something', () => {
  // Arrange: Set up test data
  const input = { /* ... */ };

  // Act: Call the function
  const result = myFunction(input);

  // Assert: Check the result
  expect(result).toBe(expected);
});
```

## Debugging Tests

To debug a specific test:

```bash
# Run only tests matching a pattern
npx jest -t "should show talk when no filters are active"

# Run with verbose output
npx jest --verbose

# Run with coverage for specific file
npx jest talks-filter.test.js --coverage
```
