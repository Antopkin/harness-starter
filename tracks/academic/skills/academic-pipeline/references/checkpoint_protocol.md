### Decision Dashboard (shown at FULL checkpoints)

```
━━━ Stage [X] [Name] Complete ━━━

Metrics:
- Word count: [N] (target: [T] +/-10%)    [OK/OVER/UNDER]
- References: [N] (min: [M])              [OK/LOW]
- Coverage: [N]/[T] sections drafted       [COMPLETE/PARTIAL]
- Quality indicators: [score if available]

Deliverables:
- [Material 1]
- [Material 2]

Flagged: [any issues detected, or "None"]

Ready to proceed to Stage [Y]? You can also:
1. View progress (say "status")
2. Adjust settings
3. Pause pipeline
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Adaptive Rules

1. **First checkpoint**: always FULL
2. **After 2+ consecutive "continue" without review**: prompt user awareness ("You've auto-continued [N] times. Want to review progress?")
3. **Integrity boundaries (Stage 2.5, 4.5)**: always MANDATORY
4. **Review decisions (Stage 3, 3')**: always MANDATORY
5. **Before finalization (Stage 5)**: always MANDATORY
6. **All other stages**: start FULL, downgrade to SLIM if user says "just continue"

### Checkpoint Rules

1. **Cannot auto-skip MANDATORY checkpoints**: Even if the previous stage result is perfect, explicit user input is required at MANDATORY checkpoints
2. **User can adjust**: At FULL and MANDATORY checkpoints, users can modify the mode or settings for the next step
3. **Pause-friendly**: Users can pause at any checkpoint and resume later
4. **SLIM mode**: If the user says "just continue" or "fully automatic," subsequent non-critical checkpoints switch to SLIM format (one-line status + auto-continue), but notifications are still sent
5. **Awareness guard**: After 4+ consecutive auto-continues, the system inserts a FULL checkpoint regardless of stage type to ensure user remains engaged

---

