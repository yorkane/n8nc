# Localization Overrides (Low-Conflict Pattern)

This document records a reusable way to localize UI text when upstream code uses hardcoded strings and we want to minimize merge conflicts.

## Goal

- Keep upstream files as untouched as possible
- Avoid editing large shared locale files unless necessary
- Make the override easy to reuse and maintain

## Applied Pattern

1. Add a small reusable helper:
   - `src/app/utils/menuLocalizationUtils.ts`
2. In the render entry component, apply locale-specific overrides only at display time:
   - `src/app/components/MainSidebarHeader.vue`
3. For module-provided tabs, localize by stable route values in the tabs component:
   - `src/features/collaboration/projects/components/ProjectTabs.vue`
4. Keep hardcoded source logic unchanged:
   - `src/app/composables/useGlobalEntityCreation.ts` (unchanged)

## Current Override Example

In `MainSidebarHeader.vue`, when locale starts with `zh`, map menu ids to localized titles:

- `workflow` -> `工作流`
- `credential` -> `凭据`
- `create-project` -> `项目`
- `workflow-title` -> `创建于`
- `credential-title` -> `创建于`

In `ProjectTabs.vue`, localize module-provided tab labels by stable route value:

- `DATA_TABLE_VIEW` / `PROJECT_DATA_TABLES` -> `locale.baseText('dataTable.dataTables')`

## Reuse Recipe

For future similar cases:

1. Identify stable ids (menu id / route value) used by the UI model.
2. Define a locale-specific mapping object in the render-layer component.
3. Apply mapping immediately before rendering.
4. Guard by locale (`locale.startsWith('zh')`, etc.) so behavior is scoped.
5. If language is loaded asynchronously, add a reactive dependency on `i18nVersion`
   (from `@n8n/i18n`) inside computed logic so overrides update after locale switch.

## Why This Reduces Conflicts

- No edits in upstream business-generation logic
- New helper file is additive and isolated
- Render-layer patch is small and straightforward to rebase
