# Bytes EPART DSL v0.4 規格書

草案更新於 2026-11-10。

Bytes EPART DSL 用於繪製工業電氣元件的 2D 工程簡圖。圖面以毫米表達元件外形、電氣接點、安裝結構與識別資訊。內建接頭是工程示意模板。產品的尺寸、腳位與安裝資料應以經核實的資料為準。

本工具的一項目標是讓使用者能用文字快速為原廠未提供 `.dwg` 或 `.dxf` 圖檔的小眾品牌電氣元件建立 `.dxf` 工程簡圖。預覽器可匯出單一 PART 視圖的 DXF。

## 通用語法與註解

每行一個指令。指令、模板及列舉值不分大小寫。標籤及顯示文字保留原始大小寫。子指令跟在所屬宣告後，縮排可省略。`[]` 表示可選項，`|` 表示選項擇一。

行首 `#` 或 `//` 開始註解。單引號或雙引號之外的 `#` 也可以開始行尾註解，引號內的 `#` 是文字的一部分。

```text
CN -CN1 TB3 AT .5,+5 FUNCTION "Power #1"
  LABEL L,PE,N  # 依 Pin 編號排列
  LABEL_POS K2  # 接點下方
```

`@` 可替代定位指令中的 `AT`。例如 `AT .5,+5`、`@ .5,+5` 和 `@.5,+5` 等效。此規則適用於所有使用 `AT` 的指令。

`BODY`、`AT`、`SIZE` 的寬高和 `MARGIN` 可用空格或逗號分隔數值。逗號兩側可留空格，同一組也可混用兩種分隔方式。例如 `BODY 130 90 83`、`BODY 130,90,83` 和 `BODY 130, 90 83` 等效。`AT .5,+5` 與 `AT .5 +5` 也等效。

指令有誤時，編輯器顯示行號。點擊帶行號的診斷可選取編輯器中的對應行。修正錯誤後即可匯出。重複 ID、找不到表格目標和標籤數量不符會顯示警告，仍可預覽及匯出。

## PART、BODY、VIEW

- `PART name` 指定元件名稱。預設為 `UNTITLED`。可合寫為 `PART MY_IO BODY 30 90 80`，尺寸規則與獨立的 BODY 指令相同。同一份文件可宣告多個 PART。各零件以自己的本體中心 (0,0) 定位，可在視圖選單分別預覽和匯出，也可使用相同的接頭 ID。
- `BODY W H [D] [HIDE]` 指定寬、高、深，各尺寸必須大於 0。省略 `D` 時為 50 mm。省略整行時使用 100 × 100 × 50 mm。`HIDE` 保留本體尺寸供定位，在預覽與匯出隱藏本體外框。50 Pin 焊接表範例用它單獨繪製接頭。
- `VIEW FRONT|BACK|LEFT|RIGHT|TOP|BOTTOM` 切換視圖，預設為 `FRONT`。各視圖獨立定義，不會自動投影接頭或安裝結構。

BODY 中心固定在 `(0,0,0)`，是 DXF 的插入基準。每個視圖以 BODY 中心為 `(0,0)`，X 向右、Y 向上，`ROT` 正值為逆時針。FRONT／BACK 使用 W × H，LEFT／RIGHT 使用 D × H，TOP／BOTTOM 使用 W × D。

### PLACE 共同圖面

`PLACE name @x,y` 指定零件本體中心在共同圖面上的位置，單位為 mm，X 向右、Y 向上。PLACE 是獨立指令，可寫在 PART 前後。工具在所有零件都有 PLACE 時提供共同圖面，各零件依當前視圖繪製，SVG 採用相同位置。缺少座標時會提示零件名稱，各零件仍可獨立出圖。SET 文件使用組裝規則定位。

```text
PART A BODY 30 20 10
PART B BODY 50 20 12
PLACE A @0,0
PLACE B @80,10
```

## CN

```text
CN [-id] TYPE [STYLE P|S|PLUG|SOCKET] [(AT | @) (x,y | K1…K9)] [ROT degrees] [ORDER mode] [START corner] [SHAPE ROUND|SQUARE] [PIN1 DOUBLE|SOLID|NONE] [PINEND AUTO|ARC|NONE] [FUNCTION text]
```

省略 ID 時，每個視圖依宣告順序自動分配 `-CN1`、`-CN2` 等，略過同一視圖所有明確指定的 ID，查重時不分大小寫。明確指定的 ID 以 `-` 開頭，後接至少一個字元。可用自訂名稱，例如 `-X1`、`-CN1`、`-電源輸入` 或 `-motor.out`。ID 不含空白、引號或註解符號 `#`。若圖面上的顯示名稱需要空格，可另用 `NAME "Motor output"`。舊寫法 `CN CN1 IDC20 AT x,y` 須改成 `CN -CN1 IDC20 AT x,y`。同一視圖的 ID 應唯一，重複時會警告，`TABLE id` 採用第一筆。不同視圖可以使用同一 ID。

`AT` 通常定位到接頭中心。錯列接頭以未錯列的針腳格中心定位，外框中心可因 `STAGGER` 與 `MARGIN` 偏移。RJ45 採模板原點。`ROT` 預設為 0，接頭輪廓和接點一起旋轉。標籤一般隨接頭旋轉，`LABEL_POS OUTSIDE` 的文字保持水平。

`STYLE P` 或 `STYLE PLUG` 指定公頭，`STYLE S` 或 `STYLE SOCKET` 指定母座。`CN -RJ RJ45 STYLE P` 在原點繪製 RJ45 公頭。`STYLE` 可寫在位置前後，也可獨立寫在子行。舊檔的 `SUBTYPE` 可繼續讀取，型別後單獨的 `P`、`S`、`PLUG` 或 `SOCKET` 須補上 `STYLE`。

省略位置時使用原點。一般模板預設 `SOCKET`。`MDR50M_SOLDER` 及其別名固定為 `PLUG`。D-sub 依公母選擇預設首腳方向，其他模板沿用各自的腳位排列。

### AT 九宮格定位

在 `CN` 宣告中，可用 `AT K1` 至 `AT K9` 快速定位接頭。位置以當前 `VIEW` 的 BODY 正投影為準。

| 左側 | 中央 | 右側 |
| --- | --- | --- |
| K7 左上 | K8 上方置中 | K9 右上 |
| K4 左方置中 | K5 正中央 | K6 右方置中 |
| K1 左下 | K2 下方置中 | K3 右下 |

外側位置讓接頭外框沿指定方向對齊 BODY 邊緣，靠內放置，預設留距為 0 mm。中央方向讓接頭外框在該軸置中。計算會套用接頭的幾何設定與 `ROT`，以旋轉後的外框包絡定位。標籤與名稱不參與計算。外框比該視圖的 BODY 大時，預覽器會顯示警告。

`AT K8` 決定整個接頭在視圖中的位置，`START` 決定 Pin 1，`LABEL_POS` 決定接點文字方向。需要指定座標或自行預留距離時，可用 `AT x,y`。

```text
PART STEPPER_DRV BODY 118 75 34
CN TB6 @K8
CN TB6 @K2
```

### 模板

| 模板 | 排列 | 預設 Pin 中心距 |
| --- | --- | --- |
| IDC 加偶數總腳數，如 IDC32 | 雙排，IDC32 為 2 × 16 | 2.54 mm |
| DE9、DB9 | 上排 5、下排 4，圓角 D-sub | 水平 2.77 mm、排距 2.84 mm |
| DB25、DSUB25 | 上排 13、下排 12，圓角 D-sub 示意 | 水平 2.77 mm、排距 2.84 mm |
| MDR20、MDR26、SCSI26、MDR50 | 2 × 10／13／13／25，簡化 MDR | 1.27 mm |
| G57-24 | 2 × 12，通用示意 | 2.54 mm |
| G50 | 2 × 25，通用示意 | 2.54 mm |
| MDR50M_SOLDER | MDR 50 Pin 外框與四列交錯焊接腳位 | 2.54 mm（同列） |
| TB2、TB3、TB4、TB6、TB8 | 1 × 2／3／4／6／8 | 7.5 mm |
| TB4_2X2 | 2 × 2 | 4.2 mm |
| TB6_2X3 | 2 × 3 | 7.62 mm |
| TB8_2X4 | 2 × 4 | 3.5 mm |
| TB26、TB28 | 2 × 13／14 | 4.38／4.18 mm |
| RJ45 | 8 個沿長直邊排列的矩形接點 | 1.02 mm |
| USB_MINIB | 1 × 5，USB Mini-B 母座，繪製斜肩開口與接點 | 0.8 mm |
| USB_MICROB | 1 × 5，Micro USB Type-B 母座，繪製斜角開口與接點 | 0.65 mm |

`IDC` 後接 2～1000 的偶數總腳數，例如 `CN IDC32` 或 `CN IDC64`。雙排 IDC 使用通用缺口輪廓，預設水平腳距和垂直排距皆為 2.54 mm，可用 `PITCH` 和 `ROW_PITCH` 調整。

宣告 USB 接頭時，須指定實際的模板型別，例如 `USB_MINIB` 或 `USB_MICROB`。

接頭只畫一圈最容易辨識的輪廓。RJ45 保留卡扣輪廓，DE／DB 保留圓角梯形護罩，MDR 保留有鍵位的護罩，IDC 的缺口畫在同一圈。針腳與 Pin 1 記號各自繪製。

DE9 的護罩與接點依 9 Pin 母頭 DXF 正視圖重畫。預設護罩寬 16.30 mm、高 7.90 mm，圓角半徑 2.54 mm。DB25 以同樣的圓角和排距按腳數加寬，尺寸供示意。 D-sub 9 Pin 母頭 DXF

`USB_MINIB` 的開口取自 `refs/fx5uj-40m_a.dxf` 的正視圖，寬 7.7 mm、高 3.9 mm。九宮格定位以開口輪廓為準。

RJ45 母座外框採用 `RJ45-simple.dxf` 的八段輪廓。`ROT 0` 時卡扣側朝上，接點沿底部水平排列。此方向的局部座標依序為 `(5.9,2.675)`、`(5.9,-4.475)`、`(-5.9,-4.475)`、`(-5.9,2.675)`、`(-3.45,2.675)`、`(-3.45,4.475)`、`(3.45,4.475)`、`(3.45,2.675)`，閉合後以 `(0,0)` 定位。接點採通用 8P8C 示意間距，DXF 來源僅提供外框。RJ45 外框及接點間距固定，接點為無填色矩形。公頭使用帶斜肩卡扣的示意輪廓。`ROT 0` 時，EPART 的公頭與母座皆預設由左至右編為 Pin 1～8。

預覽器的「CN 模板總覽」顯示各模板及別名的腳號，並排展示 RJ45 公頭與母座。IDC 列出部分尺寸作為範例。

### D-sub 殼型與排數

以接合面上的接點排數為準。殼型與接點密度一起決定配置。例如同為 15 腳的 `DA15` 是兩排，`DE15` 是三排。 `DB25P` 表示 25 腳公頭，EPART 寫作 `CN DB25 STYLE P`。總覽並列 `DB25 STYLE P` 與 `DB25 STYLE S`，兩者皆為 13＋12 腳。

| 殼型 | 標準密度 | 高密度 | ITT Cannon 2D 雙密度 |
| --- | --- | --- | --- |
| E | DE9，9 腳，2 排 | DE15（HD15），15 腳，3 排 | 2DE19，19 腳，3 排 |
| A | DA15，15 腳，2 排 | DA26，26 腳，3 排 | 2DA31，31 腳，3 排 |
| B | DB25，25 腳，2 排 | DB44，44 腳，3 排 | 2DB52，52 腳，3 排 |
| C | DC37，37 腳，2 排 | DC62，62 腳，3 排 | 2DC79，79 腳，3 排 |
| D | DD50，50 腳，3 排 | DD78，78 腳，4 排 | 2DD100，100 腳，4 排 |
| 6 號殼 | — | AMPLIMITE 104，104 腳，5 排 | — |

上表供辨識型號。目前 EPART 的 D-sub 繪圖模板為 `DE9`／`DB9` 和 `DB25`／`DSUB25`。 [Amphenol 殼型對照](https://cdn.amphenol-cs.com/media/wysiwyg/files/documentation/customerpresentation/d_sub_productpresentation.pdf#page=3) · [ITT Cannon 2D 接點配置](https://www.mouser.com/datasheet/3/867/1/ITT_Cannon_2D_D_Sub_Series_Brochure.pdf#page=5) · [TE 104 腳接合面圖](https://www.te.com/commerce/DocumentDelivery/DDEController?Action=srchrtrv&DocFormat=pdf&DocLang=English&DocNm=204510&DocType=Customer+Drawing&PartCntxt=204510-1)

### ORDER、START、SHAPE、PIN1

- `START K7|K9|K1|K3` 選擇局部未旋轉座標的左上、右上、左下、右下角。多數模板預設 `K7`，D-sub 母座預設 `K9`。單排接頭只區分左端和右端。
- `ORDER ODD|ROW|COLUMN|REVERSE` 從 `START` 位置開始編號。`ODD` 和 `COLUMN` 逐欄走完各排。`ROW` 逐排且各排方向相同。`REVERSE` 逐排且各排交替方向，形成蛇形。多數模板預設 `ODD`。D-sub 預設 `ROW`，先排上排，再排下排。從接合面看，`PLUG` 預設從左開始，`SOCKET` 預設從右開始。下排置中，相對上排錯開半個 Pin 中心距。可用 `START` 明確指定首腳位置。
- `SHAPE ROUND|SQUARE` 設定接點輪廓，預設 `ROUND`。RJ45 使用模板固定的矩形接點。
- `PIN1 DOUBLE|SOLID|NONE` 設定 Pin 1 樣式。`DOUBLE` 為接頭預設，會加畫一層內框。`SOLID` 為保留的舊語法，在本版預覽仍以單層空心輪廓顯示。`NONE` 不加內框。

這四個選項可寫在 CN 宣告行或子行。`ORDER` 與 `START` 只決定編號與對應標籤，接點的間距與外框尺寸由幾何參數決定。

### PINEND

`CN` 和 `TERMINAL` 預設為 `PINEND AUTO`。圓形末腳內畫半圓，矩形末腳內畫直角折線。前一腳位於水平或垂直方向時，折線有三邊。前一腳位於斜向時，折線用兩邊畫出角落。開口朝向前一腳的實體位置，例如 Pin 20 朝向 Pin 19。標記隨接頭旋轉，也會出現在 DXF。只有一腳，或兩腳位於同一點時，省略標記。

可在宣告行或子行用 `PINEND ARC` 指定半圓，或用 `PINEND NONE` 關閉標記。

### PITCH、ROW_PITCH、STAGGER、MARGIN

- `PITCH n` 改變相鄰接點的水平間距，`ROW_PITCH n` 改變兩排的垂直間距。請使用正值。D-sub 的預設排距為 2.84 mm，其他模板的預設排距等於其預設水平間距。
- `STAGGER n` 將第二排沿局部 X 移動 `n × PITCH`。例如 `STAGGER -0.5` 向左移半個間距。
- `MARGIN x` 或 `MARGIN x,y` 指定外框距最外側接點中心的左右、上下留量，須為正數。只給 `x` 時兩方向使用同值。計算外框時包含 `STAGGER` 後的接點位置。省略時使用模板外框。RJ45 和 USB 模板使用固定輪廓。

### LABEL、LABEL_ROWS、PIN、PINS

- `LABEL L,PE,N,S/S,X0..X7` 按 Pin 1、Pin 2…分配標籤。可用逗號或空白分隔，`X0..X7` 會展開為 `X0` 至 `X7`。也支援反向範圍和步長，例如 `X7..X1 BY 2`。
- `LABEL_ROWS A1..A10 / B1..B10` 按局部未旋轉的實體上排、下排分配，排內由左向右。排與排之間用兩側有空格的 ` / ` 分隔。`S/S` 始終是一個標籤。
- `PIN 1 L "AC line"` 按實體 Pin 編號覆寫標籤與表格功能，說明可用單引號或雙引號。`PINS 1=L 2=PE 3=N` 可一次覆寫多個標籤。格式有誤或腳號超出模板範圍時，整行不套用並顯示行號。
- 缺少的接頭標籤會回退至 Pin 編號，多出的標籤不顯示。數量警告依範圍展開後的結果計算，`LABEL_ROWS` 逐排核對。省略 `LABEL` 時不警告。
- `LABEL NONE` 隱藏圖面接點文字，並讓表格 NAME 欄留白。接點、Pin 1 標記及表格功能仍可顯示。

### LABEL_POS

`LABEL_POS` 選擇文字相對於接點的方向。九宮格和英文方位採用接頭的局部座標。可寫一個方向套用到各排，或以 ` / ` 或逗號分隔各排的方向。

| 左側 | 中央 | 右側 |
| --- | --- | --- |
| K7 或 TOP_LEFT | K8 或 ABOVE | K9 或 TOP_RIGHT |
| K4 或 LEFT | K5 或 CENTER | K6 或 RIGHT |
| K1 或 BOTTOM_LEFT | K2 或 BELOW | K3 或 BOTTOM_RIGHT |

`LABEL_POS K2 / K8` 表示文字放在**實體上排的下方、實體下排的上方**。排順序以未旋轉的接頭為準，與 `START` 選擇的角落無關。`START K1` 仍然從左下角開始編號。

`CN` 可用 `LABEL_POS OUTSIDE`。文字按旋轉後的接點位置分配至外框左側或右側，並保持水平。EXD2060EC 範例用 `TB8_2X4` 描述手冊中的兩排四欄，套用 `ROT 90` 後符合正視圖的安裝方向，Pin 1 位於左下角。

`MDR50M_SOLDER` 的腳號固定在焊點內。指定 `LABEL_POS` 時會顯示警告。

省略方向或指定 `AUTO` 時，端子台上排文字在上方，下排文字在下方。其他一般接頭預設在上方，獨立端子預設在右方。RJ45 和 USB 預設省略接點文字，指定 `LABEL_POS` 才顯示。文字可能因間距和長度而重疊。

### NAME、FUNCTION

- 省略 `NAME` 或寫 `NAME NONE` 時不顯示接頭名稱。`NAME "INPUT" K6` 在接頭右側顯示文字。方位可用 K1～K9 或對應的英文方向，以視圖為準，文字保持水平。`TABLE` 可用明確指定或自動分配的 ID 查詢。
- `FUNCTION "Motor power"` 設定接頭用途。只寫 `NAME "INPUT"` 時，名稱和用途一起顯示在接頭局部下方並隨接頭旋轉。有指定 NAME 方位時，圖面只顯示 NAME 文字。宣告行與子行都接受單引號或雙引號，宣告行上的多詞值須加引號。個別 Pin 的表格功能用 `PIN` 指定。

## TERMINAL

```text
TERMINAL name[,name...] AT x,y [PITCH mm] [ROT degrees] [SIZE mm] [SHAPE ROUND|SQUARE] [PIN1 DOUBLE|SOLID|NONE] [PINEND AUTO|ARC|NONE] [FUNCTION text]
```

獨立端子沒有共用接頭框。`AT` 指第一顆端子中心，後續端子沿局部 +X 按 `PITCH` 排列，再以 `ROT` 旋轉。每個宣告最多 100 顆端子。預設 `PITCH 10`、`SIZE 6`、`SHAPE ROUND`、`ROT 0`、`PIN1 NONE`。

`SIZE` 設定直徑或方形邊長。子行可用 `PITCH`、`SIZE`、`SHAPE`、`PIN1`、`PINEND`、`LABEL`、`LABEL_POS`、`PIN`、`PINS` 和 `FUNCTION`。初始標籤取自宣告的端子名稱。`FUNCTION` 可設定表格中各端子的預設功能，個別 `PIN` 定義優先。

每個視圖依宣告順序自動分配 `T1`、`T2` 等 ID。表格中的 PIN 欄是宣告內的序號。

## LINK（v0.4 草案）

`LINK` 表達模組的機構定位關係，例如並排貼合、正面擴充板與底板插槽。介面外形用於工程圖，定位點供組裝使用。並排模組可用 `LINK LEFT`／`LINK RIGHT` 表達貼齊位置，包含以擴充纜線通訊的模組。若需要單獨描繪纜線接頭，可用 `CN`。

```text
LINK [-ID [BY n]] TYPE @位置 [SIZE w,h] [PITCH p] [ROT deg] [ANCHOR x,y] [NAME "文字"|NONE]
```

- `LINK` 僅可宣告在 `VIEW FRONT`，省略 `VIEW` 時預設就是正視圖。
- `@` 與 `AT` 等價，例如 `@-63,10`、`@ -63 10` 或 `AT -63,10`。`BACK` 可省略位置，預設介面中心為 `(0,0)`。
- `SIZE`、`PITCH`、`ROT`、`ANCHOR`、`NAME` 可寫在宣告行或子行。`SIZE` 與 `ANCHOR` 各需要兩個數值，`PITCH` 與 `ROT` 各需要一個數值。`SIZE` 和 `PITCH` 必須大於零。
- 明確指定的 ID 以 `-` 開頭，下一個字元必須是英文字母。建議沿用實物上的標示，例如 `-POWER`、`-CPU` 或 `-S0`。省略時，依宣告順序自動分配 `LINK1`、`LINK2` 等 ID。同一零件的 LINK ID 不得重複，查重時不分大小寫。

### 類型與預設定位點

| 類型 | 用途 | 對接 | 預設定位點 |
| --- | --- | --- | --- |
| `RIGHT` | 本體右側貼合，向右延伸 | `LEFT` | `(+W/2,y)` |
| `LEFT` | 本體左側貼合，向左延伸 | `RIGHT` | `(-W/2,y)` |
| `FRONT` | 正面可安裝區域，與附加零件疊畫 | `BACK` | 介面中心 |
| `BACK` | 本零件以背面接合，疊畫在主體上 | `FRONT` | 介面中心 |

`W` 為 BODY 寬度，`y` 為介面中心的 Y 座標。`ANCHOR x,y` 使用正視圖座標，可覆寫預設定位點。`TOP` 與 `BOTTOM` 是保留語法，本版會回報尚未支援。

### 九宮格與陣列

`@K1` 至 `@K9` 採用 [CN 的九宮格配置](#at)。有尺寸時，以旋轉後的介面輪廓包絡對齊 BODY 內側邊緣，中央方向置中。無尺寸時，以介面中心點對齊。九宮格決定繪圖位置，組裝定位點仍由 TYPE 或 `ANCHOR` 決定。例如 `LINK RIGHT @K4` 會畫在左側，預設定位點仍在右緣。工具接受位於本體範圍外的座標。

`-S0..S7` 依 `LABEL` 的範圍格式展開，也接受反向範圍及步長，例如 `LINK -S0..S6 BY 2 FRONT @ 0,0 PITCH 20`。每個陣列最多 100 個介面。`@` 或九宮格決定第一個介面的中心。其餘沿局部 +X 方向按 `PITCH` 排列，`ROT` 正值使陣列方向及介面外框逆時針旋轉。陣列有兩個以上介面時必須指定 `PITCH`。若有 `ANCHOR`，它是第一個介面的定位點，後續定位點沿陣列等距平移。

### 繪圖與匯出

`SIZE` 定義紫色虛線的無填色輪廓。`RIGHT` 與 `LEFT` 另加朝對接方向的小箭頭。省略 `SIZE` 時，`RIGHT`、`LEFT`、`FRONT` 繪製位置標記，`BACK` 只保留定位資料。明確指定的 ID 預設顯示在介面旁，自動 ID 預設隱藏。用 `NAME "文字"` 覆寫圖面文字，或用 `NAME NONE` 隱藏。陣列的名稱覆寫套用於各介面。

`LINK` 外觀包含在 SVG 匯出。未來的 DXF 匯出預計使用 `EPART_LINK` 圖層與 AutoCAD 6 號色（洋紅）。

### 範例

CPU 的直接擴充介面與 HMI 網路埠。

```text
PART FX5UJ-40MT/ES
BODY 130,90,83
VIEW FRONT
LINK -L LEFT @-63,10 SIZE 4,30
LINK RIGHT @K6 SIZE 12,27  # 目測尺寸，暫置於右側中央
LINK -BD FRONT @-20,0 SIZE 40,25
CN -CN4 RJ45 @-45.7,-16.5 ROT 270
  FUNCTION ETHERNET
```

用九宮格快速畫出左右兩側介面。

```text
PART SOME_PLC
BODY 90 90 80
LINK LEFT @K4 SIZE 4 30
LINK RIGHT @K6 SIZE 4 30
```

擴充板以背面安裝於主機正面。省略 `SIZE` 可只記錄定位點。

```text
PART FX5-232-BD
BODY 38,25,15
VIEW FRONT
LINK BACK
```

底板的電源、CPU 與等距插槽。

```text
PART Q38B
BODY 328,98,44
VIEW FRONT
LINK -POWER FRONT @-136,0 SIZE 55,98
LINK -CPU FRONT @-94,0 SIZE 27.4,98
LINK -S0..S7 FRONT @-66,0 SIZE 27.4,98 PITCH 28
```

範例中的尺寸、座標與模板用來示範語法。

FX5-8EX/ES 的端子中心取自 `refs/fx5-8e_a_inside.DXF`。以 BODY 中心為原點，兩欄的 X 為 0.4 mm 和 8.8 mm，欄內節距為 7.62 mm，右欄比左欄低 3.81 mm。端子台外框使用示意輪廓。

## SET 模組組合（v0.4 草案）

`SET` 描述一組設備包含哪些模組，以及它們如何在實體上相接。適用於 PLC、遠端 I/O、底板和其他用 `LINK` 組合的設備。盤面位置由 ELAYOUT 引用組代號決定，接線由 EWIRING 引用成員代號和端子。SET 的組裝規則僅使用幾何定位，程式位址由使用者指定。各自獨立安裝在軌道上的零件，適合在 ELAYOUT 的 `RAIL` 下分別列出。

```text
SET -ID [ON 底板型號]
  NAME "文字"
  [-代號] 型號 [@介面]
  + [-代號] 型號 [@介面]
  ADDR [CN代號] 位址清單
  EMPTY
  BREAK
```

縮排可省略。`NAME` 若有使用，須緊接 SET 宣告，並以引號包住整組顯示名稱。`SET` 與 `PART` 可出現在同一文件中，順序不限。解析型號時優先採用文件內的 `PART` 定義，其次查找內建零件庫。找不到型號時會提示，並畫出標示型號的 40 × 90 mm 灰色佔位框。

SET 和自訂成員代號以 `-` 開頭，其後須為英文字母，代號在同一文件中不分大小寫且須唯一。未寫成員代號時依模組出現順序使用 `-A1.1`、`-A1.2` 等。普通模組與 `+` 模組都計入順序，`EMPTY`、`BREAK` 和 `ON` 指定的底板本身不計入。

### 串接與疊裝

- 串接型省略 `ON`。第一個模組以 BODY 中心為原點，普通模組由左到右，讓前一個普通模組的 `LINK RIGHT` 和目前模組的 `LINK LEFT` 重合。
- 若已定義的零件缺少對接的 LINK，預覽仍會顯示組合，並警告該側採用本體相應邊緣。可用 `LINK LEFT @K4` 或 `LINK RIGHT @K6` 補上定位。兩側都缺 LINK 時，兩台都有正視或背視的 `MOUNT DIN` 就對齊 DIN 高度，背視優先。其餘情況對齊本體中心高度。
- `+` 把模組疊在同段最近的普通模組正面，讓主體的 `LINK FRONT` 和疊裝模組的 `LINK BACK` 重合。缺少介面的一側使用本體中心。多張疊裝模組依序取用主體尚未占用的 `FRONT`。後續普通模組仍接在原主體右側。
- `@` 引用被接對象的 LINK ID，省略前綴 `-`。串接時查前一台的 `RIGHT`，疊裝時查主體的 `FRONT`，底板型查底板的 `FRONT`。指定的介面不存在或已占用時會提示，並採預設順序。`K1` 至 `K9` 保留給九宮格定位。

### 底板與分段

`SET -ID ON 型號` 指定底板，底板中心為組裝原點。普通模組按宣告順序使用第一個尚未占用的 `FRONT` 插槽。`EMPTY` 占用下一槽，`@S6` 可先占用指定槽，後續未指定的模組仍從最前面的空槽接續。插槽用完後會提示，多出的模組由底板右側依序並排。串接型遇到 `EMPTY` 會提示並略過。

`BREAK` 將串接型拆成獨立段。有效的每一段都有自己的原點，可在預覽的視圖選單切換。段首、段尾或連續出現的 `BREAK` 會提示並略過。分段後必須先宣告普通模組才能疊裝或指定 `ADDR`。底板型使用 `BREAK` 會報錯。ELAYOUT 日後可按同一 SET 代號的出現次序放置各段。

### 程式位址

`ADDR` 套用到最近宣告的模組，包含 `+` 模組。依接頭宣告順序及各接頭的 Pin 編號由小到大填入，可指定單個接頭，例如 `ADDR -X1 X30..X37`。清單與 `LABEL` 一樣可用逗號或空白分隔，支援範圍與 `BY` 步長。若指定的接頭 ID 在同一 PART 有多個候選，會列出視圖並報錯。數量不符時會提示，多出的位址略過，缺少的欄位留白。

組裝圖下方的位址表並列實體 `NAME` 和 `ADDR`。每個成員的位址各自保存，同型號的其他成員可有不同位址。

### 範例

官方 `-A1` 範例先列出兩份完整 `PART` 定義，再用以下四行組裝。

```text
SET -A1
  NAME "PLC 主站"
  FX5UJ-40MT/ES
  -A1.2 FX5-8EX/ES
```

第一台自動編為 `-A1.1`。右側模組中心為 `(85,0)`，貼齊後正視外形為 170 × 90 mm。FX5UJ 輸出端子使用參考圖確認的實體上下排。

自訂零件可以只用本體尺寸參與組裝。

```text
PART MY_PLC BODY 90 90 80
PART MY_IO8 BODY 30 90 80

SET -A3
  MY_PLC
  MY_IO8
  MY_IO8
```

底板和疊裝的介面選擇可用文件內的測試零件驗證。

```text
PART BASE
BODY 100,90,40
LINK -S0..S3 FRONT @-30,0 PITCH 20

PART MODULE
BODY 18,70,30
LINK BACK
LINK -BD FRONT @0,15

PART BOARD
BODY 10,15,5
LINK BACK

SET -A2 ON BASE
  MODULE @S2
  + BOARD @BD
  EMPTY
  MODULE
```

## IND LED

`IND LED` 繪製功能指示燈。名稱以逗號分隔，名稱含空白或逗號時用引號包住。既有的單顆引號寫法也可使用。

```text
IND LED 名稱[,名稱...] @位置 [PITCH mm] [ROT deg] [D diameter] [LABEL_POS 方向] [COLOR 色碼]
```

- `@` 或 `AT` 指定第一顆燈的中心，可用 `x,y` 或 `K1` 至 `K9`。九宮格依當前視圖的 BODY 和第一顆燈的圓形輪廓定位。
- 後續指示燈按 `PITCH` 沿局部 +X 排列，再以 `ROT` 逆時針旋轉。預設 `PITCH 10`、`ROT 0`、`D 2`。`D` 和 `PITCH` 須為正數，單行最多 100 顆。
- `D`、`PITCH`、`ROT`、`LABEL_POS`、`COLOR` 可按任意順序寫在位置之後，套用到該行所有指示燈。
- 標籤預設在右側（`K6`）。可用 `K1` 至 `K9` 或與 CN 相同的英文方位。標籤方向以視圖為準，`ROT` 只旋轉排列方向。需沿用上方標籤時寫 `LABEL_POS K8`。
- `COLOR` 支援 `GN`、`RD`、`YE`、`BU`、`WH` 和全名 `GREEN`、`RED`、`YELLOW`、`BLUE`、`WHITE`。省略時繪製中性色無填充輪廓。[IEC 60757 色彩代號](https://webstore.iec.ch/en/publication/66266)

```text
IND LED RUN @K9
IND LED "DC OK",ALARM @ 5,10 COLOR YE LABEL_POS K8 PITCH 6
```

FX5UJ 的前四顆狀態燈等距排列，第五顆另指定位置。

```text
IND LED PWR,ERR,P.RUN,CARD @42.5,5.5 PITCH 2.75 ROT -90 D 1.3
IND LED SD/RD @42.5,-6.5 D 1.3
```

## MOUNT

| 語法 | 圖面內容 |
| --- | --- |
| `MOUNT HOLE AT x,y D diameter` | 以 AT 為中心的圓孔 |
| `MOUNT STUD AT x,y D diameter [L length]` | 以 AT 為中心的螺柱。L 不影響正投影 |
| `MOUNT SLOT AT x,y W width H height` | 以 AT 為中心的長孔 |
| `MOUNT SLOT AT x,y W width OPEN TOP` 或 `OPEN BOTTOM` | 開口朝 BODY 上緣或下緣的 U 形槽 |
| `MOUNT DIN AT x,y W width [H height]` | 以 AT 為中心的 DIN 安裝投影。W 為水平跨度，H 為截面寬度 |

單顆零件圖顯示安裝孔與螺柱的中心十字。SET 組裝圖只顯示輪廓。

未指定時，`D`、`W`、`H` 分別使用 4、12、5 mm。對 35 mm DIN 軌，在背視圖使用 `H 35` 表示跨軌方向的尺寸。`W` 可依圖面所需的水平跨度指定。

FX5UJ-40MT/ES 依原廠直接安裝圖，在正視圖標出兩個 Ø4.5 mm 螺絲孔，圓心為 `(-50,41)` 和 `(61,-41)`。背視圖的 DIN 軌中心沿用 DXF 的高度基準，水平跨度採示意值。[Mitsubishi FX5UJ 硬體手冊，直接安裝](https://dl.mitsubishielectric.com/dl/fa/document/manual/plcf/sh082206eng/sh082206engg.pdf)

開口槽必須指定正數 `W`。`AT` 是半圓端的圓心，半徑為 `W/2`。槽的直邊連到指定的 BODY 邊緣，該段本體邊線由槽輪廓取代。槽深由圓心和邊緣的位置決定。開口槽須落在本體直邊範圍內，且彼此分開。

```text
BODY 34,134,77
MOUNT SLOT @ -5,63 W 5 OPEN TOP
MOUNT SLOT @ -5,-63 W 5 OPEN BOTTOM
```

## BRAND、MODEL、TEXT、BOX

`BRAND "Name" AT x,y SIZE w,h`、`MODEL "Model" AT x,y SIZE w,h` 和 `TEXT "Description" AT x,y SIZE w,h` 都以指定中心和尺寸繪製一般字型文字。預覽器也支援 `BOX AT x,y SIZE w,h` 以指定中心繪製矩形。

## TABLE、TITLE

在預覽開啟「拖曳模式」後，單一 PART 視圖可拖接頭、端子群或表頭。由同一行 `TABLE … SPLIT` 產生的表格會一起移動。共同圖面可拖整個零件，放手後更新 `PLACE`。拖曳空白處可平移圖面。

點到可拖曳的物件時，DSL 編輯器會短暫高亮其宣告行。宣告行在可見範圍外時，編輯器會捲到該行。寫回座標時會保留當下的捲動位置。

預設以 1 mm 為單位定位。邊緣或中心對齊時顯示提示線，位置由滑鼠與格線決定。按住 Shift 可用 0.1 mm 定位，按住 Alt 可隱藏提示線，按 Esc 可取消拖曳。放手後寫回原指令的定位座標，可用 Ctrl+Z 復原。表格以左上角定位，接頭與端子群沿用各自的定位點。

開啟「拖曳模式」後，在單一 PART 視圖的空白處長按約半秒，可開啟環形插入選單。先選接頭、端子群、指示燈或安裝件，再選型號。RJ45 與 D-sub 接頭可接著選公頭或母座。插入位置取長按處的 1 mm 整數座標，指令寫入目前的 VIEW，可用 Ctrl+Z 復原。

`TABLE -X1 @ x,y` 放置指定接頭的功能表，`TABLE T1 @ x,y` 可指定獨立端子。既有的無前綴查詢（例如 `TABLE CN1 AT x,y`）在找不到同名目標時會查找 `-CN1`。定位點是表格左上角。表格顯示 PIN、NAME、FUNCTION，Pin 依編號排序。`TABLE ALL AT x,y` 包含同一視圖的接頭和獨立端子，並加上 CN 欄。`TITLE "Pin assignment"` 可接在 TABLE 下方覆寫標題。

同一視圖可以先放 TABLE，再宣告目標接頭。目標不存在時會警告，並省略該表格。接頭表屬於零件預覽的視圖。將零件放入 SET 時，組裝圖可另外宣告自己的 TABLE。

`TABLE -CN1 K8 SPLIT` 把表格放在圖面上方置中，`K2` 放下方置中，其餘九宮格方位也可使用。九宮格定位可省略 `AT` 或 `@`。加上 `SPLIT` 時，左表列奇數 Pin，右表列偶數 Pin，各接頭在組內仍按實體 Pin 編號排序。

在 `SPLIT` 後加群組，可指定每張表的 Pin。用 `/` 分隔各表，組內可用逗號或空白列出 Pin，例如 `1,3,5`，也可用 `1..25 BY 2` 表示從 1 到 25 每次加 2。步長須為正整數，省略時為 1。舊檔仍可使用 `:2` 步長寫法。各表由左至右依群組順序放置，只顯示指定的 Pin。重複指定同一 Pin 會報錯。預覽器的「50 Pin 焊接表（四組）」使用台達 ASDA-A2 的 CN1 腳位。NAME 欄的一般腳位採原廠信號名稱，DI／DO 採 PT 模式預設功能。DO 名稱保留正負極性。焊點依線端示意圖由左至右分成 2–24 偶數、1–25 奇數、27–49 奇數、26–50 偶數。接頭圖內顯示腳號，表格顯示 NAME。MDR 公頭外框依原廠圖面重建，焊接腳位仍為示意。MDR50M_SOLDER 可用於採相同接頭和焊點排列的設備，信號名稱由各設備的 PINS 定義。SCSI50 和舊名 ASDA_A2_CN1 為同一模板的別名。原有的 MDR26 與 SCSI26 是未區分公母的通用模板。外形來源為 [3M TS-0669](https://multimedia.3m.com/mws/media/22367O/3mtm-mdr-050-solder-plug-connector-shielded-ts0669.pdf)。

```text
TABLE -CN1 K2 SPLIT 2..24 BY 2 / 1..25 BY 2 / 27..49 BY 2 / 26..50 BY 2
```

TABLE 下方可直接貼兩欄 CSV，每筆一行，不需縮排。第一欄為位址或端子標示，第二欄為用途。單一接頭表也可用實體 Pin 編號。用途含逗號時用雙引號包住，欄內的雙引號寫成兩個。首列可用 `ADDR,FUNCTION` 或 `Address,Comment` 作為欄名。找不到對應 Pin 或對應到多個 Pin 時會提示。

組裝表寫在 SET 成員宣告之後，或另立一段引用 SET 代號。位址優先查成員的 `ADDR`，未指定 ADDR 的 Pin 可用原廠端子標示。位址精確比對，`X00` 和 `X0` 各自保留。表格顯示有位址對應的接頭和該接頭的其他 Pin。有明確 TABLE 的組裝段使用指定位置，其餘段沿用自動位址表。

```text
TABLE -A1 K2 SPLIT
  TITLE "I/O 焊接表"
X00,急停
X01,啟動
X02,"手動,低速"
```

## SVG 與檔案

下載檔名中的 `/` 會換成全形 `／`，例如 `FX5UJ-40MT／ES.epart`。其他 Windows 保留字元換成底線。原廠型號在 DSL 與圖面文字中保留 `FX5UJ-40MT/ES`。

成組數值可使用逗號、空白或兩者混合分隔，數量須符合各指令定義。儲存有效的 `.epart` 時，成組數值會統一使用逗號且逗號旁無空白，編輯器原文、引號文字與註解會保留。有解析錯誤時則儲存原文。

預覽器可開啟及儲存 `.epart` 文字檔，並匯出當前視圖的 SVG。匯出檔的 `width` 和 `height` 以 mm 標示，數值對應 `viewBox` 的寬與高，因此一個 SVG 使用者單位對應 1 mm。SVG 圖框會納入本體外的安裝結構、文字與接頭標籤，並包含表格和圖面留白。預覽預設適合視窗。可用滾輪以游標為中心縮放，或用 ＋、− 按鈕調整。拖曳可平移，按「還原」可回到完整圖面。鍵盤焦點在圖面上時，可用方向鍵、＋、− 和 Home 操作。SVG 依完整圖面的尺寸匯出。

DXF 匯出目前支援單一 PART 的當前視圖。圖面採 AutoCAD 2007 DXF 格式、毫米單位、BODY 中心為原點，X 向右、Y 向上。本體、安裝結構、接頭外框、針腳、文字與指示燈分別放在 EPART_BODY、EPART_MOUNT、EPART_CONNECTOR、EPART_PIN、EPART_TEXT、EPART_INDICATOR 圖層。TABLE、LINK、預覽輔助線、SET 和 PLACE 共同圖面由 SVG 匯出。DXF 文字保留 Unicode，顯示取決於 CAD 使用的字型。

## 通用範例

```text
# Bytes EPART DSL — demo only, not manufacturer-certified
PART SAMPLE_SERVO
BODY 120 180 65

VIEW FRONT
CN -CN1 IDC20 AT -28,48
  LABEL_ROWS A1..A10 / B1..B10
  PIN 1 SG "Signal ground"
  PIN 2 24V "Control power"
CN -CN2 DE9 STYLE S AT 30,-32 ROT 90
  PIN 1 RX "Receive"
  PIN 2 TX "Transmit"
MOUNT HOLE AT -48,76 D 5
MOUNT HOLE AT 48,76 D 5
MOUNT HOLE AT -48,-76 D 5
MOUNT HOLE AT 48,-76 D 5
TABLE -CN1 AT 90,72
  TITLE "CN1 Pin Functions"

VIEW RIGHT
CN -CN3 TB3 AT 0,36
  PINS 1=L 2=G 3=N
  PIN 1 L "AC line"
  PIN 2 G "Ground"
  PIN 3 N "Neutral"
TABLE -CN3 AT 48,60
```
