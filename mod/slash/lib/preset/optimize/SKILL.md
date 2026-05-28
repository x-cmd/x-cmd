---
name: optimize
description: Review code for efficiency and performance. Triggered by "/optimize" when user wants to identify bottlenecks or improve performance.
tools: Bash, Read
---

# Performance Optimizer

## Trigger

Use when:
- User says `/optimize`
- User reports slowness or high resource usage
- User asks for performance improvements

Do NOT use when:
- User asks for readability improvements (use `/simplify`)
- User asks for security audit (use `/security-review`)

## Steps

### Step 1: Profile (if applicable)

If user provides runtime data or if profiling is straightforward:
```bash
# Examples by platform/language
/usr/bin/time -v ./script.sh        # Linux
python -m cProfile -s cumtime script.py
node --prof script.js
```

If no runtime data, skip to Step 2 with static analysis.

### Step 2: Identify Bottlenecks

Analyze for:
- Algorithmic complexity (O(n²) → O(n log n))
- Synchronous I/O in loops
- N+1 query patterns
- Missing database indexes
- Unbounded memory growth
- Repeated expensive computations without caching

### Step 3: Generate Report

Use the output format below.

## Output Format

```markdown
## Performance Review

### Bottlenecks Found

#### 🔴 [Severity] [Category]
**File**: `path:line`
**Issue**: [Description]
**Impact**: [Quantify if possible]
**Fix**: [Recommendation]

#### 🟠 ...

### Recommendations (Priority Order)
1. [Highest impact fix]
2. [Next fix]
```

## Constraints

- Do NOT optimize without profiling data unless obvious algorithmic issue
- Focus on the 20% causing 80% of slowdown (Pareto)
- Verify each suggestion is measurable
- Do NOT auto-apply changes
