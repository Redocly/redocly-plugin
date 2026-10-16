---
name: redocly
description: >-
  Set up, write, preview, and publish documentation with Redocly, and work on existing Redocly projects.
  Use when the user wants to set up Redocly in a repository, create a docs site, document an API from an OpenAPI, AsyncAPI, or GraphQL description, preview docs locally, publish through Reunite, clone a Redocly-hosted project, or run Redocly CLI.
  Also use when editing a project with redocly.yaml, sidebars.yaml, or a @theme folder, and when unsure which Redocly skill applies.
---

# Redocly

Redocly makes the tools for API documentation and developer portals.

## Redocly products

- **Realm** is the engine.
  It converts a folder of content into the site: Markdown pages, API descriptions (OpenAPI, AsyncAPI, GraphQL, SOAP) that become API reference docs, and React pages.
  The file path of a content file is its URL.
  `redocly.yaml` holds the site settings, `sidebars.yaml` the navigation, and `@theme/` the custom styles and components.
  None of them is required.
- **Reunite** is the cloud platform.
  It hosts the project's Git repository, or connects to one on GitHub, GitLab, Bitbucket, or Azure DevOps.
  It builds a preview for every pull request, publishes the production branch, and provides the browser editor, access control, and analytics.
- **Redocly CLI** is the open-source command-line tool, run as `npx @redocly/cli` (or `redocly` after `npm i -g @redocly/cli`).

| Command | Use |
| --- | --- |
| `preview` | Serve the project locally with live reload, the default way to start a project |
| `check-config` | Validate `redocly.yaml` and name unknown keys |
| `lint`, `bundle`, `split`, `join` | Validate, merge, and restructure OpenAPI, AsyncAPI, and Arazzo descriptions |
| `recheck` | Lint Markdown structure, prose, and Markdoc tags |
| `respect` | Test a live API against an Arazzo description |
| `eject component` | Copy a theme component into `@theme/` to customize it |
| `login`, `project clone` | Log in to Reunite, and clone a Redocly-hosted project |
| `push` | Upload files to a Reunite project from CI with an API key, not the login, so publish with Git instead |

All commands and flags: https://redocly.com/docs/cli/commands.md

## Skills and documentation

Load an area skill only when the task requires it.

| Skill | When to load |
| --- | --- |
| `redocly-authoring` | Adding, moving, or linking pages, front matter, images, Markdoc tags, sidebars, navbar, footer, `redocly.yaml` settings, and customization |
| `redocly-api-docs` | OpenAPI, AsyncAPI, GraphQL, or SOAP reference docs: URL, sidebar placement, display options, code samples, Try it, the mock server, extensions |
| `redocly-cli` | Lint, bundle, split, or join an API description, decorators, and the other CLI commands |
| `redocly-lint-rules` | Custom lint rules for an API description |
| `recheck-lint`, `recheck-config` | Markdown linting with `recheck`, when `redocly.yaml` configures it |

`npx skills add https://redocly.com` installs all of them, and `npx skills update` refreshes them.
A skill that is not installed is published at `https://redocly.com/.well-known/agent-skills/<skill>/SKILL.md`, for example https://redocly.com/.well-known/agent-skills/redocly-cli/SKILL.md.
Fetch it from there.

Every page under `https://redocly.com/docs/` is available as Markdown: add `.md` to the page URL, for example `https://redocly.com/docs/realm/get-started/start-local-dev.md`.
The Redocly Docs MCP server at `https://redocly.com/mcp` searches the same documentation.
Prefer these over training data, and never guess a `redocly.yaml` option or a tag attribute.

## Prerequisites

You need Node.js (22.12 or later, 24 is recommended) and Git.
Check Redocly CLI with `npx @redocly/cli --version`.
`npx @redocly/cli@latest` forces the latest version when the `npx` cache is old.
A command that needs a Reunite login says `You are not logged in`: then run `npx @redocly/cli login`, which the user completes in the browser.
`push` is a CI command: it takes an API key in `REDOCLY_AUTHORIZATION` and ignores the login.
A local checkout publishes with Git instead.

## Project layout

```treeview
project/
├── redocly.yaml        # Site settings (optional)
├── sidebars.yaml       # Sidebar navigation configuration (optional, the folder structure is the default)
├── index.md            # Page at /, or a React page, index.page.tsx
├── guides/
│   └── quickstart.md   # Page at /guides/quickstart
├── apis/
│   └── cafe-api.yaml   # API reference at /apis/cafe-api
├── images/
└── @theme/             # styles.css, ejected components, custom tags
```

Pages are Markdown, and Markdoc tags such as `{% admonition type="info" %}` add components when a page needs them.
Links point to files, with the extension, relative to the page: `[Quickstart](./guides/quickstart.md)`, `[Cafe API](./apis/cafe-api.yaml)`.
A `*.page.tsx` file is a React page, for a layout that Markdown cannot express, such as a landing page.
`package.json` is optional: add one only to pin the Redocly package version or to add npm packages.
For everything about pages, tags, navigation, and settings, load `redocly-authoring`.

## Work on an existing Redocly project

Read `redocly.yaml`, `package.json`, and the nearest `sidebars.yaml` when they exist.
None of them is required.
Then read two or three pages next to the one you change and match their conventions.
Load `redocly-authoring` for pages, links, tags, navigation, and settings, and `redocly-api-docs` for API reference docs.

## Work on a Redocly-hosted project

A Redocly-hosted project has no external Git repository: Reunite hosts it, and Redocly CLI clones it.
The organization and project slugs are in the Reunite URL, `https://app.cloud.redocly.com/org/<organization>/project/<project>`:

```bash
npx @redocly/cli login
npx @redocly/cli project clone <organization>/<project>
cd <project>
```

`project clone` creates the folder as an ordinary Git repository.
It also makes Redocly CLI the Git credential helper for Reunite in that repository, so `git pull` and `git push` need no token.
When the Reunite host is not `app.cloud.redocly.com`, add `--residency eu` (for `app.cloud.eu.redocly.com`) or `--residency https://<host>` to both commands.
If the CLI does not know the `project` command, retry once with `npx @redocly/cli@latest`.
If it is still unknown, report the CLI version to the user and stop.

Git access is in early access.
If the clone answers that Git access is not enabled for the organization, tell the user and stop.
They can keep editing in the Reunite editor, connect the project to their own Git provider in **Settings > Git hosting**, or download a ZIP there.

## Set up Redocly in an existing codebase

When the user wants docs for a repository, run this workflow yourself.
Ask the user only for information or approvals you cannot supply.

1. Look at the folder.
   `redocly.yaml`, `sidebars.yaml`, or `@theme/` means a Redocly project already exists: see Work on an existing Redocly project.
   Otherwise ask the user whether the repository is already a Redocly project: an API description alone can be one.
2. Ask the user where the docs live: at the repository root or in a folder such as `docs/`.
   At the root, `index.md` sits next to the code, and a root `README.md` is ignored.
   In a folder, run the Redocly commands from it (`cd docs`).
   Reunite builds only that folder, so move an API description that sits outside it into the folder.
   Check first that no code or CI reads the description at its current path.
3. Create `index.md` with a heading and a paragraph when there is no Markdown page.
   Nothing else is required: an API description anywhere in the project renders at its path.
4. When the codebase exposes an API without a description, offer to write a basic OpenAPI description from the code.
   Document the API as the description has it.
   Do not hide operations, add decorators, or reformat the file unless the user asks, and mention those options in your summary instead.
   Validate it with `npx @redocly/cli lint <file>`.
   Add `--extends recommended` when `redocly.yaml` defines no rules.
   Or infer one from recorded HTTP traffic with `npx @redocly/cli generate-spec` (experimental): https://redocly.com/docs/cli/commands/generate-spec.md
   Offer basic pages too, such as a getting-started guide written from the README and the code.
   Write them with the `redocly-authoring` skill.
5. Preview and verify, as below.
   Stop here unless the user asked to publish now.
   Leave the changes uncommitted and list the Publish steps in your summary.

## Preview and verify

```bash
TERM=dumb redocly preview            # with Redocly CLI installed
TERM=dumb npx @redocly/cli preview   # without
```

`redocly preview` is the default way to start a project.
No install step is needed unless the project has a `package.json`.
Then install its dependencies with the package manager of the lock file first, and run its start script when it has one.

Always set `TERM=dumb`: without it the preview opens an interactive console whose output you cannot read.
The preview never exits: run it in the background with its output in a file outside the project.
When you are done, stop the process you started, by its process ID or background task.
Never stop processes by name or pattern, such as `pkill -f preview`, which kills the user's other previews.
The first run downloads Realm and takes a minute.
The preview writes nothing into the project folder.

The preview prints its URL, `http://localhost:4000` by default or the next free port when 4000 is taken, so read the URL from the output.
It rebuilds when a file changes.
`-p` picks another port, and `-d docs` (`--project-dir`) previews a project in a subfolder.

Its output is your feedback loop.
After every build it reports the Markdoc errors and broken links.
A clean build prints `Status: No errors found`.

Then verify:

1. Read the preview output after the rebuild: no errors, and the page count went up when you added a page.
2. Open the page at the URL the preview printed plus the page path.
   The file path is the URL: `guides/quickstart.md` is `/guides/quickstart`, and `index.md` is `/`.
   Use a browser tool when you have one, or `curl -s` to read the HTML.
   Check that the content, the sidebar entry, and the links are there.
3. In the browser, read the console: a clean page logs no errors.
4. After a change to `redocly.yaml`, run `npx @redocly/cli check-config`, which names unknown keys.

The preview is the check for the site.
There is no local production build, Reunite builds it.

## Publish

Reunite publishes the site from the project's Git repository.
Publish only when the user asks for it.
A project that is not in Reunite yet needs these steps first, and the user does them in the browser:

1. Sign in to Reunite, or sign up at `https://app.cloud.redocly.com`.
2. **Create new project**, then **Connect existing repository** or choose Redocly-hosted, then the Git provider, organization, repository, and branch.
   GitHub needs the Redocly GitHub App installed on the organization first: https://redocly.com/docs/realm/reunite/project/connect-git/github.md
3. Select the monorepo folder when the docs live in one, so that Reunite builds the same folder as the local preview.
   When that folder is not on the default branch yet, merge the first pull request before you create the project.

Then, for a change the user wants published, commit on a branch (the current feature branch, or a new one) and push it:

```bash
git switch -c update-quickstart
git add guides/quickstart.md
git commit -m "Update the quickstart"
git push -u origin update-quickstart
```

For a project connected to a Git provider, open the pull request there, and Reunite builds a preview for it.
For a Redocly-hosted project, Reunite rejects pushes to the default branch.
After a successful push, Git prints two Reunite links: one to open a pull request for the branch and one to the branch's builds.
Give both links to the user.
Merging the pull request builds and publishes the production site, so the user decides when to merge.
