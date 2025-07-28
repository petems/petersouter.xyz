# Overcoming GraphQL Code Generation Challenges: A Custom Solution for the Hardcover.app API

## Introduction

When building a Go CLI client for the Hardcover.app GraphQL API, we encountered a fundamental problem: **standard GraphQL code generation tools simply don't work** with this API. The introspection schema has significant mismatches with the actual API behavior, making off-the-shelf tools unusable.

This post explores the challenges we faced, the approaches we tried, and how we built a custom solution that provides type safety and maintainability while working around the API's limitations.

## The Problem: GraphQL Introspection Schema Mismatches

The Hardcover.app GraphQL API has introspection schema issues that prevent standard code generation tools from working. Here are the key problems we discovered:

### 1. Search Field Parameters Don't Match

**Expected Schema (per API docs):**
```graphql
type Query {
  search(
    query: String!
    query_type: String
    per_page: Int
    page: Int
    sort: String
    fields: String
    weights: String
  ): SearchOutput
}
```

**Actual Introspection Result:**
```graphql
type Query {
  search: SearchOutput
}
```

The introspection schema completely omits the search parameters, making it impossible for code generators to create type-safe search functions.

### 2. User Profile Query Structure Issues

**Expected Schema (per API docs):**
```graphql
query GetCurrentUser {
  me {
    id
    username
    email
    created_at
    updated_at
  }
}
```

**Actual Introspection Result:**
```graphql
type Query {
  me: users
}
```

**Runtime Reality:** The API actually returns `me` as an array `[]users`, not a single object. This causes generated code to fail with "cannot unmarshal array into Go struct" errors.

### 3. Field Name Inconsistencies

**API Reality:** Uses snake_case fields (`release_date`, `isbn_10`, `isbn_13`, `edition_format`)

**Introspection Schema:** May show camelCase fields (`publicationYear`, `pageCount`, `editionFormat`)

This mismatch means generated code references non-existent fields.

### 4. Book Query Structure Problems

**Expected Schema (per API docs):**
```graphql
query GetBookDetails {
  editions(where: {id: {_eq: 21953653}}) {
    id
    title
    description
    slug
    isbn_10
    isbn_13
    release_date
    pages
    edition_format
    publisher { name }
    contributions { author { name } }
  }
}
```

**Actual Introspection Result:** Shows `book(id: ID!): Book` which doesn't work with the actual API structure.

## Failed Approaches: Standard GraphQL Tools

We tried several standard GraphQL code generation tools, but all failed due to the schema mismatches:

### 1. gqlgenc

```bash
# Installation
go install github.com/Khan/genqlient/cmd/gqlgenc@latest

# Configuration (gqlgenc.yaml)
schema:
  - https://api.hardcover.app/v1/graphql
  headers:
    Authorization: Bearer ${HARDCOVER_API_KEY}
```

**Result:** Failed with authentication errors and package naming conflicts:
```
introspection query failed: {"networkErrors":{"code":401,"message":"Response body {\"error\":\"Unable to verify token\"}"},"graphqlErrors":null}
```

Even after fixing authentication, we got:
```
generating core failed: exec and model define the same import path (hardcover-cli) with different package names (main vs generated)
```

### 2. genqlient

```bash
# Installation
go install github.com/Khan/genqlient@latest

# Configuration (genqlient.yaml)
schema:
  - https://api.hardcover.app/v1/graphql
```

**Result:** Failed because genqlient doesn't support remote schemas directly:
```
.../https:/api.hardcover.app/v1/graphql did not match any files
```

### 3. gqlgen

```bash
# Installation
go install github.com/99designs/gqlgen@latest

# Configuration (gqlgen.yml)
schema:
  - https://api.hardcover.app/v1/graphql
```

**Result:** Generated introspection types but not query-specific types, making it unsuitable for client-side generation.

## Our Custom Solution: Working Around the Limitations

Instead of fighting with broken tools, we built a custom type generation system that works around the API's limitations while providing type safety and maintainability.

### 1. Custom Type Generator

We created a Go script (`scripts/generate-types.go`) that:

```go
func fetchGraphQLSchema(apiKey string) (*GraphQLResponse, error) {
    // Create GraphQL request
    req := GraphQLRequest{
        Query: introspectionQuery,
    }

    // Execute HTTP request with proper authentication
    ctx := context.Background()
    httpReq, err := http.NewRequestWithContext(
        ctx, "POST", "https://api.hardcover.app/v1/graphql", bytes.NewBuffer(jsonData))
    
    // Handle response and parse schema
    // ...
}

func generateTypesFile(schema *GraphQLResponse) error {
    // Filter out problematic types
    var filteredTypes []Type
    for _, t := range schema.Data.Schema.Types {
        if t.Name != "" && !strings.HasPrefix(t.Name, "__") && t.Name != "json" {
            filteredTypes = append(filteredTypes, t)
        }
    }

    // Generate Go types with custom mappings
    // ...
}
```

### 2. Custom Type Mappings

We handle problematic GraphQL types with custom mappings:

```go
func getGoType(typeRef TypeRef) string {
    switch typeRef.Name {
    case "ID":
        return "string"
    case "String":
        return "string"
    case "citext":  // Handle PostgreSQL citext type
        return "string"
    case "json":
        return "*json.RawMessage"  // Handle JSON fields
    case "jsonb":
        return "*json.RawMessage"
    default:
        return "*" + toCamelCase(typeRef.Name)
    }
}
```

### 3. DRY GraphQL Architecture

We implemented a maintainable pattern with:

**Query Constants** (`internal/client/queries.go`):
```go
const (
    GetCurrentUserQuery = `
query GetCurrentUser {
  me {
    id
    username
    email
    name
    bio
    location
    createdAt
    updatedAt
  }
}
`
)
```

**Typed Responses** (`internal/client/responses.go`):
```go
type GetCurrentUserResponse struct {
    Me *Users `json:"me"`
}
```

**Helper Functions** (`internal/client/helpers.go`):
```go
func (c *Client) GetCurrentUser(ctx context.Context) (*GetCurrentUserResponse, error) {
    var response GetCurrentUserResponse
    if err := c.Execute(ctx, GetCurrentUserQuery, nil, &response); err != nil {
        return nil, err
    }
    return &response, nil
}
```

## The Result: Clean, Type-Safe GraphQL Operations

Our custom approach provides a clean, type-safe API:

```go
// Before: Manual HTTP requests with interface{} types
const query = `query GetCurrentUser { me { id username } }`
var response map[string]interface{}
client.Execute(ctx, query, nil, &response)

// After: Type-safe operations with generated types
response, err := gqlClient.GetCurrentUser(ctx)
if err != nil {
    return fmt.Errorf("failed to get user profile: %w", err)
}

// Direct access to typed fields
user := response.Me
printToStdoutf(cmd.OutOrStdout(), "  ID: %d\n", user.ID)
printToStdoutf(cmd.OutOrStdout(), "  Username: %s\n", user.Username)
```

## Benefits of Our Custom Approach

### 1. **Actually Works**
- Bypasses introspection schema issues
- Handles real API behavior (arrays vs objects)
- Maps problematic types correctly

### 2. **Type Safety**
- Compile-time validation of API responses
- IDE autocomplete and error detection
- No more runtime type assertion errors

### 3. **Maintainability**
- DRY pattern with centralized queries
- Easy to add new GraphQL operations
- Clear separation of concerns

### 4. **Developer Experience**
- Clean, intuitive API
- Proper error handling
- Easy to understand and extend

## Implementation Workflow

Our development workflow is simple and effective:

```bash
# Generate types from GraphQL schema
make generate-types

# Build the application
make build

# Run tests
make test
```

For adding new commands, we follow a consistent pattern:

1. Add query to `internal/client/queries.graphql`
2. Regenerate types with `make generate-types`
3. Add response type to `internal/client/responses.go`
4. Add helper function to `internal/client/helpers.go`
5. Implement CLI command using the helper

## Lessons Learned

### 1. **Don't Trust Introspection Blindly**
Always test introspection schema against actual API behavior. The schema may not match the documentation or runtime behavior.

### 2. **Custom Solutions Can Be Better**
When standard tools fail, custom solutions can provide better results. Our approach is more maintainable than fighting with broken tools.

### 3. **Type Safety is Worth the Effort**
The investment in type-safe code generation pays off in reduced bugs and better developer experience.

### 4. **Documentation vs Reality**
API documentation and introspection schema can both be wrong. Test against actual API responses.

## Conclusion

While standard GraphQL code generation tools failed due to introspection schema issues, our custom solution provides:

- **Type safety** with generated Go structs
- **Maintainability** with DRY patterns
- **Developer experience** with clean APIs
- **Reliability** that works with the actual API

The key insight is that **custom type generation + DRY architecture** can overcome introspection schema limitations while providing excellent developer experience and type safety.

Our approach demonstrates that when standard tools don't work, building custom solutions can result in better, more maintainable code. The investment in our custom type generation system has paid off with a robust, type-safe GraphQL client that actually works with the Hardcover.app API.

## Code Repository

The complete implementation is available at: [hardcover-cli](https://github.com/petems/hardcover-cli)

Key files:
- `scripts/generate-types.go` - Custom type generator
- `internal/client/queries.go` - GraphQL query constants
- `internal/client/responses.go` - Typed response structures
- `internal/client/helpers.go` - Helper functions
- `internal/client/types.go` - Generated types

---

*This post demonstrates how to work around GraphQL API limitations while maintaining type safety and developer experience. The custom approach we developed provides a robust solution for APIs with introspection schema issues.* 
