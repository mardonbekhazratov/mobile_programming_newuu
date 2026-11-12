# Lab 9 - Notes

## Part 1 - Shared code

1. **Why is `CartLine` immutable with `copyWith`?**
   Riverpod, Cubit and Bloc only notify when the new state is different from the old one
   (`==`, which is identity for a class without `==`). If `qty` were mutated in place, the
   state would still be the same object, so nothing would rebuild. Only **setState** would still
   "work", because it rebuilds after the closure whatever the closure did. That is the trap: the
   code works by accident, and breaks as soon as it is moved to another style, put behind a
   `select`/`buildWhen`, or kept in an undo history (the old states would change too, because
   they share the same mutated objects).
2. **Why does `CartBody` take callbacks?**
   So it knows nothing about state management. The same widget is used by all four pages, and
   only the page decides where the data comes from and what a tap does.
