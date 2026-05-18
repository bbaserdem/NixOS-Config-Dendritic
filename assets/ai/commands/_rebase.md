There were upstream changes.
We want to rebase our current branch to upstream.
Fetch all upstream changes first.
Then perform a rebase, retaining upstream changes while adapting the current branch' changes to the upstream changes.
Priority is retaining the changes upstream (unless it's functionality that we directly changed; then our changes take precedence) and then retaining our implementation.
(If I did not mention a reference branch explicitly, rebase on main)
