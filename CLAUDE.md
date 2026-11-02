# Pharmaapp

Flutter monorepo. Apps are in `apps/` (`pharmmed`, `pharmabtob`, `pharmaadmin`) and shared packages are in `packages/` (including `packages/features/*`). See `README.md`.

## Writing prompts for other LLMs

When asked for "a prompt", write it as a copy-paste `.md` file in the repo root, named like `PHARMMED_<FEATURE>_PROMPT.md`. These prompts are run by **weaker models (e.g. Nemotron)**. They skip steps, guess API types, and invent classes, so write for that.

**Before writing the prompt:**
1. Read the real code the feature touches. List every file that must change.
2. Write down every existing API it must call, with its exact signature (`Future`/async, nullable types). Example: `KeyValueStore.read` is `Future<String?> read(String key)` and must be awaited.
3. Make every design decision yourself. Never write "if X works use it, otherwise build Y".

**Every prompt must contain:**
- **Files you may change:** an explicit list. Nothing outside it, and no edits to unrelated comments or config.
- **Existing APIs:** exact signatures and the real names of design-system members. Forbid inventing new ones. If one is missing, use an existing one.
- **Finished code for the tricky parts:** routing and redirects, platform config (Podfile, AndroidManifest, Info.plist, Gradle), async checks, lifecycle observers, permission flows. Only describe the simple UI.
- **Small numbered steps.** After each step: run `flutter analyze` and paste the raw output. If there are any errors or warnings, stop and fix them before continuing.
- **Common mistakes to avoid,** specific to the task.
- **Checks the model can run without a device:** grep for code that must exist, a successful `flutter build apk --debug`, and widget tests where possible. Don't rely on manual device test tables.
- **Final report:** the files changed and the last `flutter analyze` output, verbatim.

**After writing:** reread the prompt as the weak model would, and fix every place where it could guess wrong. For large features, split the work into 2–3 prompts that run one after another (e.g. service/platform → UI → routing).

## Project facts that models tend to get wrong

- `permission_handler_android` stays overridden at `13.0.1` under `dependency_overrides`, because AGP is 8.11. Don't also add it to `dependencies`.
- iOS permissions need `PERMISSION_<NAME>=1` macros inside `post_install → installer.pods_project.targets.each → target.build_configurations.each` in `apps/pharmmed/ios/Podfile`.
- Before using any `AppColors`, `AppSpacing` or `AppTypography` member, check that it exists in `packages/design_system/lib/src/theme/`.
