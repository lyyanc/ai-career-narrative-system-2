# 職涯敘事製圖所｜AI 職涯敘事生成系統

> 生成可能，而非定義未來。

技術型高中職業試探的教學工具。整合 **MBTI 認知風格**、**RIASEC 職業興趣**與**真實任務偏好**三份量表，
生成結構型、故事型、文化型三種版本的自我敘事，並對接教育部技職架構
**6 大類 · 15 群 · 94 專業類科（92 一般 + 2 特殊）**，推薦前三名群科與逐條理由。

- **計畫名稱**：生成可能，而非定義未來：AI 職涯敘事生成與技高群科探索計畫
- **單位／作者**：新北市立鶯歌工商　顏龍源、盧淑惠
- **投稿**：第二屆「技職力 100」職業試探與技職引導組 ／ 2026 台灣 AI 教育年會教學應用

---

## 功能

| 區塊 | 內容 |
|---|---|
| 基本資料 | 姓名、出生年月日、性別、血型、就學階段（全部可留白） |
| MBTI 量表 | 32 題四向度李克特量表，正反向題交錯，輸出四碼與各向度 0–100 強度 |
| RIASEC 量表 | 36 題，六型各 6 題，輸出 0–100 權重與興趣前三碼 |
| 真實任務偏好 | 12 題，問「願不願意做」而非「喜不喜歡」 |
| 生涯階段定位 | 依 Super 生涯發展理論，以年齡定位所處階段 |
| 聚合效度檢核 | 交叉比對興趣與實作意願，分三級預警供輔導參考 |
| 三版本敘事 | A 結構型 / B 故事型 / C 文化型（可開關） |
| 群科配對 | 餘弦相似度比對，前三名 + 推薦理由 |
| 探索任務 | 可勾選清單、完成度追蹤 |
| 輸出 | 複製摘要、列印探索單（含簽章欄）、重新測驗、社群分享卡 |

## 資料保存（v2）

計分與敘事生成**全部在瀏覽器內完成**，不經過任何伺服器。是否把結果留存，
由學生在步驟一的同意欄位自行決定 —— **不勾選也能使用全部功能**。

| 項目 | 設定 |
|---|---|
| 資料庫 | Google Firestore，`asia-east1`（台灣彰化） |
| 集合 | `submissions` |
| 驗證 | Firebase Anonymous Auth（臨時 uid，無帳號密碼） |
| 權限模型 | **只寫不讀** —— `read` / `update` / `delete` 全部禁止 |
| 保存欄位 | 同意紀錄、班級代碼、基本資料、**32＋36＋12 題原始作答**、完整計算結果 |
| 利用期間 | 畢業後兩年 |

原始作答一併保存，日後可重新計分，或做量表的信效度分析。

### 安全設計

`firestore.rules` 強制五道檢查：必須通過匿名驗證、文件內 `meta.uid` 必須等於
`request.auth.uid`（防冒名）、**`consent.agreed` 必須為 true**（同意條款在伺服器端二次驗證，
前端勾選框被繞過也擋得住）、頂層欄位白名單、各欄位長度與陣列長度上限。

因為 `read` 一律拒絕，即使有人拿到網站原始碼與 apiKey，**也讀不到任何一筆學生資料**。
Firebase 的 apiKey 本來就是公開識別碼而非密鑰，真正的門鎖是規則與授權網域。

未勾選同意的使用者，全程**不會與 Firebase 建立連線**，也不會產生匿名 uid ——
模組採延遲初始化。

### 老師如何取用資料

網頁端讀不到，請由以下任一方式：

- **Firebase Console** → Firestore Database → `submissions` 集合，可直接瀏覽與篩選
- **匯出 CSV**：Console 沒有內建匯出，需用 Admin SDK 或
  `gcloud firestore export` 匯到 Cloud Storage

### 自動刪除（TTL）

每筆資料寫入時會一併記下 `expiresAt`，由 Firestore 的 TTL 政策自動刪除，
**不依賴任何人記得去清**。到期日依學生填寫的就讀階段推算：

| 就讀階段 | 距畢業 | 保存至 |
|---|---|---|
| 國中七年級 / 技高一年級 | 2 年 | 畢業年 + 2 年的 7/31 |
| 國中八年級 / 技高二年級 | 1 年 | 同上 |
| 國中九年級 / 技高三年級 | 0 年 | 同上 |

台灣學年度自 8 月起算，8 月之後填寫者，本學年度視為結束於次年 6 月。
安全規則另設上下界：`expiresAt` 必須晚於此刻、且不得超過 10 年，
防止有人把期限設成西元 9999 年來規避刪除。

**Console 設定**：Firestore Database → TTL → 建立政策 →
集合群組 `submissions`、時間戳記欄位 `expiresAt`。

### App Check（防灌假資料）

以 **reCAPTCHA Enterprise** 驗證請求確實來自本網站，擋掉繞過網頁直接打 API 的腳本。

> **provider 必須前後一致。**Enterprise 與傳統 v3 的金鑰不能互換：Enterprise 金鑰丟進
> 傳統 `api.js` 會被拒為 `Invalid site key`。程式碼用 `ReCaptchaEnterpriseProvider`，
> Firebase Console 的 App Check 也必須註冊為 reCAPTCHA Enterprise。
> Enterprise 每月 10,000 次評估免費，超過需在 Google Cloud 專案啟用計費。
**目前狀態：停用中。**`index.html` 裡的 `window.RECAPTCHA_SITE_KEY` 留空即停用，網站照常運作。

停用原因：專案中兩把 reCAPTCHA 金鑰各缺一半 —— 一把能產生 token 但 Firebase 無法
assess（疑似建於另一個 Cloud 專案），另一把已在 Firebase 註冊卻連 token 都產不出來
（傳統與 Enterprise API 皆回 `Invalid site key`）。在釐清前先行停用，避免無效的錯誤請求。

**要重新啟用**：在 Google Cloud Console 的 `ai-career-narrative` 專案中建立一把
**Score-based 網站金鑰**，網域填 `ai-career-narrative-system-2.vercel.app`，
同時填入 `window.RECAPTCHA_SITE_KEY` 與 Firebase App Check。兩邊必須是同一把。

> **`window.RECAPTCHA_SITE_KEY` 是單一真實來源。**填入值即自動啟用 App Check、
> 顯示 reCAPTCHA 文字聲明、並顯示告知事項第 8 條；留空則三者一併消失。
> 這樣就不會出現「已停用卻仍告訴學生會載入 reCAPTCHA」的不實告知。
> **修改時請維持這個連動，不要把金鑰另外寫死在模組裡。**

reCAPTCHA 右下角的浮動徽章已用 CSS 隱藏。Google 條款允許隱藏，但要求改以可見文字聲明替代，
本站的替代聲明有兩處：儲存狀態區的 `.rc-note`，以及同意書告知事項第 8 條。
**若日後移除這兩處文字，必須把徽章改回顯示**，否則違反 reCAPTCHA 服務條款。

> **隱私取捨：**reCAPTCHA 會蒐集 IP 與瀏覽器操作行為，適用 Google 隱私權政策。
> 因此它只在使用者**勾選同意並送出時**才載入 —— 未同意者全程不會載入 reCAPTCHA，
> 也不會與 Firebase 建立任何連線。此事實已寫入告知事項第 8 條。

### 待辦

- **紙本同意書**：網站上的勾選是學生本人勾的。未成年學生的法定代理人同意，
  仍需另行取得紙本。

## 設計原則

- **AI 是翻譯引擎，不是決策工具。** 系統產出「值得去看看的方向」，不產出「你只能走的路」。
- **文化趣味模式可開關。** 星座、生肖、血型與命理語彙只作為家長與學生的參與入口，
  並提供「家長焦慮轉譯對照表」，**完全不參與群科配對計算**。各校可依校風關閉。
- **個資最小化，且保存與否由學生決定。** 無登入、無 Cookie、無 localStorage、無分析追蹤。
  計分與敘事生成全部在瀏覽器記憶體內完成。未勾選同意者不上傳、不連線 Firebase、不載入 reCAPTCHA，
  關閉分頁即銷毀；勾選者才寫入學校輔導資料庫，並於畢業後兩年自動刪除。

## 使用限制

本系統為**職業試探的教學工具**，非心理衡鑑、非醫療診斷、非命理占卜、非落點分析。
所用量表為教學用簡式量表，未經標準化常模驗證。適配指數是「相似程度」，與錄取分數、招生名額、就業率無關。

---

## 技術

單一靜態 HTML 檔，無建置步驟、無框架、無相依套件。全部邏輯內嵌於 `index.html`。

```
.
├── index.html                    # 完整網站（HTML + CSS + JS + Firebase 模組）
├── og-image.png                  # 1200×630 社群分享圖
├── firestore.rules               # Firestore 安全規則（貼進 Console）
├── firebase-config.template.js   # Firebase 設定值填寫範本
├── vercel.json                   # Vercel 靜態託管設定與安全標頭
├── tools/
│   └── make-og.ps1               # 重新產生 og-image.png
└── README.md
```

### 重新產生社群分享圖

`og-image.png` 由指令稿產生，不需要繪圖軟體。改完文案後執行：

```powershell
powershell -ExecutionPolicy Bypass -File tools\make-og.ps1
```

需求：Windows PowerShell（System.Drawing）、已安裝 Noto Serif TC 與 Noto Sans TC。
指令稿本身必須維持 **UTF-8 with BOM** 編碼，否則 PowerShell 5.1 會以 ANSI 讀取而使中文毀損。

> 換綁自訂網域時，記得同步更新 `index.html` 裡 `og:url`、`og:image`、`twitter:image`
> 與 `canonical` 的絕對網址 —— Open Graph 不接受相對路徑。

### 本機預覽

直接用瀏覽器開啟 `index.html` 即可，不需要伺服器。

### 部署到 Vercel

本專案為純靜態站，Vercel 會自動偵測，**不需要設定 build command 或 output directory**。

**方式一：Git 整合（推薦，之後 push 就自動部署）**

1. 把本目錄推上 GitHub：

   ```bash
   git init
   git add .
   git commit -m "feat: AI 職涯敘事生成系統"
   git branch -M main
   gh repo create ai-career-narrative-system --public --source=. --push
   ```

2. 到 <https://vercel.com/new> → Import Git Repository → 選擇該 repo → Deploy。
   Framework Preset 選 **Other**，其餘留空即可。

**方式二：Vercel CLI**（需先安裝 Node.js）

```bash
npm i -g vercel
vercel --prod
```

**方式三：拖拉上傳**

到 <https://vercel.com/new> 頁面下方，直接把整個資料夾拖進去。

---

## 授權與引用

本系統之量表題項、群科標定向量與敘事文案為本計畫自撰，供教學使用。
理論依據：Holland 職業興趣理論（RIASEC）、MBTI 四向度架構、Super 生涯發展理論（Life-span Theory）、
全國技術型高中專業群科統整資料。

群科分類採本計畫所使用之 15 群架構（家事類含幼保群、海事水產類合併為一群）。
教育部課綱在部分名稱與歸類上略有差異，各校招生名稱亦不盡相同，實際請以各校招生簡章與技高課程綱要為準。
