# Coding Standards

## Function and File Size Limits

**Maximum function length: 75 lines**
- Keep individual functions focused and under 75 lines
- Break complex functions into smaller, well-named helper functions
- Each function should have a single, clear responsibility

**Maximum file length: 750 lines**
- Keep files under 750 lines of code
- Decompose large files into multiple focused modules
- Split by logical boundaries (features, layers, responsibilities)

**Enforcement:**
- Agents MUST decompose functionality across files as far as necessary to meet these limits
- When approaching limits, refactor proactively before adding new code
- Prefer many small, focused files over fewer large files

## Decomposition Guidelines

When a function or file exceeds its limit:

1. **For Functions:**
   - Extract logical blocks into helper functions
   - Move complex conditions into named predicates
   - Pull repeated patterns into utility functions
   - Consider if the function has multiple responsibilities

2. **For Files:**
   - Group related functions into new modules
   - Separate concerns (data, logic, presentation)
   - Extract shared utilities to common files
   - Split large classes into composition of smaller ones

## Benefits

- **Readability:** Smaller units are easier to understand
- **Maintainability:** Changes are isolated and safer
- **Testability:** Focused functions are easier to test
- **Reusability:** Small, focused components can be reused
- **Collaboration:** Reduces merge conflicts
