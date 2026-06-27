# Rules

Set of rules for development

## Markdown Files

When creating markdown files;

- Introduce line breaks at punctuation marks and conjunctions,
so that individual lines aren't much longer than 100 characters long when applicable.
This improves readability for human.

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root,
AND codegraph command is available in the current shell environment),
reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call
— the relevant symbols' verbatim source plus the call paths between them,
including dynamic-dispatch hops grep can't follow.
Name a file or symbol in the query to read its current line-numbered source.
If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, or if `codegraph` is not available in the current shell,
skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
