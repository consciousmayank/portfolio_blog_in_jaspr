# Claude Design — MJ Admin prompt

Paste the block below into Claude Design. Tweak the bracketed `[notes to you]`
lines before sending if needed.

---

## Prompt

Design a **mobile-first content management admin app** for a senior Flutter
developer's personal portfolio + blog site (mayankjoshi.in). The app already
exists and works (Flutter, Material 3, Riverpod, go_router) — I want you to
**redesign the UI** to feel as intentional and editorial as the public site it
manages.

### Target platforms

- **Primary:** Android phones (5.5"–6.7"). Designed for one-handed thumb
  reach.
- **Secondary:** iOS phones, with the same layout; respect iOS safe-area
  insets and Cupertino-flavored transitions where natural.
- **Tertiary (nice-to-have):** Tablet / desktop adaptive layout — side rail
  + two-column content for ≥900 dp width.

### Visual language

Match the **editorial / mono-serif vibe** of the public site
(<https://mayankjoshi.in>). Specifically:

- **Type:** Display headings in *Instrument Serif* (italic for emphasis,
  matches the "next thing" / "own voice" pull-quotes on the marketing page).
  Body in *Geist Sans*. Numbers and code in *Geist Mono*.
- **Palette:** Choose a default theme that feels closer to the public site's
  `editorial` theme (warm off-white `#f0ebe0` / `#e8e1d5` surfaces, plum
  accent `#8a5a8c`), but support a `dark` variant that mirrors the public
  site's `terminal` theme (navy `#14192c` / `#18203a` with a cooler blue
  accent `#6ba3d6`).
- **Density:** comfortable, not tight. Inspired by Notion/Linear's
  whitespace — generous side margins, 16dp base unit, 8dp on dense lists.
- **Voice:** copy in tooltips and empty states is direct and slightly
  self-aware. No "Awesome!" — more "Saved." Same tone as the marketing copy.

### Screens

The app has 9 screens accessed from a left navigation rail (≥900 dp) or
collapsible drawer (<900 dp). Design each in both default + dark themes,
include a phone (~390 × 844 dp) and a tablet (~1024 × 768 dp) frame for
the ones marked `[tablet]`.

1. **Login** — email + password, "Change API URL" hidden behind a link.
   Should feel like signing into your own workshop, not a corporate SaaS.

2. **Shell** — global nav with: Blog, Timeline, Skills, Experiments,
   Messages, Settings. App bar shows current section + a Save / primary
   action when relevant. Logout in the app bar trailing slot.

3. **Blog list** — `[tablet]` table-like list of posts with:
   - publish toggle inline (the most-used control — should be reachable
     by thumb)
   - title, date, tags
   - search bar at the top
   - FAB "New post" at bottom right

4. **Blog editor** — `[tablet]` THE most-used screen. On phone, the editor
   is the hero — collapsible "Post details" card at the top (title, slug,
   date, published, description, tags, cover image), then **Input / Output
   tabs** filling the rest. Horizontal swipe between tabs, vertical drag
   scrolls within. Markdown in a monospace TextField; preview rendered via
   flutter_markdown. App bar: back, post title (or "New post"), delete,
   prominent Save. Show unsaved-changes badge if the user navigates away.

5. **Timeline editor** — `[tablet]` Career timeline (Roles). Reorderable
   list (drag handle), each row: company · title · start–end · "lead"
   chip. Tap to edit in a sheet. FAB "New role".

6. **Skills editor** — `[tablet]` Tabs at the top:
   - **Core skills**: list with name, years, percent slider, "hot" flag
   - **stateManagement / aiStack / architecture / webOps / platforms**:
     each is a reorderable chip cloud with an "add new" affordance
   Sticky "Save" button at the bottom.

7. **Experiments editor** — `[tablet]` Cards (code, status pill, title,
   body, meta, span 4/6, nested demo lines with style tag). Each demo line
   is a row with `[line text | style pill]`. Add/remove/reorder lines.

8. **Messages** — `[tablet]` Read-only inbox of contact-form submissions.
   List view with delivered status (green check / red exclamation), name,
   subject, age. Tap expands to show full message + IP + UA + a Reply
   button that copies `mailto:…` to clipboard.

9. **Settings** — Change admin password (current + new + confirm), change
   API base URL, app version, a "Sign out" CTA at the bottom.

### Interaction details that matter

- **Save button** is always primary, always reachable. Snackbar feedback on
  save (`Saved.`) and on error (`Save failed — tap to retry`).
- **Destructive actions** (delete a post, drop a role) → confirmation
  dialog with a tinted red button. No "Are you sure?" — write the actual
  consequence: "Delete this post permanently?"
- **Loading states**: skeleton shimmer for list screens, simple spinner
  inside Save buttons.
- **Empty states**: every list ("No posts yet — first idea?") with a quick
  affordance to add one.
- **Markdown editor**:
  - tab to switch between Input and Output
  - autocorrect / smart-quotes OFF (already enforced in code)
  - monospace font
  - simple toolbar (optional): bold, italic, h2, link, list, code fence
- **Inbox unread indicator**: bold + a small dot in the side rail until
  the operator has opened Messages once after a new submission.

### Out of scope (don't design these)

- Multi-user / roles / permissions
- Comments / RSS / search
- iOS App Store screenshots
- Onboarding tour
- 2FA enrollment screen

### Deliverables I want

1. **Hi-fidelity Figma frames** for each of the 9 screens, in both the
   default and dark themes, phone size (390 × 844).
2. **Tablet frame** for the 6 screens tagged `[tablet]` (1024 × 768
   landscape).
3. **A short style guide page** showing: color tokens (with hex), type
   scale, button states, chip styles, card styles, the snackbar /
   confirmation dialog patterns.
4. **Two empty-state illustrations** (Messages inbox + Blog list) drawn
   in the same line-art / editorial style as the marketing site's
   typographic flourishes. Monochrome ink stroke, accent color sparingly.
5. **An "interaction patterns" page** (one frame) showing: the Save
   button in idle / pressed / saving / saved-snackbar states; the
   reorderable list drag state; the markdown tab swipe.

### References

- The public site this admin manages — visit <https://mayankjoshi.in>;
  the design language there is what the admin should feel like a quiet,
  back-of-house version of. Note the eyebrow micro-numbering ("02 — The
  12-year arc"), the italic emphasis, the muted code-comment chrome.
- Linear's settings screens for two-column form layout density.
- Notion's mobile editor for the tabbed editor pattern done well.

### What NOT to do

- No glassmorphism, no gradients, no rounded-pill nav.
- No bottom navigation bar — drawer or rail keeps the screen clean for
  long-form editing.
- No emoji-heavy empty states. Use the line-art illustrations instead.

When you're done, give me the frames as a Figma file link + a PDF
exported summary I can share with myself across devices.

---

## Tips when you paste this

- Hand Claude a screenshot of `https://mayankjoshi.in` first so it can
  reference the actual aesthetic of the public site.
- After the first pass, iterate by asking for specific screens to be
  redone with new constraints ("redo Blog Editor with a sticky bottom
  Save bar instead of app-bar Save").
- Ask explicitly for the Figma file link if the model leaves it implied.
