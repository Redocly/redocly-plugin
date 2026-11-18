# Redocly plugin

The Redocly plugin gives your AI coding agent the [Redocly](https://redocly.com) skills and live access to the Redocly documentation through the Redocly MCP server.
It works in Claude Code, Codex and Cursor.

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

Cursor: import this repository as a [team marketplace](https://cursor.com/docs/plugins) (Teams and Enterprise plans), or copy `plugins/redocly` into `~/.cursor/plugins/local`.

Skills only, in any client that reads Agent Skills:

```bash
npx skills add Redocly/redocly-plugin
```

MCP server only, in any MCP client: add `https://redocly.com/mcp` as a remote server over Streamable HTTP, or install `com.redocly/mcp` from the [MCP Registry](https://registry.modelcontextprotocol.io). The [Redocly MCP server docs](https://redocly.com/docs/platform/ai-ready/use-redocly-with-ai-clients#install) have the steps for each client.

## What you get

- **Skills** that the agent loads when your request matches one: Redocly CLI commands, `redocly.yaml` configuration, custom lint rules, Markdown linting with `redocly recheck`, and Redocly docs projects (setup, pages, and API reference docs). The Redocly [skills index](https://redocly.com/.well-known/agent-skills/index.json) lists them.
- **The Redocly MCP server** at `https://redocly.com/mcp`. It searches and reads the current Redocly documentation, and it reports a wrong or incomplete page to the Redocly documentation team. With a Redocly API key that you enter, it can also read your Redocly projects through the Redocly platform API.

Example prompts:

- "Lint my OpenAPI description with Redocly CLI and explain each problem."
- "Write a Redocly lint rule that requires an operationId on every operation."
- "Set up a Redocly docs site for my OpenAPI description."

## Data and privacy

The plugin itself runs no code on your machine: the skills are Markdown files, and the plugin adds only the Redocly MCP server. Some skills tell the agent to run Redocly CLI commands, which the agent runs like any other command.
Redocly receives the tool calls that your agent sends, not your conversation, and keeps usage statistics such as the tool name, the duration, the name of your client and the plugin version.
Redocly also keeps a security audit log of tool calls and API calls.
No tool changes your Redocly account or your projects: the server sends only read requests to the Redocly platform API.

When your agent needs to call the Redocly platform API, it gives you a link to a page on redocly.com, where you enter a Redocly API key.
Your agent does not see the key.
Redocly stores the key encrypted for 24 hours after you save it, and sends it only to the Redocly platform API.
In the chat where you entered the key, ask your agent to remove your API credentials.
You can also revoke the key in Redocly at any time.

The [Redocly Privacy Notice](https://redocly.com/privacy-notice) covers requests to the server.

## Support

Open an issue for a problem with the plugin. We do not accept pull requests from outside Redocly.
To report a security vulnerability, follow [SECURITY.md](SECURITY.md). For anything else, [contact Redocly](https://redocly.com/contact-us).

## License

[MIT](LICENSE)
