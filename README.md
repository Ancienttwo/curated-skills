# curated-skills

精选的第三方 Agent Skills（Claude Code / Codex 等），并记录每个 skill 的上游来源，方便升级。
Curated third-party agent skills, with each skill's upstream source recorded for easy upgrades.

## 规则 / Policy

- 只有上游许可证允许再分发的 skill 才会被收录（vendored）到 `skills/<name>/`，并原样保留 LICENSE / NOTICE / CITATION 文件。
  Only skills whose upstream license permits redistribution are vendored into `skills/<name>/`, with LICENSE/NOTICE/CITATION kept intact.
- 无许可证或禁止再分发的 skill 仅登记来源（source-only），不存放副本；`install` 时直接从上游固定 commit 拉取。
  Skills without a license (or that forbid redistribution) are source-only: listed in `sources.json`, no copy here; `install` fetches them from upstream at the pinned commit.
- 为保持仓库小巧，上游的示例 `.mp4` 视频被移除（如 live-panel 的 `examples/*/*.mp4`），请到上游查看。
  To keep the repo small, upstream example `.mp4` videos are dropped (e.g. live-panel `examples/*/*.mp4`); see upstream for them.

## Skills

| Skill | Upstream | License | Vendored |
|---|---|---|---|
| `live-panel` | [ythx-101/live-panel-skill/.](https://github.com/ythx-101/live-panel-skill) @ `2ca517fd774b` | MIT (+ OFL-1.1 font, ISC Lucide icons; see NOTICE) | ✅ |
| `remotion-best-practices` | [remotion-dev/skills/skills/remotion-best-practices](https://github.com/remotion-dev/skills/tree/main/skills/remotion-best-practices) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-create` | [remotion-dev/skills/skills/remotion-create](https://github.com/remotion-dev/skills/tree/main/skills/remotion-create) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-markup` | [remotion-dev/skills/skills/remotion-markup](https://github.com/remotion-dev/skills/tree/main/skills/remotion-markup) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-studio` | [remotion-dev/skills/skills/remotion-studio](https://github.com/remotion-dev/skills/tree/main/skills/remotion-studio) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-render` | [remotion-dev/skills/skills/remotion-render](https://github.com/remotion-dev/skills/tree/main/skills/remotion-render) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-maps` | [remotion-dev/skills/skills/remotion-maps](https://github.com/remotion-dev/skills/tree/main/skills/remotion-maps) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-captions` | [remotion-dev/skills/skills/remotion-captions](https://github.com/remotion-dev/skills/tree/main/skills/remotion-captions) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-saas` | [remotion-dev/skills/skills/remotion-saas](https://github.com/remotion-dev/skills/tree/main/skills/remotion-saas) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-interactivity` | [remotion-dev/skills/skills/remotion-interactivity](https://github.com/remotion-dev/skills/tree/main/skills/remotion-interactivity) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-docs` | [remotion-dev/skills/skills/remotion-docs](https://github.com/remotion-dev/skills/tree/main/skills/remotion-docs) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-upgrade` | [remotion-dev/skills/skills/remotion-upgrade](https://github.com/remotion-dev/skills/tree/main/skills/remotion-upgrade) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |
| `remotion-multimedia` | [remotion-dev/skills/skills/remotion-multimedia](https://github.com/remotion-dev/skills/tree/main/skills/remotion-multimedia) @ `7ba4dcf8ebe1` | NONE (no LICENSE file upstream; not redistributable) | ❌ source-only |

> Remotion skills（[docs](https://www.remotion.dev/docs/ai/skills)）的上游仓库 `remotion-dev/skills` 目前没有 LICENSE 文件，因此默认保留所有权利，这里不再分发，只记录来源。
> The upstream `remotion-dev/skills` repo currently has no LICENSE file (all rights reserved by default), so it is source-only here. Official install: `npx skills add remotion-dev/skills`.

## 用法 / Usage

Requires `bash`, `git`, `jq`, `rsync` (macOS & Linux).

```bash
./update.sh                     # 更新全部到上游最新，刷新 commit_sha 并显示 diff 摘要 / update all to upstream HEAD
./update.sh live-panel          # 只更新一个 / update one skill
./update.sh --dry-run live-panel # 预览，不改动 / preview only
./update.sh install             # 安装到 ~/.claude/skills 与 ~/.agents/skills / install all
./update.sh install remotion-docs --dry-run
```

更新后检查 `git diff`，并重新确认上游许可证没有变化，再提交。
After updating, review `git diff` and re-check upstream licenses before committing.

`sources.json` fields: `name, upstream_url, path_in_upstream, commit_sha, license, vendored, installed_to`.
