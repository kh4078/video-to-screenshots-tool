# Video to Screenshots Tool

**把螢幕錄影變成一組看得懂的截圖 —— 給人判讀,不是讓機器替你決定。**

用手機錄下 App 的操作過程,這個工具會幫你把整支影片變成一張「總覽表」,讓你一眼挑出需要的畫面,再把那幾個時間點以全解析度抽出來。

適合:產品走查、資訊架構(IA)盤點、既有系統畫面備存、競品分析。

> English version below → [Jump to English](#english)

---

## 📋 錄影前,請先看這幾點

這段最直接影響最後截圖好不好用,不管你是自己錄影、還是 AI 助理在協助別人,都請先看過:漏看這幾點,是重錄影片最常見的原因:

- **一個區塊錄一支影片**,檔名寫清楚涵蓋什麼(`首頁.mp4`、`結帳.mp4`)—— 不要一支長影片來回跳
- **每個畫面停留 1～2 秒**,才不會抽到轉場動畫的殘影
- 進到子頁後**退回上一層再進下一個**,路徑才清楚
- 如果頁面會捲動,**一定要捲到最底** —— 沒出現在畫面上的內容事後救不回來

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

(錄影重點放在文件最前面 ——「[錄影前,請先看這幾點](#錄影前請先看這幾點)」。)

## 搭配 AI 助理使用

很多人會這樣用:工具負責粗掃,AI 讀總覽表提出時間點,你確認。這個組合很有效,但 AI 會從很短的描述推論很多事,而且會推錯。

**先把這五件事講清楚**,可以省掉大部分的重做:

| 要先講的 | 為什麼重要 |
|---|---|
| **每頁要完整捲動,還是一頁一張代表畫面?** | 「IA 盤點」兩種都說得通,這是最常見的重做原因 |
| **狀態要不要收?**(空狀態、載入中、錯誤、彈窗) | 不講的話只會拿到順利路徑 |
| **同一頁的不同變體要分開嗎?**(外送/外帶、不同地區) | 這些會改變資訊架構,不只是內容不同 |
| **系統層的畫面要嗎?**(分享面板、控制中心) | 通常不要,但要講 |
| **最終要放到 Figma,還是只要檔案就好?** | 二選一即可。選 Figma,AI 助理會直接幫你放進去;選檔案,AI 助理存好最終截圖就結束 —— 之後要放到 Notion、簡報或其他任何地方,交給你當下在用的 AI 助理臨場討論就好,不是這個工具該預先定義的事。 |

另外一個實務建議:**總覽表每格至少要 400px 寬。** 240px 讀不出頁面標題,而頁面標題是分辨畫面最可靠的依據。

### 精抽全解析度之前,一定要先把總覽表打開給使用者看

第 2 步(粗掃+總覽表)做完、第 3 步(全解析度精抽)開始之前,AI 助理要停下來,**實際把總覽表圖片打開給使用者看** —— 就算前面五個問題的答案已經完全決定要抽哪些時間點(例如答案是「完整捲動全收」,理論上已經沒有東西要挑了),這一步還是不能省。因為這一步的重點不是挑時間點,而是使用者**唯一能在花時間精抽一堆全解析度圖之前,抓出這支影片本身有沒有問題**(漏拍某個畫面、捲動中途被剪掉、跳拍)的機會。

**只用文字列出打算抽的時間點,不算做到這一步。** 一串數字沒辦法讓使用者判斷任何事 —— 從 `[9, 12, 15, 18, ...]` 這種清單,他們看不出畫面對不對、捲動有沒有捲完、影片有沒有錄壞。只有實際看到圖片本人才判斷得出來。AI 助理要把總覽表本身打開/顯示出來,等使用者確認(或指出問題)之後,才能進行第 3 步。

### 檔名怎麼命名 —— 不管目的地是什麼,本地資料夾一律要改

**不要**直接沿用 `t<秒數>` 當最終截圖的檔名。這一步是**不管最終要放哪裡都要做**的 —— 不管最後目的地是 Figma 還是純檔案,本地資料夾都要經過同一套處理:

- **實際看過每張畫面的內容,依畫面意圖命名** —— 標出頁面/區塊與所處狀態,例如「選擇城市-捷運站列表」,而不是「t0042.0」。
- **同一個頁面/區塊、只是捲動位置不同的畫面,要標成一組對照序列**,依捲動順序命名為 `..._1of3`、`..._2of3`、`..._3of3`,讓人一眼就看得出這些畫面彼此相關、順序為何,而不是看起來像互不相干的畫面。
- 對照順序已經由序列標記(`_NofM`)承擔,**不需要**再把秒數留在最終名稱裡。
- **直接在第 3 步(精抽)已經產生的那個資料夾裡原地改名**(例如 `02_精選`)——**不要**另外開一個資料夾放改名後的複本。那個資料夾本來就只放最終挑出來的截圖,沒有其他東西需要靠保留原檔名來保護,另外複製一份只會讓容量變兩倍,沒有任何好處。`01_粗掃`(低解析度的粗掃資料夾)是獨立的、用完即可丟的工作資料夾 —— 裡面的 `t<秒數>` 檔名不用管,第 3 步做完之後這個資料夾也可以直接刪掉。

這件事不管目的地是什麼都要做,兩種目的地只差在**接下來**:

- **檔案**:不用再做什麼,第 3 步改完名的那個資料夾就是最終產出物。
- **Figma**:放進 Figma 時,**用剛剛套在本地檔案上的同一個名字** —— 圖層名稱、下方的文字標籤都用這個名字,不要讓兩邊的命名分岔。真正花時間的是想出這個語意化名稱(要看過每張畫面才能決定),之後拿同一個名字去改本地檔名,只是單純的改名動作,不是重做一次判讀,所以沒有理由讓 Figma 跟本地資料夾對不起來。

**如果目的地是 Figma**,還要多做一件事:在每張圖片下方加一個小文字,內容就是那張圖的圖層名稱。這樣掃過整個畫布時,不用一張一張點開圖層面板,一眼就能認出畫面是什麼。

### 放進 Figma 時的排版間距

這件事值得一次做對 —— 版面在結構上正確,不代表看起來舒服,而且通常要等畫面塞滿圖片之後才會發現不對勁。

- **每張圖片跟自己的文字標籤,包成一組小的直向 auto-layout**,兩者間距抓緊一點(6–8px)——就是這個「緊」,才會讓人一眼看出「這個標籤是在講上面這張圖」。
- **這些「圖片+標籤」的組合,排進會自動換行的網格**(wrap grid),整體才會像一張可以掃視的總覽板,而不是一路往下捲的長條。
- **列與列之間的間距,一定要明顯大於圖片與自己標籤的間距 —— 至少 3–4 倍**(例如圖片與標籤間距 6–8px 時,列間距抓 60–80px)。間距太接近的話,標籤跟下一列圖片的距離會跟跟自己上面那張圖差不多近,分不出這個標籤是在講哪一張。
- 欄與欄之間(左右)留 20px 左右就夠,因為圖片本身的邊界已經有分隔效果。
- **最外層、對應每一段影片的容器,四周要留真正的內邊距**(例如 40px)——內容貼著容器邊界看起來會很擠。
- **如果同一頁放了好幾段影片的內容**,容器與容器之間要留明顯的間距(100px 以上),而且只要調整過上面任何一個間距數值,就要重新檢查有沒有重疊 —— 列間距或內邊距變大,會讓「自動撐開高度」的容器變高,可能因此擠到下面的東西。

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

---

<a name="english"></a>

# Video to Screenshots Tool (English)

**Turn a screen recording into a set of readable screenshots — for people to review, not for machines to decide.**

Record a walkthrough of an app on your phone, and this tool gives you a contact sheet of the whole session so you can pick the frames that matter, then pull those exact moments at full resolution.

Built for product walkthroughs, IA audits, UI archiving, and competitor research.

## 📋 Before you record — read this first

This is the part that most affects how usable your captures turn out — read it whether you're the one recording or the assistant helping someone through this. Skipping these is the single biggest cause of having to redo a recording:

- **One recording per section**, named for what it covers (`home.mp4`, `checkout.mp4`) — not one long recording that jumps around
- **Pause 1–2 seconds on each screen** so you capture the screen, not a transition blur
- **Back out to the previous level** before going into the next branch, so the path stays legible
- If a page scrolls, **scroll it all the way to the bottom** — you can't recover content that was never on screen

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

(Recording tips are at the top of this doc — [Before you record](#before-you-record--read-this-first).)

## Using it with an AI assistant

Many people will use this alongside Claude, Cursor, or similar: the tool sweeps, the assistant reads the contact sheet and proposes timestamps, you approve. That works well, but the assistant will infer a lot from a short brief, and it can infer wrong.

Say these five things up front and you'll avoid most rework:

| Tell it | Why it matters |
|---|---|
| **Full scroll of every page, or one representative frame each?** | "IA audit" can mean either. This is the single biggest source of redo. |
| **Do you want states?** (empty, loading, error, modals) | Otherwise you get only the happy path. |
| **Split variants of the same page?** (delivery vs. pickup, different regions) | These change the information architecture, not just the content. |
| **Include OS-level UI?** (share sheets, control center) | Usually no — but say so. |
| **Final destination: Figma, or just files?** | A binary choice. If Figma, the assistant places them there directly. If files, it saves the final captures and stops — where they go from there (Notion, a slide deck, wherever) is between you and whatever assistant you're using at that moment. |

Also worth knowing: **read contact sheets at 400px per tile or wider.** At 240px you can't read page titles, and page titles are the most reliable way to tell one screen from another.

### Show the contact sheet before running the full-resolution capture — always

Between step 2 (sweep + contact sheet) and step 3 (full-res capture), the assistant should stop and actually show the contact sheet image — even when the five answers above already fully determine which timestamps to capture (e.g. "full scroll coverage" means there's technically nothing left to pick). This isn't about picking timestamps; it's the user's only chance to catch a bad recording — a missed screen, a scroll cut short, a jump — before the assistant spends time on the expensive lossless full-res pass.

**Listing the intended timestamps in text doesn't satisfy this.** A list of numbers gives the user nothing to judge a screen by — they can't tell if it looks right, if a scroll is complete, or if the recording glitched, from `[9, 12, 15, 18, ...]`. Only looking at the actual image does that. The assistant should open/display the contact sheet itself and wait for confirmation (or for the user to flag a problem) before running step 3.

### Naming captures — always rename the local folder, regardless of destination

Never leave final captures named by their `t<seconds>` timestamp. This happens **unconditionally, before you even know where they're going** — the local folder gets the same treatment whether the destination turns out to be Figma or plain files:

- **Name each capture after what it actually shows** — the page/section and its state — based on actually looking at the image, e.g. `Choose city - subway station list`, not `t0042.0`.
- **If several captures are the same page/section at different scroll positions, mark them as a sequence** in scroll order — `..._1of3`, `..._2of3`, `..._3of3` — so the relationship is visible instead of looking like unrelated screens.
- The sequence label carries the ordering information — there's no need to also keep the seconds in the final name.
- **Rename in place inside the same folder the final-capture step already wrote to** (step 3's output, e.g. `02_picked`) — don't create a second folder for renamed copies. That folder only ever holds the hand-picked final captures, so there's nothing to protect by keeping the originals, and a second copy just doubles disk usage for no benefit. `01_sweep` (the low-res sweep) is a separate, disposable working folder — fine to leave its `t<seconds>` names as-is, or delete it once step 3 is done.

Do this regardless of destination — the two only diverge on what happens *next*:

- **Files**: nothing further; the renamed folder from step 3 is the deliverable.
- **Figma**: place the images there using **the same names** just given to the local files — same layer name, same caption text (below). The semantic name was already worked out once (that's the part that costs real time — it requires reading each image); reusing it for the local files afterward is a cheap rename, not a redo, so there's no reason for the two to drift apart.

**When the destination is Figma specifically**, add one more thing: a small text caption directly below each image, showing that same layer name. That way you can identify a screen at a glance while scanning the canvas, without opening the layers panel for every tile.

### Layout spacing when placing into Figma

Worth getting right the first time — a board can be technically correct and still be uncomfortable to scan, and you tend to only notice once it's full of images.

- **Group each image with its own caption** in a small vertical auto-layout, tight spacing between the two (6–8px) — that tightness is what reads as "this caption belongs to the image right above it."
- **Arrange the groups in a wrapping grid** so the set reads as a scannable board, not one long vertical scroll.
- **Row gap must be clearly bigger than the image-caption gap — at least 3–4x it** (e.g. 60–80px of row gap against a 6–8px image-caption gap). Too close, and a caption sits about as near the row below as its own image above — not obvious which image it labels.
- Column gap of ~20px is enough; neighbors are already separated by the image edges.
- **Give the outermost per-video-segment container real padding** on all sides (e.g. 40px) — content flush against the frame edge reads as cramped.
- **When multiple segments land on the same page**, stack them with a clear gap (100px+) and re-check for overlap after touching any spacing value above — growing the row gap or padding grows a hugging container's height, which can push it into whatever's below it.

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
