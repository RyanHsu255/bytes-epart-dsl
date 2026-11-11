# 專案貢獻指南

這是供專案擁有者閱讀的繁體中文譯本。協作代理平時只需讀英文版 [AGENTS.md](AGENTS.md)。每次更新英文版，都要在同一次變更中同步更新這份譯本。

## 專案結構

Bytes EPART DSL 是可直接在瀏覽器執行的編輯器，用於繪製具實際尺寸比例的工業電氣元件簡圖。

本工具的一項目標是讓使用者能用文字快速為原廠未提供 `.dwg` 或 `.dxf` 圖檔的小眾品牌電氣元件建立 `.dxf` 工程簡圖。DXF 匯出支援單一 PART 視圖。

- `index.html` 是預覽器入口，包含介面、CSS、DSL 解析器、SVG 繪圖程式和內建範例。處理順序為 `parse()` → `pinList()` 與幾何輔助函式 → `draw()`。
- `docs/specification.md` 是現行語法規格的來源。變更語法時，同步更新 `docs/specification.html` 和預覽器的語法快速參考。版本沿革記錄在 `CHANGELOG.md`。

- `refs/` 存放範例參考的原始 CAD 圖檔，預覽器執行時不會讀取這些檔案。

## 本機開發與測試

在 PowerShell 執行 `Invoke-Item .\index.html` 即可開啟編輯器。專案無須建置或安裝套件，目前也沒有設定程式碼檢查工具或自動化測試套件。若已安裝 Node.js，可從專案根目錄檢查內嵌 JavaScript 的語法。

```powershell
$previewHtml = Get-Content -Raw -Encoding utf8 .\index.html
if ($previewHtml -match '(?s)<script>(.*?)</script>') {
    $Matches[1] | node --check
}
```

載入各個內建範例，逐一切換可用的視圖，確認圖面正常顯示且沒有錯誤或警告。修改解析器時，各測一段合法語法和一段錯誤語法，確認後者顯示正確的行號及訊息。修改繪圖或匯出功能時，檢查受影響的視圖，並確認匯出 SVG 的毫米寬高與 `viewBox` 的寬高相符。

## 程式與幾何慣例

提出或修改 DSL 標點前，先讀 [IEC／EPLAN 標識符號](docs/designation-symbols.md)。盡量避免可能混淆的用法。有理由沿用同一符號時，將用法限於明確的指令或欄位，並記下取捨。

讓修改聚焦於需求，縮排沿用周圍程式的風格。JavaScript 識別字使用 camelCase，範例的 DSL 關鍵字使用大寫。優先沿用現有的解析與幾何輔助函式。將使用者輸入的文字插入 SVG 或 HTML 前，先處理特殊字元的跳脫。

以 BODY 中心為原點、毫米為繪圖單位，旋轉角度正值代表逆時針。範例只呈現有工程用途的結構，並清楚區分產品實測資料和示意資料。

## Commit 與 Pull Request

使用本機 Git 與公開的 [GitHub 儲存庫](https://github.com/RyanHsu255/bytes-epart-dsl)。使用者要求跑 Git 時，提交已驗證且可公開的變更並推送到 GitHub。Commit 標題用簡短的祈使句。雙擊 `Publish-GitHub.bat` 會啟動 `Publish-GitHub.ps1`，透過獨立工作副本提交與推送。同步維護腳本的公開檔案清單。`refs/` 的原始 CAD、憑證、記錄檔及產生的暫存目錄都留在公開儲存庫之外。

僅在使用者明確要求發布特定版本時建立 GitHub Release。送出 Pull Request 時，說明行為變更、列出執行的檢查，並附上相關 issue 連結。有可見變更時，附上修改前後的截圖。

## Firebase Hosting

雙擊 `Deploy-Firebase.bat` 會啟動 `Deploy-Firebase.ps1` 並更新 [tools.bytes.tw](https://tools.bytes.tw/)。腳本會整理編輯器與 HTML 規格頁，再部署到 `bytes-epart-tools` Hosting 站點。
