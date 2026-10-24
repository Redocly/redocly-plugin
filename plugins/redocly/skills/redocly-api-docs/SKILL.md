---
name: redocly-api-docs
description: >-
  Use when adding or changing API reference docs in a Redocly project: rendering an OpenAPI, AsyncAPI,
  GraphQL, or SOAP (WSDL) description, its URL and place in the sidebar or navbar, code samples, the
  Try it (Replay) console, the mock server, x- extensions such as x-tagGroups or x-codeSamples, or
  embedding one operation or schema in a Markdown page.
  Not for linting, bundling, or splitting API descriptions (use redocly-cli).
---

# Add API reference docs to a Redocly project

## The file is the reference

Put the API description anywhere in the project.
Redocly renders it as reference docs at the path of the file, with a sidebar built from its tags and operations.
OpenAPI, AsyncAPI, and GraphQL files need no configuration, and WSDL needs the SOAP plugin first, see below.

| File | URL |
| --- | --- |
| `apis/cafe-api.yaml` | `/apis/cafe-api` |
| `api-reference/index.yaml` | `/api-reference` |

Supported descriptions: OpenAPI (any version, YAML or JSON), AsyncAPI 3.0, GraphQL SDL (`.graphql`, `.gql`), and WSDL with the SOAP plugin.
For a new description, use the latest OpenAPI or AsyncAPI version unless the user asks for another.

To change the URL, move or rename the file, and the mock server path below follows it.
Link to the reference by its file path, like any page:

```yaml
# sidebars.yaml, navbar, or footer
- page: apis/cafe-api.yaml
  label: Cafe API
```

The internal sidebar of the reference comes from the description itself.
Shape it with `x-tagGroups` and the other extensions below, not with `sidebars.yaml`.
Render the description as it is.
Hiding operations, with `x-internal` and a decorator or by leaving a tag out of `x-tagGroups`, and reformatting the file are the user's decisions, so ask first.

Full reference: https://redocly.com/docs/platform/content/api-docs/add-openapi-docs.md

## AsyncAPI, GraphQL, and SOAP

- AsyncAPI 3.0 files render like OpenAPI files, with `asyncapi` options and their own extensions: https://redocly.com/docs/platform/content/api-docs/add-asyncapi-docs.md
- GraphQL SDL files get a sidebar from their queries, mutations, and types, and `graphql.menu` groups them: https://redocly.com/docs/platform/content/api-docs/add-graphql-docs.md
- SOAP needs `@redocly/portal-plugin-soap-api` and `@redocly/framework` in `package.json`, `plugins: ['@redocly/portal-plugin-soap-api/plugin.js']` in `redocly.yaml`, and `.wsdl` files: https://redocly.com/docs/platform/content/api-docs/add-soap-docs.md

## OpenAPI display options

Options go under the top-level `openapi` key of `redocly.yaml` for every API, or under `apis.<name>.openapi` for one API.
Both merge, and the per-API value wins.
With one API, the top-level key is enough.
Use the per-API form for a setting that must not apply to APIs added later.
`asyncapi` and `graphql` work the same way.

```yaml
openapi:
  layout: stacked
  hideReplay: true
  codeSamples:
    languages:
      - lang: curl
      - lang: Python
apis:
  cafe_api:
    root: apis/cafe-api.yaml
    openapi:
      hideReplay: false
```

| Option | Default | Effect |
| --- | --- | --- |
| `layout` | `three-panel` | `stacked` moves the samples into the middle panel |
| `hideReplay` | `false` | Hide the Try it buttons |
| `codeSamples.languages` | a default set | Which generated samples to show, in order, by `lang` (`curl`, `JavaScript`, `Python`, ...), and `label` renames a tab. Supported values: https://redocly.com/docs/platform/config/openapi/code-samples.md |
| `hideDownloadButtons` | `false` | Hide the download links, which does not hide the description |
| `downloadUrls` | - | Download links: a list of `title` and `url` |
| `schemaDefinitionsTagName` | - | List all schemas in a sidebar section with this name |
| `showExtensions` | `false` | Show `x-` fields in the docs |
| `sortRequiredPropsFirst` | `false` | Required properties first |
| `excludeFromSearch` | `false` | Keep the API out of search and `llms.txt` |

All options: https://redocly.com/docs/platform/config/openapi.md

An `apis` entry is optional.
Add one only when an API needs its own lint rules, decorators, or rendering options, or a CLI shortcut name such as `redocly lint cafe_api`.
Its key is a name, or `name@version`, and `root` is required.
It does not add a page and does not set the URL: https://redocly.com/docs/platform/config/apis.md

## Code samples

Redocly generates request samples in the configured languages.
For a language it does not generate, or a hand-written sample, add `x-codeSamples` to the operation.
`source` is inline code or a `$ref` to a file:

```yaml
paths:
  /orders:
    post:
      x-codeSamples:
        - lang: Python
          source:
            $ref: ../code-samples/create-order.py
```

When `codeSamples.languages` is set, list the sample's `lang` there too, or the sample does not show.

Full reference: https://redocly.com/docs/platform/config/openapi/code-samples.md

## Try it and the mock server

Replay is the Try it console.
Hide it for all APIs or one API with `hideReplay`, or for one operation with `x-hideReplay: true`.
It sends requests through a built-in CORS proxy, so the API needs no CORS headers.

The mock server is on by default and answers with the examples from the description at `/_mock/<path-to-description>/`, for example `/_mock/apis/cafe-api/`.
Turn it off with `mockServer.off: true`: https://redocly.com/docs/platform/config/mock-server.md

Prefilling request values, headers, or auth for Replay is a customization (an ejected `configure.ts`): https://redocly.com/docs/platform/customization/configure-request-values.md

## OpenAPI extensions

| Extension | Where | Effect |
| --- | --- | --- |
| `x-tagGroups` | root | Group tags in the sidebar, and a tag in no group does not show |
| `x-displayName` | tag | Tag label in the sidebar |
| `x-traitTag` | tag | A tag that describes operations without grouping them |
| `x-tags` | schema | Add a schema to a tag section |
| `x-badges` | operation, parameter, schema | Badges with `name`, `color`, `position` |
| `x-enumDescriptions` | schema | Describe enum values, and only listed values show |
| `x-rbac` | any object | Team-to-role map that hides the object from other users |
| `x-seo` | operation | Title, description, and image of the operation page |
| `x-webhooks` | root | Webhooks in OpenAPI 3.0 and earlier |

```yaml
x-tagGroups:
  - name: Ordering
    tags: [Menu, Orders]
  - name: Account
    tags: [Customers]
```

All extensions: https://redocly.com/docs/platform/content/api-docs/openapi-extensions.md

## API content in Markdown pages

Show one operation or schema in a guide with the API content tags:

```markdoc {% process=false %}
{% openapi-code-sample descriptionFile="../apis/cafe-api.yaml" operationId="createOrder" language="curl" /%}
```

`openapi-response-sample` shows the response and `replay-openapi` embeds Try it for one operation.
Both take the same `descriptionFile` and `operationId` (or `pointer`) attributes.
`json-schema` takes a `schema` object: `{% json-schema schema={ "$ref": "../apis/cafe-api.yaml#/components/schemas/Order" } /%}`.
Language values are case-sensitive, as in `codeSamples`.

References: https://redocly.com/docs/platform/content/markdoc-tags/openapi-code-sample.md, https://redocly.com/docs/platform/content/markdoc-tags/replay-openapi.md, https://redocly.com/docs/platform/content/markdoc-tags/json-schema.md

## Verify

1. For OpenAPI and AsyncAPI, `npx @redocly/cli lint apis/cafe-api.yaml` validates the description.
   Add `--extends recommended` when `redocly.yaml` configures no rules.
   GraphQL and WSDL files are checked by the preview only.
   Lint rules, bundling, and the other commands are in the `redocly-cli` skill (https://redocly.com/.well-known/agent-skills/redocly-cli/SKILL.md), and custom rules in `redocly-lint-rules` (https://redocly.com/.well-known/agent-skills/redocly-lint-rules/SKILL.md).
2. Follow Preview and verify in the `redocly` skill (https://redocly.com/.well-known/agent-skills/redocly/SKILL.md).
   Run `TERM=dumb npx @redocly/cli preview` in the background, read its output, and open the reference page.
3. After a change to `redocly.yaml`, run `npx @redocly/cli check-config`.

## Common mistakes

| Mistake | Correct approach |
| --- | --- |
| An `apis` entry to publish or move an API | The file path sets the URL |
| `hideReplay` or other options directly under `apis.<name>` | Under `openapi`, or `apis.<name>.openapi` |
| `x-tagGroups` that leaves out a tag | List every tag, as tags in no group do not show |
| `hideDownloadButtons` to protect an API | It hides buttons only, so use `x-rbac` or `access.rbac` |
| A code sample language that is not generated | Add it with `x-codeSamples` |
