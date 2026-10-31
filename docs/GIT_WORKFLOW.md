# GitHub 推送与协作规则

> 本文是 **GitHub 侧的操作规则**：分支、推送、PR、合并、发布、出错怎么救。
> 规则的**定义权**在 [CODE_STYLE.md](CODE_STYLE.md) §14（提交信息、分支模型、PR 规模、评审）；本文只做落地与补充，冲突时以 CODE_STYLE 为准。
> 目标读者：仓库 owner、未来的贡献者、以及在本仓库工作的 AI 代理。

---

## 0. 三条不可协商

1. **`main` 永远可直接发布。** 任何时候 `main` 上的提交都应该能构建、能测过、能发版。
2. **`main` 不接受直接 push，也不接受 force-push。** 所有改动走 PR（唯一例外：仓库初始化那一次）。
3. **CI 不绿不合并。** 没有「这次特殊，我先合了再说」。

违反这三条的操作，即使内容正确也要回退重来 —— 因为代价不在这次，在下一次别人被迫救火。

---

## 1. 分支模型（trunk-based）

```
main ──●──●────●────●────●──▶  常绿，只接受 squash 合并
        \        \        \
     feat/x    fix/y    docs/z   短分支，存活 ≤ 3 天
```

| 分支 | 用途 | 从哪切 | 合到哪 | 存活期 |
| --- | --- | --- | --- | --- |
| `main` | 唯一长期分支，永远可发布 | — | — | 永久 |
| `feat/<slug>` | 新功能 | `main` | `main`（squash） | ≤ 3 天 |
| `fix/<slug>` | 修 bug | `main` | `main`（squash） | ≤ 3 天 |
| `docs/<slug>` | 纯文档 | `main` | `main`（squash） | ≤ 3 天 |
| `chore/<slug>` | 构建、依赖、CI | `main` | `main`（squash） | ≤ 3 天 |
| `release/vX.Y.Z` | 发版前的稳定化（仅打 tag、改 CHANGELOG） | `main` | `main` | ≤ 1 天 |
| `hotfix/<slug>` | 线上紧急修复 | `main` 上的 tag | `main` | ≤ 1 天 |

规则：

- 分支名全小写、用 `-` 分隔，**不要**中文、不要下划线、不要带 `wip`。
- 一个分支只做一件事；做完即删（GitHub 上开启 Automatically delete head branches）。
- **不要**从别人的功能分支切分支；需要依赖就先合进 `main`。
- 存活超过 3 天说明 PR 太大，拆它，不要硬撑。

---

## 2. 推送规则

### 2.1 允许

| 操作 | 条件 |
| --- | --- |
| `git push origin feat/xxx` | 自己的分支，随时 |
| `git push --force-with-lease origin feat/xxx` | **仅**自己的分支，且没有他人基于它工作时 |
| `git push origin v1.2.3`（tag） | 符合 §6 的发版流程 |
| `git push` 到 `main` | **仅**仓库初始化的第一次提交 |

### 2.2 禁止

| 操作 | 原因 |
| --- | --- |
| `git push origin main` | 绕过 PR 与 CI，`main` 失去可信度 |
| `git push --force` / `--force-with-lease` 到 `main` | 会改写公共历史，别人的 clone 直接坏掉 |
| `git push` 到别人的分支 | 除非对方明确同意 |
| 覆盖已发布的 tag（`git tag -f`） | 版本号对应的代码必须永久可复现 |
| `git push --mirror` / `--all` | 会顺带推送本地实验分支与 tag |
| 推送含密钥、签名文件、正版书籍样本的提交 | 见 §7，一旦推上去就当已泄露 |

### 2.3 推之前固定跑

```bash
dart run tool/tasks.dart check     # format --set-exit-if-changed + analyze + test
```

本地 hook 只是提示，**真正的门是 CI**。跳过 hook 不会让 CI 变绿。

---

## 3. GitHub 仓库设置（一次性）

在 `Settings` 里逐项核对，这些是「规则」的一部分，不是可选项：

### 3.1 Branches → Branch protection rules（`main`）

| 选项 | 值 | 为什么 |
| --- | --- | --- |
| Require a pull request before merging | ✅ | 唯一例外是初始化提交 |
| Require approvals | 1（单人阶段可设 0，但保留 PR 流程） | 有贡献者后必须打开 |
| Dismiss stale pull request approvals when new commits are pushed | ✅ | 防止「批完又改」 |
| Require status checks to pass | ✅ `analyze`、`test`、`format`、`lint` | CI 是唯一门禁 |
| Require branches to be up to date before merging | ✅ | 防止「本地绿、合完红」 |
| Require conversation resolution | ✅ | 未回复的 review 意见不能被忽略 |
| Require linear history | ✅ | 配合 squash，`main` 上不出现 merge commit |
| Do not allow bypassing the above settings | ✅ | 包括 owner 自己 |
| Allow force pushes | ❌ | 硬性禁止 |
| Allow deletions | ❌ | 误删 `main` 是灾难 |

### 3.2 General → Pull Requests

| 选项 | 值 |
| --- | --- |
| Allow merge commits | ❌ |
| Allow squash merging | ✅（默认，且是唯一方式） |
| Allow rebase merging | ❌ |
| Default commit message for squash | **Pull request title** |
| Automatically delete head branches | ✅ |

### 3.3 其它

- `Settings → General → Default branch`：`main`。
- Issues 打开；Discussions 在 M3 之后再开（先别分散注意力）。
- Topics：`flutter`、`ebook-reader`、`epub`、`txt`、`chinese`、`novel`、`mit`。
- Description：`本地优先的开源中文小说阅读器 · Flutter · 不内置书源`。

---

## 4. Commit 规则（摘要）

完整 scope 表见 [CODE_STYLE.md](CODE_STYLE.md) §14.1，这里只列最容易错的四条：

1. **英文、祈使句、首行 ≤ 72 字符**：`fix(reader): keep page anchor when font size changes`。
2. **一个 commit 一件事**；功能 + 格式化 + 重构混在一起必须拆。
3. **body 写为什么**，不写「改了哪些文件」（diff 已经说了）。
4. 禁止 `wip`、`update`、`fix bug`、`临时提交`。

如果分不清 type：改行为的用 `fix`/`feat`，不改行为的用 `refactor`/`docs`/`chore`/`test`。

---

## 5. PR 规则

### 5.1 流程

```
切分支 → 小步 commit → 本地 dart run tool/tasks.dart check → 开 PR（draft 可选）
   → CI 绿 → 自查/评审 → squash merge → 分支自动删除
```

### 5.2 硬性要求

| 项 | 要求 |
| --- | --- |
| 标题 | 同 commit 规范（squash 后它就是 `main` 上的提交信息） |
| 规模 | ≤ 400 行（不含生成文件与 fixtures），超了拆 |
| 内容 | 只做一件事；顺手重构单独开 PR |
| CI | 全绿才能合并 |
| 描述 | 必填「为什么 / 怎么验 / 风险」，模板见下 |
| 生成物 | 改了模型/表/ARB 必须带 `dart run tool/tasks.dart gen` 的结果 |
| 架构变更 | 附 ADR 链接 |
| 用户可见变更 | `CHANGELOG.md` 有 `Unreleased` 条目 |

### 5.3 PR 描述模板

```markdown
## 为什么
<问题是什么、影响谁；不要复述 diff>

## 改了什么
- <要点，3 条以内>

## 怎么验
- [ ] `dart run tool/tasks.dart check` 绿
- [ ] <手动验证步骤 / 截图 / 录屏>

## 风险与回滚
<会不会让旧页表失效、要不要迁移、出问题怎么退>
```

### 5.4 合并

- **只用 Squash**，合并后 `main` 上是**一条**提交。
- 合并前确认分支基于最新 `main`（`git rebase origin/main`），避免「合完才发现 CI 红」。
- 合并后立刻删分支，不留「备用」。

---

## 6. Tag 与发布

```bash
# 1. 从最新 main 切发版分支（只改版本号与 CHANGELOG）
git switch -c release/v0.1.0

# 2. 改 pubspec.yaml 的 version 与 CHANGELOG.md，提交
git commit -m "chore(release): prepare v0.1.0"

# 3. 打 annotated tag（必须带注释，不用轻量 tag）
git tag -a v0.1.0 -m "modoo_reader v0.1.0"

# 4. 推 tag 与分支
git push origin release/v0.1.0
git push origin v0.1.0

# 5. 在 GitHub 上基于该 tag 发 Release，粘贴 CHANGELOG 对应段落 + 签名 APK 的 SHA256
```

规则：

- 版本号 **SemVer**：`vMAJOR.MINOR.PATCH`；预发布用 `v0.5.0-beta.1`。
- **tag 一旦推送永不移动**。发错了就发新 patch 版本，不要 `tag -f`。
- `tag` 与 `pubspec.yaml` 的 `version`、`CHANGELOG.md` 的段落必须一致，CI 会比对。
- Release 附件只放构建产物与校验值，**不放书籍样本**。

---

## 7. 不能提交的东西

| 类别 | 例子 | 处理 |
| --- | --- | --- |
| 密钥/凭据 | `.env`、API key、WebDAV 密码 | 不进仓库；本地 `.env` 已被 `.gitignore` 拦 |
| 签名材料 | `*.jks`、`*.keystore`、`key.properties` | 只放 CI Secrets 与本地，绝不入库 |
| 版权内容 | 正版 txt/epub 全文、书源规则集合 | 违反项目底线；测试只用公版或自造样本 |
| 大二进制 | > 5MB 的字体/图片/数据库 | 用 LFS 或外链；先问再提交 |
| 生成物垃圾 | `.dart_tool/`、`build/` | 已在 `.gitignore` |

**误提交了密钥怎么办**：立刻轮换密钥 → 再处理历史（`git filter-repo` 属于改写历史，必须 owner 批准并全员重新 clone）→ 不要只删文件了事，历史里还在。

---

## 8. 同步与冲突

- 更新分支用 **rebase**，不要 `merge main into feat`：
  ```bash
  git fetch origin
  git rebase origin/main
  ```
- rebase 后必须**重跑** `dart run tool/tasks.dart check`，冲突解决很容易引入编译不过的代码。
- 冲突解决原则：**保留行为，不要保留文本**。看不懂就问，不要「两边都留下」。
- 已 push 的分支 rebase 后推送要用 `--force-with-lease`，**永远不要**裸 `--force`。

---

## 9. 紧急修复（hotfix）

```
线上崩 → 从对应 tag 切 hotfix/xxx → 最小改动 → 测试 → PR 到 main（squash）
   → 打新 patch tag（如 v1.0.0 → v1.0.1）→ 补 CHANGELOG
```

- hotfix 也要走 PR 与 CI，**紧急不是跳过的理由**。
- 只修崩溃点，不夹带重构。
- 修完在 `main` 上验证一次完整构建，再发版。

---

## 10. 常见报错与处置

| 报错 | 原因 | 处置 |
| --- | --- | --- |
| `! [rejected] ... (non-fast-forward)` | 远端有你没有的提交 | `git pull --rebase` 后再推；**不要** `--force` |
| `! [rejected] ... (fetch first)` | 同上 | 先 `git fetch`，再 rebase |
| `remote: error: GH006: Protected branch update failed` | 直接推了 `main` | 改成切分支 + 开 PR |
| `! [remote rejected] ... (pre-receive hook declined)` | 分支保护或大小限制 | 看完整报错，通常是权限或文件过大 |
| `fatal: refusing to merge unrelated histories` | 两个独立仓库历史 | 用 `git rebase --onto` 或 `--allow-unrelated-histories`，先确认没有丢代码 |
| `Updates were rejected because the tip of your current branch is behind` | 同 non-fast-forward | rebase 后 `--force-with-lease`（仅自己分支） |
| `Permission denied (publickey)` | SSH key 未配置 | 见 §11 |
| `HEAD detached at ...` | 检出了 tag 或旧提交 | `git switch -c <分支名>` 再接续 |
| `error: failed to push some refs` 且无更多信息 | 常见于代理断开 | 检查代理端口与 `~/.ssh/config` |

---

## 11. 本机 Git 与 SSH 配置（本仓库实测）

| 项 | 值 |
| --- | --- |
| 远端 | `git@github.com:WindSky9975/modoo_reader.git` |
| 默认分支 | `main` |
| 代理 | `http://127.0.0.1:7897`（`git config http.proxy` / `https.proxy`） |
| SSH key | `~/.ssh/google_id_rsa`（GitHub 用这个，不是 `qq_id_rsa`） |
| 行尾 | 全仓 LF（见 `.gitattributes`） |

自检：

```bash
ssh -T git@github.com          # 期望：Hi <user>! You've successfully authenticated...
git ls-remote --heads origin   # 期望：列出 refs/heads/main
```

**已知坑**：`~/.ssh/config` 里 `github.com` 的 `ProxyCommand` 仍写着 `127.0.0.1:7890`，而实际代理在 `7897`。目前靠「探测失败自动退回直连」的分支还能通 —— **直连被墙时就会失败**。修法：把该行里的 `7890` 全部改成 `7897`。

CI 环境不依赖上面的本地配置；CI 用 `GITHUB_TOKEN` 读仓库，发版用受保护的环境密钥。

---

## 12. 本地等价检查

推送前想一次过，跑这些（CI 跑的就是同一套）：

```bash
dart run tool/tasks.dart check        # 主门禁
dart run tool/tasks.dart gen          # 生成物是否最新（CI 会 diff）
git diff --check       # 空白字符错误
git log origin/main..HEAD --oneline   # 确认这次要推的提交
```

---

## 变更记录

| 版本 | 日期 | 变更 |
| --- | --- | --- |
| v1.0 | 2026-10-31 | 首版：分支模型、推送禁令、仓库设置清单、commit/PR/tag 规则、密钥与冲突处置、常见报错表、本机 SSH 现状 |
