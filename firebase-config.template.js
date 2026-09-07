/* ============================================================
   Firebase 設定範本
   ------------------------------------------------------------
   取得方式：
     Firebase Console → 專案設定(齒輪) → 一般 → 您的應用程式
     → 網頁應用程式 → SDK 設定和配置 → 選「設定 Config」

   把下面六個值換成你自己的，然後把整個物件貼給我，
   我會接進 index.html。這個檔案本身不會被網站載入。

   ------------------------------------------------------------
   關於 apiKey 會不會外洩的疑問：

   Firebase 的 apiKey 「本來就是公開的」，它不是密碼。
   它只是用來標示「請求要送到哪個專案」，Google 官方文件明載
   可以安全地寫在前端原始碼裡。

   真正的防線是 firestore.rules（本 repo 根目錄）與
   Authentication 的「授權網域」設定。所以：
     - 不需要把 apiKey 藏進環境變數
     - 但 firestore.rules 一定要正確設定，那才是門鎖
   ============================================================ */

export const firebaseConfig = {
  apiKey:            "AIzaSy...........................",
  authDomain:        "你的專案ID.firebaseapp.com",
  projectId:         "你的專案ID",
  storageBucket:     "你的專案ID.firebasestorage.app",
  messagingSenderId: "000000000000",
  appId:             "1:000000000000:web:xxxxxxxxxxxxxxxxxxxx"
};

/* 資料寫入位置。若要改集合名稱，記得 firestore.rules 裡的
   match /submissions/{docId} 也要同步改。 */
export const COLLECTION = "submissions";
