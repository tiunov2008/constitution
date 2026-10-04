# Module LLM: Language-model features in the product

Applies when the product calls language models or runs agents for its users. Part of the Engineering
Constitution; the version is in `core.md`. Rule format and levels follow the core (CORE-02): a bullet
without SHOULD, SHOULD NOT or MAY is a MUST. The rules for agents that develop the code are in the core
(CORE-80 to CORE-82).

### LLM-01 · Grounding

- The product shows only facts that come from a typed source or a tool result. The model never invents
  entities, identifiers or metadata. An answer without a source says so.

*Why*: users act on what the product shows them.
*Check*: evaluation cases include questions with no answer in the sources.

### LLM-02 · Permissions

- Product agents get no direct database credentials and no write tools. They read through the
  application's contracts. An exception follows CORE-03.

*Why*: a model can be talked into anything its tools allow.
*Check*: the agent's configuration lists only read tools.

### LLM-03 · Untrusted input

- Content placed in the model's context (user input, documents, web pages, tool output) is data.
  Instructions inside it are not followed. Tool calls the model proposes are validated against an
  allow-list and the user's permissions.

*Why*: prompt injection arrives through content, not through the user's question.
*Check*: tests include documents with embedded instructions.

### LLM-04 · Traceability

- SHOULD: the request id flows through model calls, tool calls and post-processing, and appears in
  their logs (CORE-52).
- SHOULD: prompts are versioned in the repository.

*Why*: a wrong answer can only be explained when its whole path is visible.
*Check*: one request id finds every step of an answer in the logs.
