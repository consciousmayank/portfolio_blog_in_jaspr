# Helpful Skills for This Project

## Already Installed

| Skill | Trigger | What it does |
|---|---|---|
| `claude-jaspr` | subagent_type in Agent tool | Specialized Jaspr agent — use for all Jaspr/Dart web code |
| `flutter-use-http-package` | `/flutter-use-http-package` | HTTP POST patterns — used by contact form |
| `dart-run-static-analysis` | `/dart-run-static-analysis` | Static analysis / lint checks |
| `dart-add-unit-test` | `/dart-add-unit-test` | Unit test scaffolding |
| `dart-fix-runtime-errors` | `/dart-fix-runtime-errors` | Live stack trace → fix loop |
| `dart-use-pattern-matching` | `/dart-use-pattern-matching` | Switch expressions, pattern matching |
| `dart-generate-test-mocks` | `/dart-generate-test-mocks` | Mockito mock generation |

## Available to Install (not yet installed)

### `dart-lang/skills@dart-web-development` — 61 installs (official dart-lang)
Dart web-specific patterns that complement the Jaspr skill.
```
npx skills add dart-lang/skills@dart-web-development -g -y
```

### `travisjneuman/.claude@generic-static-design-system` — 94 installs
Design token / CSS system patterns for static sites.
Relevant for the dark-mode design system with CSS custom properties.
```
npx skills add travisjneuman/.claude@generic-static-design-system -g -y
```

## Notes

- No dedicated Jaspr skill exists in the public ecosystem (as of 2026-05-17).
- `claude-jaspr` (already available) is the best tool for Jaspr-specific work.
- `membranedev/application-skills@web3forms-contact-forms-for-static-websites` exists
  as a fallback if the PHP mailer on Hostinger proves unreliable.
