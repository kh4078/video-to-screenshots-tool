# Contributing

Thanks for taking the time. This is a small tool maintained by one person alongside other work, so responses may take a while — that's not disinterest.

> 繁體中文在下方 → [跳到中文](#中文)

## Before anything: read the scope

The [Scope section in the README](README.md#scope) lists what this tool will and won't take on. Two things in particular are settled and not up for debate:

- **No external dependencies, ever.** Zero-install is the entire point of this tool.
- **macOS only.** Using Apple's built-in frameworks is what makes zero-install possible.

If your idea needs either of those to change, it belongs in a fork, not here. That's a normal and respectable outcome — fork freely, the license allows it.

## Reporting a bug

Use the [bug report form](../../issues/new/choose). The fields exist because without them a report usually takes several rounds of back-and-forth before it's actionable.

The two most useful things you can include:

- **What kind of recording it is** — iPhone screen recording? QuickTime? OBS? Android? Container and codec if you know them.
- **The exact command you ran, and the full terminal output.** Not a summary — paste it.

## Suggesting a feature

Use the [feature request form](../../issues/new/choose). Describe **the problem you hit**, not the solution you have in mind. There may be a simpler fix that doesn't require the feature.

## Submitting code

**Please open an issue first and get a reply before you write anything.**

This isn't bureaucracy. The maintainer is a designer, not a professional developer, and reviewing a 150-line change they can't fully evaluate is a bad position for everyone. Agreeing on the approach first means your work has somewhere to land.

Once we've agreed:

1. Fork, branch off `main`
2. Keep the change **small and single-purpose** — one PR, one concern
3. Test it and say how you tested it (macOS version, chip, what video)
4. Fill in the PR template
5. **Explain what the change does in plain language**, not just code. If the maintainer can't follow it, it can't be merged.

### What makes a PR easy to accept

- It stays within scope
- It doesn't change existing command syntax (people have scripts built on it) — or if it must, it says so loudly
- It adds no dependencies
- It's readable by someone who isn't a Swift specialist

### If your PR isn't merged

It may be closed with a short explanation. That isn't a judgement of the work — usually it means the direction doesn't fit what this tool is trying to stay. Forking and maintaining your own version is a completely legitimate path and is explicitly encouraged.

---

<a name="中文"></a>

# 參與本專案

感謝你願意花時間。這是一個人在工作之餘維護的小工具,回覆可能會慢,不是不理你。

## 動手前:先看範圍

[README 的「範圍」一節](README.md#範圍)寫了這個工具接受和不接受什麼方向。其中兩件事是定案,不會改:

- **永遠不引入外部相依套件。** 「不用裝任何東西」就是這個工具存在的理由。
- **只支援 macOS。** 用蘋果內建框架,才做得到不用安裝。

如果你的想法需要改變這兩點,那它適合放在 fork(你自己複製一份維護),而不是這裡。這是很正常也值得尊重的做法 —— 授權條款允許你自由 fork。

## 回報問題

請用[問題回報表單](../../issues/new/choose)。那些欄位存在是有原因的:少了它們,一則回報通常要來回問好幾輪才知道發生什麼事。

最有用的兩項資訊:

- **你的錄影是什麼來源** —— iPhone 螢幕錄影?QuickTime?OBS?Android?知道格式和編碼的話也附上。
- **你下的完整指令,以及終端機的完整輸出。** 不要摘要,直接貼上。

## 提出功能建議

請用[功能建議表單](../../issues/new/choose)。描述**你遇到的問題**,而不是你想到的解法 —— 有可能有更簡單的做法,不需要加這個功能。

## 提交程式碼

**請先開一個 Issue,等到回覆之後再開始寫。**

這不是官僚流程。維護者是設計師而不是專業工程師,收到一個 150 行、他無法完全判斷對錯的修改,對雙方都是尷尬的處境。先談好方向,你的工作才有地方著陸。

談好之後:

1. Fork 一份,從 `main` 開新分支
2. **一個 PR 只做一件事**,改動保持小
3. 測過,並說明你怎麼測的(macOS 版本、晶片、用什麼影片)
4. 填寫 PR 範本
5. **用白話說明這個修改做了什麼**,不要只有程式碼。維護者看不懂的東西沒辦法合併。

### 什麼樣的 PR 容易被接受

- 在範圍內
- 不改變既有的指令用法(有人已經寫了腳本在用)—— 如果非改不可,要明確講出來
- 不增加任何相依套件
- 不是 Swift 專家也讀得懂

### 如果你的 PR 沒有被合併

它可能會被關閉並附上簡短說明。**這不是對你的工作的評價** —— 通常只是方向不符合這個工具想維持的樣子。Fork 一份自己維護是完全正當的選擇,而且我們鼓勵這麼做。
