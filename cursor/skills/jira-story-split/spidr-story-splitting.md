# SPIDR: Story Splitting Techniques

Quick reference for splitting user stories/issues into smaller, deliverable pieces.

## SPIDR Framework

Five techniques by Mike Cohn (Mountain Goat Software):

| Letter | Technique  | When to Use                                                            |
| ------ | ---------- | ---------------------------------------------------------------------- |
| **S**  | Spike      | Need research before implementation — extract learning as separate issue |
| **P**  | Paths      | Multiple user flows exist (e.g., pay by card vs. Apple Pay)           |
| **I**  | Interfaces | Can deliver simpler UI first, or one platform before others           |
| **D**  | Data       | Can start with subset of data types, add complex cases later          |
| **R**  | Rules      | Can defer business rules (validation, edge cases) to later issues     |

## Choosing a Technique

1. **Paths** and **Rules** are most common — look for these first
2. **Spike** is for unknowns — use when team lacks knowledge to estimate
3. **Interfaces** works well for UI-heavy features
4. **Data** applies when multiple data formats/types add complexity

## Examples

### Splitting by Spike

Original: "System generates video captions"
Split into:
- "Spike: Evaluate caption generation libraries"
- "System generates video captions using [chosen solution]"

### Splitting by Paths

Original: "User can share a video"
Split into:
- "User can copy a shareable URL"
- "User can share to Twitter"
- "User can share to Facebook"

### Splitting by Interfaces

Original: "User can select payment method"
Split into:
- "User can select payment method (dropdown list)"
- "User can select payment method (visual card selector)"

### Splitting by Data

Original: "System accepts video uploads"
Split into:
- "System accepts MP4 uploads"
- "System accepts MOV uploads"
- "System accepts remaining 14 formats"

### Splitting by Rules

Original: "User can upload a video"
Split into:
- "User can upload a video (basic)"
- "User can upload a video with copyright detection"
- "User can upload a video with content moderation"

## References

- [SPIDR: Five Simple but Powerful Ways to Split User Stories](https://www.mountaingoatsoftware.com/blog/five-simple-but-powerful-ways-to-split-user-stories)
