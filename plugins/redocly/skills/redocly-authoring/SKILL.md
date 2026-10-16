---
name: redocly-authoring
description: >-
  Use when writing or changing content in a Redocly project: adding, moving, or renaming pages, choosing
  file names and URLs, links and images, page titles and front matter, Markdoc tags such as admonitions,
  tabs, cards, code groups, and partials, the sidebar, navbar, and footer, or site settings in redocly.yaml.
  Not for API reference docs from OpenAPI, AsyncAPI, or GraphQL files (use redocly-api-docs).
---

# Write content for a Redocly project

## The folder is the site

Realm builds the site from the project folder.
Every content file is a page, and the path of the file is the URL of the page:

| File | URL |
| --- | --- |
| `index.md` | `/` |
| `guides/quickstart.md` | `/guides/quickstart` |
| `guides/index.md` | `/guides` |
| `apis/cafe-api.yaml` | `/apis/cafe-api` (API reference, see `redocly-api-docs`) |
| `changelog.page.tsx` | `/changelog` (React page) |

A file named `index` is the page of its folder.
To change a URL, move or rename the file, and add the old URL to `redirects` in `redocly.yaml` when the page was published.

Some folders are not pages.
`_partials/` (by default) holds reusable content, and files in `static/` are copied to the site root as they are: `static/robots.txt` is served at `/robots.txt`.
Realm reserves `@theme/` (customizations), `@l10n/` (translations), `@api/`, and `@skills/`.
Any other folder that starts with `@` is a content version.
Two files that resolve to the same URL, such as `payments.md` and `payments/index.md`, get numbered URLs, so avoid them.

Full reference: https://redocly.com/docs/realm/content/project-structure.md

## Before you write

Read `redocly.yaml` and the nearest `sidebars.yaml` when they exist, as a project can have neither.
Read two or three pages next to the one you add and match their file naming, heading style, and image location.
Default to kebab-case file names when the folder has no pattern.
Search for existing content before you add a page: the right change may be a new section or a link.

## Pages

A page is Markdown with optional YAML front matter.
The first H1 is the page title.
Front matter holds the settings of one page, such as a search title that differs from the H1 or a description.
Omit it when the defaults do:

```markdown
---
seo:
  title: Rate limits for the Acme API
  description: Request limits, the 429 response, and how to retry.
---

# Rate limits
```

`slug: /custom-url` serves the page at a different URL.
Use it only when the author wants the file to stay where it is.
The other page settings, such as `rbac`, `markdown.toc`, `feedback`, or `navbar.hide`, are in the front matter reference: https://redocly.com/docs/realm/config/front-matter-config.md

## Links and images

Link to files, with their extension, relative to the page: `[Quickstart](./quickstart.md)`, `[Cafe API](../apis/cafe-api.yaml)`, `[Install](../setup/index.md#install)`.
A path that starts with `/` resolves from the project root.
Do not link to built URLs of the same site.
Realm resolves file links for locales and versions, and the preview reports a broken file link.
After moving a file, fix the links to it and the relative links inside it.

Store images where the project already stores them, otherwise in an `images/` folder next to the page.
Reference them with relative paths and alt text: `![Orders dashboard](./images/orders.png)`.
Files that need a fixed URL, such as `robots.txt`, go in `static/`.

Full reference: https://redocly.com/docs/realm/content/links.md

## Markdoc tags

Pages are Markdown, and Markdoc tags in `{% ... %}` add components when a page needs them.
A tag with content has a closing tag, and a tag without content ends with `/%}`.
Put block tags on their own lines.

```markdoc
{% admonition type="warning" name="Rate limit" %}
Requests above 100 per minute get HTTP 429.
{% /admonition %}
```

Strings are quoted, numbers and booleans are not: `columns=2`, `expanded=true`.
Child tags work only inside their parent: `tab` in `tabs`, `card` in `cards`, `numbered-item` in `numbered-list`.

| Tag | Use | Reference |
| --- | --- | --- |
| `admonition` | Callout. `type` is `info`, `warning`, `success`, `danger`, or `idea`, and the title attribute is `name` | https://redocly.com/docs/realm/content/markdoc-tags/admonition.md |
| `tabs` / `tab` | Switchable panels, and each `tab` has `label` | https://redocly.com/docs/realm/content/markdoc-tags/tabs.md |
| `code-group` | Fenced code blocks as tabs, named by the `title` fence attribute | https://redocly.com/docs/realm/content/markdoc-tags/code-group.md |
| `cards` / `card` | Link tiles, and `card` has `title` and `to` | https://redocly.com/docs/realm/content/markdoc-tags/cards.md |
| `accordion` | Collapsible section with a `title`, wrapped in `accordion-group` for an FAQ | https://redocly.com/docs/realm/content/markdoc-tags/accordion.md |
| `table` | Table with rich content in cells, where a Markdown pipe table is enough for simple data | https://redocly.com/docs/realm/content/markdoc-tags/table.md |
| `img` | Image with size, caption, lightbox, or one file per color mode | https://redocly.com/docs/realm/content/markdoc-tags/img.md |
| `icon` | Inline Font Awesome icon: `{% icon name="solid check" /%}` | https://redocly.com/docs/realm/content/markdoc-tags/icon.md |
| `partial` | Insert a file from a partials folder: `{% partial file="/_partials/note.md" /%}` | https://redocly.com/docs/realm/content/markdoc-tags/partial.md |
| `code-snippet` | Code block from a file, or a range of its lines | https://redocly.com/docs/realm/content/markdoc-tags/code-snippet.md |
| `if` / `else` | Conditional content with `equals`, `includes`, `and`, `or`, `not` on variables such as `$frontmatter` or `$rbac.teams` | https://redocly.com/docs/realm/content/markdoc-tags/if-else.md |
| `numbered-list` / `numbered-item` | Procedure steps on a rail, each step a `numbered-item` | https://redocly.com/docs/realm/content/markdoc-tags/numbered-list.md |
| `prompt` | An AI prompt that readers copy or open in Claude, ChatGPT, or Cursor with one click | https://redocly.com/docs/realm/content/markdoc-tags/prompt.md |
| `connect-mcp` | A button that connects an AI client to the site's MCP server | https://redocly.com/docs/realm/content/markdoc-tags/connect-mcp.md |
| `login-button` | A login button shown only to users who are not logged in | https://redocly.com/docs/realm/content/markdoc-tags/login-button.md |
| `code-walkthrough` | Interactive tutorial: steps on the left, highlighted code on the right | https://redocly.com/docs/realm/content/markdoc-tags/code-walkthrough.md |
| `inline-svg` | An SVG file rendered inline, so CSS can style it | https://redocly.com/docs/realm/content/markdoc-tags/inline-svg.md |
| `markdoc-example` | Markdoc source next to its rendered result | https://redocly.com/docs/realm/content/markdoc-tags/markdoc-example.md |

All tags, with every attribute: https://redocly.com/docs/realm/content/markdoc-tags/tag-library.md
Tags that show an operation or schema from an API description are in the `redocly-api-docs` skill (https://redocly.com/.well-known/agent-skills/redocly-api-docs/SKILL.md).
A project can define its own tags in `@theme/markdoc/schema.ts`, so read that file before using one.

A fenced code block takes Markdoc attributes after the language, such as `{% title="redocly.yaml" %}`.
The `treeview` language renders a folder tree, and `mermaid` renders a diagram.
Markdoc processes `{% ... %}` sequences inside a code block, and nothing else.
Add `{% process=false %}` to the fence to show them as text.

Full reference: https://redocly.com/docs/realm/content/markdown.md

## Navigation

Without a `sidebars.yaml`, Realm generates the sidebar from the folder structure.
With one, a page shows in the sidebar only when a sidebar file lists it, or lists its folder with `directory`.

```yaml
- page: index.md
  label: Overview
- group: Guides
  page: guides/index.md
  items:
    - page: guides/quickstart.md
    - page: guides/rate-limits.md
    - directory: guides/advanced
- page: apis/cafe-api.yaml
  label: Cafe API
- href: https://status.example.com
  label: Status
  external: true
```

Paths in a sidebar file are relative to that file.
The label defaults to the page title.
Large sites split into navigation tabs, one per section with its own sidebar.
Tabs are top-level `tab` entries of `sidebars.yaml`: https://redocly.com/docs/realm/navigation/navigation-tabs.md
Another option is one sidebar file per section, joined with `$ref` entries or linked from the navbar.
Leave a page out of every sidebar file to show it without a sidebar, such as a landing page.

Sidebars: https://redocly.com/docs/realm/navigation/sidebars.md

The navbar and footer are the `navbar` and `footer` objects in `redocly.yaml`, each with an `items` list.
The items take the same `page`, `href`, `label`, `external`, and `group` keys as a sidebar, with paths relative to the project root:

```yaml
navbar:
  items:
    - page: guides/index.md
      label: Guides
```

Navbar: https://redocly.com/docs/realm/config/navbar.md and footer: https://redocly.com/docs/realm/config/footer.md

## Site settings

`redocly.yaml` in the project root configures the whole site.
Paths in it are relative to the project root.

```yaml
seo:
  projectTitle: Acme docs
  siteUrl: https://docs.acme.example
redirects:
  '/old-guide/':
    to: '/guides/quickstart/'
```

A redirect source and its `to` start with `/` and leave out `index`, and `*` is valid only as the last segment.
Redirects: https://redocly.com/docs/realm/config/redirects.md
Common keys: `seo`, `redirects`, `logo`, `navbar`, `footer`, `search`, `banner`, `feedback`, `breadcrumbs`, `ignore`, `access` (login and role-based access), `analytics`, `l10n`, `products`, and `env`.
Validate the file with `npx @redocly/cli check-config`, which names unknown keys.

All options: https://redocly.com/docs/realm/config.md

## Beyond content

These exist, so load their page before changing them, and prefer the smallest change:

- Styling: CSS variables in `@theme/styles.css`, the logo and favicon in `logo`, fonts in `links`. https://redocly.com/docs/realm/branding/customize-styles.md
- Versioned content: one `@<version>` folder per version. https://redocly.com/docs/realm/content/versions.md
- Translations: `@l10n/<locale>/` folders. https://redocly.com/docs/realm/content/localization/localize-content.md
- Several products with a product picker: `products` in `redocly.yaml`. https://redocly.com/docs/realm/config/products.md
- Page templates: a React layout applied to a set of Markdown pages. https://redocly.com/docs/realm/customization.md
- Login and role-based access: `access` in `redocly.yaml`. https://redocly.com/docs/realm/config/access.md

A React page is a `*.page.tsx` file.
Its path is its URL, like a Markdown page, and it sets its front matter in code:

```tsx
import React from 'react';

export const frontmatter = { seo: { title: 'About Acme' } };

export default function AboutPage() {
  return <h1>About Acme</h1>;
}
```

Use one for a layout that Markdown cannot express, such as a landing page, and import the theme components it needs from `@redocly/theme`: https://redocly.com/docs/realm/customization/create-react-page.md

A project can define its own Markdoc tags: a tag name with typed attributes, declared in `@theme/markdoc/schema.ts`, rendered by a React component from `@theme/markdoc/components.tsx`.
Authors then write it like a built-in tag, for example `{% product-card name="Orders" /%}`.
Build one when a block repeats across pages with varying data and a partial is not enough: https://redocly.com/docs/realm/customization/build-markdoc-tags.md

Every part of the site is a React component, and any of them can be ejected.
`npx @redocly/cli eject component 'Footer/**'` copies the source into `@theme/components/`, and the copy replaces the original.
Find a component's name in the `data-component-name` attribute in the browser developer tools.
Eject only when the structure or behavior has to change, because colors, fonts, and spacing are CSS variables.
Reference: https://redocly.com/docs/realm/customization/eject-components.md

## Verify

Follow Preview and verify in the `redocly` skill (https://redocly.com/.well-known/agent-skills/redocly/SKILL.md): run `TERM=dumb npx @redocly/cli preview` in the background, read its output, and open the page.
The output reports the Markdoc errors, such as an unknown tag or attribute, and the broken links.
After a change to `redocly.yaml`, also run `npx @redocly/cli check-config`.
If `redocly.yaml` configures `recheck`, use the `recheck-lint` skill (https://redocly.com/.well-known/agent-skills/recheck-lint/SKILL.md) on the files you touched.

## Common mistakes

| Mistake | Correct approach |
| --- | --- |
| `title:` in the front matter | The H1 is the title, and `seo.title` overrides it |
| A link without the extension, or to the built URL | Link to the file: `./quickstart.md` |
| `{% admonition title="..." %}` or `{% tab title="..." %}` | `name` for admonitions, `label` for tabs |
| `{% code %}` tags inside `code-group` | Fenced code blocks with a `title` attribute |
| A new page expected in the sidebar automatically when a `sidebars.yaml` exists | Add it to `sidebars.yaml`, or use `directory` |
| A page moved without a redirect | Add the old URL to `redirects` |
| `colors` or `fonts` keys in `redocly.yaml` | CSS variables in `@theme/styles.css` |
| An option name or attribute from memory | Fetch the reference page |
