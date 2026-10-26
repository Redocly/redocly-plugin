# Redocly plugin

The Redocly plugin gives your AI coding agent the Redocly skills and the Redocly MCP server.
Use it to lint, bundle, split and join OpenAPI, AsyncAPI and Arazzo descriptions, to write and test custom lint rules, to lint Markdown with recheck, to set up and write Redocly docs projects, and to look up the current Redocly documentation while you work.

## Skills

The skills cover Redocly CLI commands, `redocly.yaml` configuration, custom lint rules, Markdown linting with `redocly recheck`, and Redocly docs projects (setup, pages, and API reference docs).
The agent loads a skill when your request matches its description.
The skills are copies of the skills in the Redocly [skills index](https://redocly.com/.well-known/agent-skills/index.json).

## MCP server

`.mcp.json` registers the Redocly MCP server at `https://redocly.com/mcp` over HTTP.
The server searches and reads the current Redocly documentation.
It only reads data, except when it sends a report about a wrong or incomplete page to the Redocly documentation team.
Redocly receives the tool calls that the agent sends, not your conversation. The [Redocly MCP server docs](https://redocly.com/docs/platform/ai-ready/use-redocly-with-ai-clients#data-and-privacy) and the [Redocly Privacy Notice](https://redocly.com/privacy-notice) describe the data it keeps.
The plugin runs no code on your machine.

## Install

The [repository README](https://github.com/Redocly/redocly-plugin#install) has the steps for Claude Code, Codex and Cursor.

## License

MIT.
