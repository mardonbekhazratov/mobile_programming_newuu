# Lab 5 - Self-check answers

1. `push` puts a new screen on top, so the old one stays and you can go back.
   `pushReplacement` swaps the current screen for the new one, so there is no way back to it.
2. A name typed in several places can have a typo that only fails at runtime.
   With one constant, a typo is a compile error and renaming a route is a single change.
3. Call `Navigator.pop(context, value)` on the second screen and
   `final result = await Navigator.push<T>(...)` on the first.
   If the user presses the system back button, `result` is `null`.
4. `context.go` jumps to a location and rebuilds the stack from the route tree
   (for a top-level route the old screens are gone). `context.push` adds the screen
   on top of the current stack, so `pop` returns to where you were.
5. When the page must work from the URL alone: browser reload, deep links, bookmarks, sharing.
   `extra` lives only in memory and is lost; a path parameter is part of the URL.
