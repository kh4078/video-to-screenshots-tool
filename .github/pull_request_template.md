<!--
Please open an issue and get a reply before writing code.
請先開 Issue 並取得回覆，再開始寫程式碼。
-->

Related issue / 相關 Issue: #

## What does this change do? / 這個修改做了什麼？

<!--
In plain language, not just code. The maintainer is a designer, not a professional
developer — if it can't be followed in prose, it can't be merged.

請用白話說明，不要只有程式碼。維護者是設計師而不是專業工程師，
文字上讀不懂的修改沒辦法合併。
-->

## How did you test it? / 你怎麼測試的？

- macOS version / 版本:
- Chip / 晶片: Apple Silicon / Intel
- Recording used / 用什麼影片測: <!-- source, duration, resolution, extension -->
- Command run / 執行的指令:

```
```

<!-- Did you open the output images and look at them? Exit code 0 isn't proof. -->
<!-- 你有實際打開輸出的圖片看過嗎？結束碼 0 不等於結果正確。 -->

## Checklist / 確認事項

- [ ] Stays within [Scope](../README.md#scope) / 在專案範圍內
- [ ] **Adds no external dependencies** / 沒有增加任何外部相依套件
- [ ] Single concern — one PR, one thing / 一個 PR 只做一件事
- [ ] Recompiled and ran both tools after the change / 改完有重新編譯並實際跑過兩支工具
- [ ] Readable by someone who isn't a Swift specialist / 不是 Swift 專家也讀得懂

## Does it change existing behaviour? / 會不會改變既有行為？

- [ ] No / 不會
- [ ] Yes — argument order, output filenames, or output format changes
      / 會 —— 參數順序、輸出檔名或輸出格式有變動

<!--
If yes, describe it here. People have scripts built on the current syntax, and
`frames` and `montage` are a matched pair — changing one side's output format
requires changing the other in the same PR.

如果會，請在這裡說明。有人已經寫了腳本在用現在的語法，
而且 frames 和 montage 是配套的 —— 改動一邊的輸出格式，另一邊要在同一個 PR 裡一起改。
-->
