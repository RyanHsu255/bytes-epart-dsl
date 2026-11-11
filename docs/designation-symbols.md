# IEC／EPLAN 標識符號與 DSL 語法

查證日期為 2026-11-10。本表供設計 DSL 語法、標識輸入與圖面匯出時查閱。現行 DSL 寫法以[語法規格](specification.md)為準。

## 符號速查

| 符號 | 在標識中的用法 | 來源 |
| --- | --- | --- |
| `:` | 分隔物件的參照代號與端子代號。EPLAN 以 `-X1:1` 表示接頭 `-X1` 的第 1 腳。IEC 61175-1 的訊號標識也用冒號引出選填的訊號連接識別碼。 | [IEC 61666 合併版](https://webstore.iec.ch/en/publication/69168)、[ISO/TS 81346-3:2012 §6.4.2 表 3 註 a](https://standards.iteh.ai/catalog/standards/iso/a6cad221-c7ba-4a33-90e4-0d24d8bb3b56/iso-ts-81346-3-2012)（歷史交叉引用，[ISO 已撤銷該技術規範](https://www.iso.org/standard/59598.html)）、[EPLAN 接頭管理](https://www.eplan.help/en-us/infoportal/content/plattform/2023/content/htm/plugsgui_k_verwaltungstecker.htm)、[IEC 61175-1:2015 圖 7](https://standards.iteh.ai/catalog/standards/clc/9d72bbef-6ae0-4f1b-a5ab-6087055ab386/en-61175-1-2015) |
| `=`、`+`、`-` | EPLAN 在依 EN 81346 組織的參照代號中，分別用作功能、位置及產品面向的前綴。 | [EPLAN 專案結構](https://www.eplan.help/en-US/Infoportal/Content/Plattform/2027/Content/htm/projectstructure_k_referenzkennzeichnung.htm) |
| `%`、`#` | 在製造與加工系統的 IEC 81346-14 中，分別用於類型面向及其他面向。EPLAN 也可能依專案設定將 `#` 用於功能指派或自訂標識區塊。 | [IEC 81346-14:2026 §6.2.1 預覽](https://standards.iteh.ai/catalog/standards/clc/3e7a34b2-e875-431c-b0ee-00f4c5fa95ff/en-iec-81346-14-2026)、[EPLAN 自訂專案結構](https://www.eplan.help/en-us/Infoportal/Content/Plattform/2022/Content/htm/projectstructure_h_frhierarchienerstellen.htm) |
| `;` | 在 IEC 61175-1 的訊號標識中，用作訊號名稱的前綴。 | [IEC 61175-1:2015 §5.1.3](https://standards.iteh.ai/catalog/standards/clc/9d72bbef-6ae0-4f1b-a5ab-6087055ab386/en-61175-1-2015) |
| `==`、`++`、`&`、`/` | 在 EPLAN 的標識格式中，`==` 可用於功能指派，`++` 用於安裝地點，`&` 可用於文件類型，`/` 可用來引出頁名。 | [EPLAN 自訂專案結構](https://www.eplan.help/en-us/Infoportal/Content/Plattform/2022/Content/htm/projectstructure_h_frhierarchienerstellen.htm) |

## DSL 設計原則

- 新增或修改 DSL 標點前，先核對符號在 IEC 與 EPLAN 的用途。尤其檢查元件、接頭、端子、訊號及頁面標識能否與新語法一起使用，也要考慮 CSV 貼上和圖面匯出。
- 優先選擇清楚的關鍵字或已有明確欄位邊界的寫法，例如用 CSV 的 `X00,急停` 對應位址與用途。若沿用同一符號有實際好處，限縮在明確的指令或欄位內，記下取捨，並驗證輸入與匯出能保留原始標識。
- DSL 以 `BY` 引出步長，例如 `LABEL X7..X1 BY 2`。舊檔仍可用 `:2`，解析範圍時才有步長語意。`SPLIT` 和 `LABEL_ROWS` 使用 `/` 分組，`PINS 1=L` 使用 `=` 指派標籤，`SET` 中的 `+ BOARD` 代表疊裝，`#` 可開始註解。評估新語法時，把這些用法和標識的語意一起檢查。
