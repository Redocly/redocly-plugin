# Redocly plugin

The Redocly plugin gives your AI coding agent the Redocly skills and the Redocly MCP server.
Use it to lint, bundle, split and join OpenAPI, AsyncAPI and Arazzo descriptions, to write and test custom lint rules, to lint Markdown with recheck, to set up and write Redocly docs projects, and to look up the current Redocly documentation while you work.
No sign-in is required.

## Skills

The skills cover Redocly CLI commands, `redocly.yaml` configuration, custom lint rules, Markdown linting with `redocly recheck`, and Redocly docs projects (setup, pages, and API reference docs).
The agent loads a skill when your request matches its description.
The skills are copies of the skills in the Redocly [skills index](https://redocly.com/.well-known/agent-skills/index.json).

## MCP server

`.mcp.json` registers the Redocly MCP server at `https://redocly.com/mcp` over HTTP.
Each request has the header `X-Redocly-MCP-Source: redocly-plugin`, so Redocly can count the requests that come from the plugin. Claude Code and Cursor read the header from `headers`, and Codex reads it from `http_headers`.
The server searches and reads the current Redocly documentation.
It needs no account or token.
Its documentation tools only read data. Its `submit-feedback` tool sends a report about a wrong or incomplete page to the Redocly documentation team, and it is the only tool that writes data.
Redocly receives the tool calls that the agent sends, not your conversation. The [Redocly MCP server docs](https://redocly.com/docs/realm/customization/mcp-server/redocly-mcp) and the [Redocly Privacy Notice](https://redocly.com/privacy-notice) describe the data it keeps.
The plugin runs no code on your machine.

## Install

Claude Code:

```bash
claude plugin marketplace add Redocly/redocly-plugin
claude plugin install redocly@redocly
```

Codex:

```bash
codex plugin marketplace add Redocly/redocly-plugin
codex plugin add redocly@redocly
```

Cursor: the Cursor Marketplace listing is not live yet. On a Teams or Enterprise plan, an admin can import [the repository](https://github.com/Redocly/redocly-plugin) as a team marketplace.

## License

MIT.
