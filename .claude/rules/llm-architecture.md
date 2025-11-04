# LLM Application Architecture

This document captures lessons learned about building robust LLM applications, focusing on classification, determinism, and architectural patterns that lead to reliable behavior.

## Core Principle

**Let LLMs do what they're good at (understanding context, intent), and use structured systems for what they're not (deterministic operations, exact calculations).**

## 1. Use Structured Outputs From the Beginning

**Principle:** When building LLM applications, have the model return structured metadata alongside its response rather than parsing/classifying the response client-side.

**Why:** LLMs have full conversation context and can accurately classify their own outputs and user intents. Client-side heuristics (regex, keyword matching) are brittle and context-unaware.

### Implementation

Have the LLM return:
```json
{
  "message": "The response to show the user",
  "metadata": {
    "userIntent": "question" | "answer" | "clarification",
    "requiresFollowUp": boolean,
    "confidence": number,
    "nextAction": "wait_for_user" | "execute_task" | "clarify"
  }
}
```

### When to Use

- Routing conversation flows
- Tracking conversation state
- Determining next actions
- Any classification that benefits from context understanding

### When NOT to Use

- Pre-LLM routing decisions (what to send to the model)
- Performance-critical paths (adds minimal latency but still adds some)
- Privacy-sensitive classifications (keep data local)

## 2. Offload Classification to the LLM

**Principle:** If the LLM is smart enough to handle user requests, it's probably smart enough to classify those requests. Don't build complex client-side classifiers without first considering whether the LLM could do it better.

### Decision Framework

**Use Client-Side Classification When:**
- Routing before LLM invocation (image vs. text, which model to use)
- Performance-critical (sub-10ms requirement)
- Privacy requirements (can't send data to LLM)
- Deterministic rules are simple (email format, number ranges)

**Use LLM Classification When:**
- Requires understanding context or intent
- Edge cases are numerous
- Client-side rules would be complex (>20 lines of conditionals)
- Classification criteria might evolve

### Anti-Pattern

Don't do this if you're already calling the LLM:

```javascript
// Anti-pattern: Complex client-side classification
function classifyUserMessage(msg) {
  if (msg.length < 10) return 'short_answer';
  if (/sorry|apologize/i.test(msg)) return 'apology';
  if (/^[0-9]+$/.test(msg)) return 'numeric_answer';
  // ... 50 more lines
}
```

**Better:** Let the LLM tell you in its response metadata:

```javascript
// LLM classified it in metadata.userMessageType
```

## 3. Use Function Calling for Deterministic Operations

**Principle:** When you need 100% accuracy on computable operations, give the LLM tools rather than relying on prompting or temperature adjustments.

**Why:** Even with temperature 0 and extensive prompting, LLMs can make arithmetic errors, date miscalculations, or formatting mistakes. Tools offload these to deterministic code.

### Common Use Cases

- **Arithmetic/Math:** Calculator tool for verifying calculations
- **Dates:** Date manipulation tool for "3 weeks from Tuesday"
- **Data Lookup:** Database/API tool for factual information
- **Formatting:** Validation tool for email, phone, postal codes
- **Calculations:** Currency conversion, unit conversion, percentages

### Implementation Pattern

```javascript
tools: [{
  type: "function",
  function: {
    name: "calculate",
    description: "Evaluate math expressions for 100% accuracy",
    parameters: {
      expression: { type: "string" }
    }
  }
}]
```

**Key Insight:** The LLM knows when to use the tool (understanding context), you provide what it should do (deterministic operation).

## 4. Prompt Engineering Has Diminishing Returns

**Principle:** After ~3 iterations of prompt refinement for a specific issue, consider whether a structural change would be more robust than further prompt complexity.

### Diminishing Returns Pattern

1. **Iteration 1:** Add clear instructions → 70% improvement
2. **Iteration 2:** Add examples of correct/incorrect behavior → 15% improvement
3. **Iteration 3:** Add edge case handling and emphasis → 5% improvement
4. **Iteration 4+:** Adding more rules/examples → <2% improvement

### When to Stop Prompting and Change Structure

- Prompt sections for one issue exceed ~20 lines
- You're repeating the same point in multiple ways
- Edge cases require extensive conditional logic in the prompt
- You're adding lookup tables or extensive examples

### Alternative Structural Solutions

- **Function calling** - For determinism
- **Structured outputs** - For reliable state tracking
- **Different model** - For capability gaps
- **Multi-step workflows** - For complex logic
- **Chain-of-thought prompting** - For reasoning

### What Prompt Engineering IS Good For

- High-level behavior description (persona, goals, method)
- Explicit prohibitions (NEVER do X)
- Format requirements (tone, style, length)
- Domain knowledge that can't be tooled

## 5. Log Tool Usage for Diagnostics

**Principle:** When using function calling, log every tool invocation with inputs and outputs. This is critical for debugging LLM behavior.

### Pattern

```javascript
console.log('🔧 LLM calling tool:', toolName);
console.log('  Input:', toolInput);
console.log('  Output:', toolOutput);
```

### Why This Matters

- Reveals when LLM uses tools vs. "guesses"
- Shows what data the LLM extracted from context
- Exposes misunderstandings (e.g., calculating "2+7" instead of "5+7")
- Helps identify prompt improvements

### Best Practices

- Use emoji prefixes for easy visual scanning
- Keep logs in production (helpful for users debugging too)
- Log both successful and failed tool calls
- Include enough context to understand why tool was called

## 6. JSON Mode vs. Strict Schema Validation

**Principle:** Start with JSON mode + prompt-based structure. Add strict schema validation only when needed.

### JSON Mode (response_format: { type: "json_object" })

**Advantages:**
- Simple to implement
- Works with prompt instructions
- Easy to extend

**Disadvantages:**
- No guarantee of exact schema
- Manual parsing required

### Strict Schema (Zod, JSON Schema, etc.)

**Advantages:**
- Type-safe, guaranteed structure
- Catches schema violations early
- Better for complex nested data

**Disadvantages:**
- More setup complexity
- Less flexible for evolution

### Decision Tree

1. Start with JSON mode
2. Add schema validation if you experience:
   - Frequent parsing errors
   - Need for strict type safety
   - Complex nested structures
   - Multiple schema versions
3. Use schema generation tools (Zod, TypeScript) for maintainability

## Summary Checklist

Before building client-side heuristics in your LLM app, ask:

- [ ] Could the LLM classify this in its response metadata?
- [ ] Do I need 100% accuracy? (If yes → use function calling)
- [ ] Am I iterating on prompts for the same issue 3+ times? (If yes → consider structure change)
- [ ] Am I logging tool invocations for debugging?
- [ ] Have I started with JSON mode before adding strict schemas?
- [ ] Is my classification logic simpler to implement client-side or LLM-side?

**Default Strategy:** Use structured outputs + function calling, unless you have a specific reason to handle it client-side.

## Application to Agent Development

When building multi-agent systems or AI assistants:

1. **Agent State Management:** Use structured outputs to track agent state (working, waiting, blocked)
2. **Task Classification:** Let agents classify task complexity and requirements in metadata
3. **Tool Selection:** Use function calling for all deterministic operations (file I/O, git operations, calculations)
4. **Coordination:** Have agents return structured metadata about their progress and blockers
5. **Debugging:** Log all tool usage to understand agent decision-making

These principles apply directly to the coordination system in this repository, where agents use structured task lists and metadata to coordinate work.
