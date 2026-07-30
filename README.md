# Video to Screenshots Tool

**Turn a screen recording into a set of readable screenshots — for people to review, not for machines to decide.**

Record a walkthrough of an app on your phone, and this tool gives you a contact sheet of the whole session so you can pick the frames that matter, then pull those exact moments at full resolution.

Built for product walkthroughs, IA audits, UI archiving, and competitor research.

> 繁體中文說明在下方 → [跳到中文](#繁體中文)

---

## ⚠️ Before you start

- **macOS only.** This uses Apple's built-in AVFoundation framework. It will not run on Windows or Linux, and that is a deliberate design choice — see [Scope](#scope).
- **Tested on iPhone screen recordings (`.MP4`, H.264).** Other sources probably work, but are untested. If yours doesn't, please [open an issue](../../issues/new/choose) — that feedback is genuinely useful.
- Requires **Xcode Command Line Tools** (for the Swift compiler). Nothing else. No Homebrew, no ffmpeg, no packages.

## Why this exists

Most frame-extraction tools want you to install ffmpeg, which usually means installing a package manager first. If you're a designer who just wants screenshots out of a screen recording, that's a lot of machinery to take on.

This is two small Swift programs that call frameworks macOS already ships with. You compile them once and you're done. Delete the folder and nothing is left behind.

## Install

```bash
# 1. Make sure the Swift compiler is available (ships with Xcode Command Line Tools)
swiftc --version
#    If that fails:  xcode-select --install

# 2. Clone and build
git clone https://github.com/kh4078/video-to-screenshots-tool.git
cd video-to-screenshots-tool
swiftc frames.swift  -o frames
swiftc montage.swift -o montage
```

You'll see two deprecation warnings when building. They're harmless — see [Known limitations](#known-limitations).

## Usage

### `frames` — pull stills out of a video

```bash
# Every N seconds
./frames <video> <outdir> <interval> <maxWidth>
./frames rec.mp4 ./overview 15 480

# Specific timestamps (set interval to 0)
./frames <video> <outdir> 0 <maxWidth> <sec> <sec> ...
./frames rec.mp4 ./final 0 1206 78 135 190
```

Output files are named `t<seconds>.jpg` (e.g. `t0078.0.jpg`).

Set `FRAMES_FORMAT=png` for lossless PNG output — **use this for final captures**, since JPEG compression puts visible artifacts around UI text:

```bash
FRAMES_FORMAT=png ./frames rec.mp4 ./final 0 1206 78 135 190
```

### `montage` — build a contact sheet

```bash
./montage <indir> <output.jpg> <columns> <thumbWidth>
./montage ./overview ./sheet.jpg 9 200
```

Each tile is labelled with its timestamp (`1:18 (78s)`), so you can read the sheet and know exactly which second to pull.

> The two tools are a matched pair: `montage` reads `.jpg` files and parses the time out of `frames`' filenames. Change one side's output format and you must change the other.

## The workflow

The middle step is the point of the whole tool.

```bash
# 1 · Sweep — a small thumbnail every 15 seconds
./frames "recording.mp4" ./01_sweep 15 480

# 2 · Contact sheet — read this, pick the seconds you want
./montage ./01_sweep ./sheet.jpg 9 200

# 3 · Capture — those exact seconds, full resolution, lossless
FRAMES_FORMAT=png ./frames "recording.mp4" ./02_picked 0 1206 78 135 190

# 4 · Take them wherever you work (Figma, a doc, a slide deck)
```

A 12-minute recording is over 20,000 frames. Step 2 turns that into one image you can scan in a few seconds. **You** decide what matters; the tool just makes deciding fast.

Recording tips that make a big difference:

- **One recording per section**, named for what it covers (`home.mp4`, `checkout.mp4`) — not one long recording that jumps around
- **Pause 1–2 seconds on each screen** so you capture the screen, not a transition blur
- **Back out to the previous level** before going into the next branch, so the path stays legible
- If a page scrolls, **scroll it all the way to the bottom** — you can't recover content that was never on screen

## Using it with an AI assistant

Many people will use this alongside Claude, Cursor, or similar: the tool sweeps, the assistant reads the contact sheet and proposes timestamps, you approve. That works well, but the assistant will infer a lot from a short brief, and it can infer wrong.

Say these four things up front and you'll avoid most rework:

| Tell it | Why it matters |
|---|---|
| **Full scroll of every page, or one representative frame each?** | "IA audit" can mean either. This is the single biggest source of redo. |
| **Do you want states?** (empty, loading, error, modals) | Otherwise you get only the happy path. |
| **Split variants of the same page?** (delivery vs. pickup, different regions) | These change the information architecture, not just the content. |
| **Include OS-level UI?** (share sheets, control center) | Usually no — but say so. |

Also worth knowing: **read contact sheets at 400px per tile or wider.** At 240px you can't read page titles, and page titles are the most reliable way to tell one screen from another.

## Scope

**In scope**

- Frame accuracy, output formats and quality
- Contact sheet readability — columns, labels, layout
- Compatibility with more recording sources (Android, QuickTime, OBS, …)
- Naming schemes, batch processing across multiple videos
- Clearer error messages

**Out of scope**

- **Windows / Linux support.** Using macOS's built-in frameworks is what makes this zero-install. Porting it means taking on a dependency, which defeats the point.
- **External dependencies of any kind.** No packages, no ffmpeg. This is the tool's only real advantage over the alternatives.
- **Video editing, transcoding, compression.** That's ffmpeg's job and ffmpeg is better at it.
- **A GUI.**
- **Automatically deciding which frames matter.** Selection needs to know your goal, and only you know that. The tool's job is to make *your* selection fast — not to replace it.

That last one is a principle, not a limitation. Automated selection hides what it skipped and gives you no way to say "no, 60 seconds, not 58."

## Known limitations

1. **Two build warnings** (`asset.duration`, `copyCGImage` are deprecated APIs). Harmless; fixing them means moving to the async API surface.
2. **Frame tolerance is 0.3s** for speed. If you need to land exactly on a specific frame, set `requestedTimeToleranceBefore/After` to `.zero` in `frames.swift` — it gets slower.
3. **Only tested on iPhone screen recordings.** Reports about other sources are welcome.
4. `montage` assumes every image in the folder shares the first one's aspect ratio.

## Contributing

Bug reports and ideas are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

**If you want to write code, please open an issue first** so we can agree on the direction. It saves you from building something that won't be merged.

## License

MIT — see [LICENSE](LICENSE).

---

<a name="繁體中文"></a>

# Video to Screenshots Tool（繁體中文）

**把螢幕錄影變成一組看得懂的截圖 —— 給人判讀,不是讓機器替你決定。**

用手機錄下 App 的操作過程,這個工具會幫你把整支影片變成一張「總覽表」,讓你一眼挑出需要的畫面,再把那幾個時間點以全解析度抽出來。

適合:產品走查、資訊架構(IA)盤點、既有系統畫面備存、競品分析。

## ⚠️ 開始前要知道的事

- **只能在 macOS 上跑。** 它用的是蘋果系統內建的 AVFoundation 框架,Windows 和 Linux 完全不支援 —— 這是刻意的設計選擇,原因見「[範圍](#範圍)」。
- **只在 iPhone 螢幕錄影(`.MP4`)上實測過。** 其他來源理論上可行但沒測過。如果你的檔案跑不起來,請[開一個 Issue](../../issues/new/choose) 告訴我,那對這個工具很有幫助。
- 需要 **Xcode Command Line Tools**(裡面有 Swift 編譯器)。除此之外什麼都不用裝 —— 不用 Homebrew、不用 ffmpeg、沒有任何套件。

## 為什麼做這個

市面上抽影格的工具大多要你先裝 ffmpeg,而裝 ffmpeg 通常又要先裝套件管理器。對一個只是想從錄影裡拿到幾張截圖的設計師來說,這是一整套不成比例的工程。

它是兩支小程式,直接呼叫 macOS 本來就有的框架。編譯一次就能用,不要了直接刪掉資料夾,系統上不會留下任何東西。

## 安裝

```bash
# 1. 確認 Swift 編譯器可用（Xcode Command Line Tools 內建）
swiftc --version
#    如果失敗，執行：xcode-select --install

# 2. 下載並編譯
git clone https://github.com/kh4078/video-to-screenshots-tool.git
cd video-to-screenshots-tool
swiftc frames.swift  -o frames
swiftc montage.swift -o montage
```

編譯時會出現兩則警告,不影響執行,說明見「[已知限制](#已知限制)」。

## 用法

### `frames` —— 從影片抽出畫面

```bash
# 等間隔：每 N 秒抽一張
./frames <影片> <輸出夾> <間隔秒> <最大寬度>
./frames rec.mp4 ./overview 15 480

# 指定秒數：間隔填 0，後面列出要的秒數
./frames <影片> <輸出夾> 0 <最大寬度> <秒> <秒> ...
./frames rec.mp4 ./final 0 1206 78 135 190
```

輸出檔名是 `t<秒數>.jpg`(例如 `t0078.0.jpg`)。

加上 `FRAMES_FORMAT=png` 會輸出無損 PNG —— **精抽階段請務必用這個**,因為 JPEG 壓縮會在介面文字邊緣產生明顯雜訊:

```bash
FRAMES_FORMAT=png ./frames rec.mp4 ./final 0 1206 78 135 190
```

### `montage` —— 把截圖拼成總覽表

```bash
./montage <輸入夾> <輸出.jpg> <欄數> <每格寬>
./montage ./overview ./sheet.jpg 9 200
```

每一格底下會標上時間(`1:18 (78s)`),所以你看完表就知道要抽第幾秒。

> 兩支工具是配套的:`montage` 只讀 `.jpg`,而且靠 `frames` 的檔名去解析時間。改動其中一邊的輸出格式,另一邊要一起改。

## 標準流程

**第 2 步才是這個工具的重點。**

```bash
# 1 · 粗掃：每 15 秒抽一張小圖
./frames "錄影.mp4" ./01_粗掃 15 480

# 2 · 總覽表：看這張圖，挑出你要的秒數
./montage ./01_粗掃 ./總覽表.jpg 9 200

# 3 · 精抽：指定那幾秒，全解析度、無損
FRAMES_FORMAT=png ./frames "錄影.mp4" ./02_精選 0 1206 78 135 190

# 4 · 拿去你要用的地方（Figma、文件、簡報）
```

一支 12 分鐘的錄影有兩萬多個影格。第 2 步把它變成一張你幾秒鐘就能掃過的圖。**判斷由你做**,工具只負責讓你判斷得快。

錄影時做到這幾點,結果會差很多:

- **一個區塊錄一支影片**,檔名寫清楚涵蓋什麼(`首頁.mp4`、`結帳.mp4`)—— 不要一支長影片來回跳
- **每個畫面停留 1～2 秒**,才不會抽到轉場動畫的殘影
- 進到子頁後**退回上一層再進下一個**,路徑才清楚
- 如果頁面會捲動,**一定要捲到最底** —— 沒出現在畫面上的內容事後救不回來

## 搭配 AI 助理使用

很多人會這樣用:工具負責粗掃,AI 讀總覽表提出時間點,你確認。這個組合很有效,但 AI 會從很短的描述推論很多事,而且會推錯。

**先把這四件事講清楚**,可以省掉大部分的重做:

| 要先講的 | 為什麼重要 |
|---|---|
| **每頁要完整捲動,還是一頁一張代表畫面?** | 「IA 盤點」兩種都說得通,這是最常見的重做原因 |
| **狀態要不要收?**(空狀態、載入中、錯誤、彈窗) | 不講的話只會拿到順利路徑 |
| **同一頁的不同變體要分開嗎?**(外送/外帶、不同地區) | 這些會改變資訊架構,不只是內容不同 |
| **系統層的畫面要嗎?**(分享面板、控制中心) | 通常不要,但要講 |

另外一個實務建議:**總覽表每格至少要 400px 寬。** 240px 讀不出頁面標題,而頁面標題是分辨畫面最可靠的依據。

## 範圍

**✅ 會接受的方向**

- 抽格精準度、輸出格式與品質
- 總覽表的可讀性 —— 欄數、標籤、排版
- 支援更多影片來源(Android 錄影、QuickTime、OBS…)
- 命名規則、批次處理多支影片
- 更清楚的錯誤訊息

**❌ 不接受的方向**

- **跨平台(Windows / Linux)。** 直接用 macOS 內建框架,才能做到「不用安裝任何東西」。移植就得引入相依套件,那就失去意義了。
- **任何外部相依套件。** 不用套件、不用 ffmpeg。這是這個工具相對於其他選擇**唯一真正的優勢**。
- **影片剪輯、轉檔、壓縮。** 那是 ffmpeg 的守備範圍,而且它做得比較好。
- **圖形介面。**
- **自動判斷哪一格重要。** 挑選需要知道你的目標,而目標只有你知道。工具的職責是讓**你的**判斷變快,不是取代它。

最後一條是原則,不是能力不足。自動挑選會**隱藏它跳過了什麼**,而且你沒辦法跟它說「不對,要 60 秒不是 58 秒」。

## 已知限制

1. **兩則編譯警告**(`asset.duration`、`copyCGImage` 是舊版寫法)。不影響執行;要消掉得改用非同步的 API。
2. **抽格容差是 0.3 秒**,為了速度。如果需要精準對到某一格,把 `frames.swift` 裡的 `requestedTimeToleranceBefore/After` 改成 `.zero`,代價是變慢。
3. **只在 iPhone 螢幕錄影上測過。** 其他來源的回報很歡迎。
4. `montage` 假設資料夾裡所有圖片的長寬比和第一張相同。

## 想幫忙改進

歡迎回報問題或提出想法 —— 請看 [CONTRIBUTING.md](CONTRIBUTING.md)。

**如果你想直接改程式碼,請先開一個 Issue 討論方向**,免得你花了時間卻做了不會被合併的東西。

## 授權

MIT —— 見 [LICENSE](LICENSE)。
