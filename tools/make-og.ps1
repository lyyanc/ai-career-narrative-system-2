# 產生 1200x630 Open Graph 分享圖
# 用法： powershell -ExecutionPolicy Bypass -File tools\make-og.ps1
# 需求： Windows PowerShell + System.Drawing + 已安裝 Noto Serif TC / Noto Sans TC

Add-Type -AssemblyName System.Drawing

$W = 1200; $H = 630
$out = Join-Path (Split-Path $PSScriptRoot -Parent) 'og-image.png'

function C([int]$r,[int]$g,[int]$b,[int]$a=255){ [System.Drawing.Color]::FromArgb($a,$r,$g,$b) }

# --- 調色盤（與網站深色主題一致） ---
$cBgTop   = C 16 32 50
$cBgBot   = C 8  18 30
$cGrid    = C 150 196 240 16
$cRule    = C 39 65 91
$cInk     = C 223 233 242
$cMuted   = C 138 160 180
$cAccent  = C 255 129 70

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g   = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$sf = [System.Drawing.StringFormat]::GenericTypographic.Clone()
$sf.FormatFlags = $sf.FormatFlags -bor [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces

# --- 底色漸層 ---
$rect = New-Object System.Drawing.Rectangle(0,0,$W,$H)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $cBgTop, $cBgBot, 65.0)
$g.FillRectangle($grad, $rect)

# --- 右上暖色暈光 ---
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(760, -230, 720, 720)
$glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$glow.CenterColor    = C 255 140 80 46
$glow.SurroundColors = @((C 255 140 80 0))
$g.FillPath($glow, $glowPath)

# --- 製圖方格 ---
$penGrid = New-Object System.Drawing.Pen($cGrid, 1)
for ($x = 0; $x -lt $W; $x += 30) { $g.DrawLine($penGrid, $x, 0, $x, $H) }
for ($y = 0; $y -lt $H; $y += 30) { $g.DrawLine($penGrid, 0, $y, $W, $y) }

# --- 圖框 ---
$penRule = New-Object System.Drawing.Pen($cRule, 1)
$g.DrawRectangle($penRule, 28, 28, $W-57, $H-57)

# --- 字型 ---
function F([string]$fam,[single]$size,[string]$style='Regular'){
  New-Object System.Drawing.Font($fam, $size, [System.Drawing.FontStyle]::$style, [System.Drawing.GraphicsUnit]::Pixel)
}
$fDisplay = F 'Noto Serif TC' 78 'Bold'
$fBrand   = F 'Noto Sans TC'  23 'Bold'
$fBody    = F 'Noto Sans TC'  25 'Regular'
$fMonoSm  = F 'Consolas'      14 'Regular'
$fMonoMd  = F 'Consolas'      16 'Bold'
$fHex     = F 'Consolas'      19 'Bold'
$fHexCjk  = F 'Noto Sans TC'  13 'Regular'

$bInk    = New-Object System.Drawing.SolidBrush($cInk)
$bMuted  = New-Object System.Drawing.SolidBrush($cMuted)
$bAccent = New-Object System.Drawing.SolidBrush($cAccent)

# 字距追蹤（System.Drawing 無 letter-spacing，逐字繪製）
function DrawTracked($gfx,[string]$text,$font,$brush,[single]$x,[single]$y,[single]$track){
  $cx = $x
  foreach ($ch in $text.ToCharArray()) {
    $s = [string]$ch
    $gfx.DrawString($s, $font, $brush, $cx, $y, $sf)
    $cx += $gfx.MeasureString($s, $font, [System.Drawing.PointF]::new(0,0), $sf).Width + $track
  }
  return $cx
}
function TW($gfx,[string]$text,$font){
  return $gfx.MeasureString($text, $font, [System.Drawing.PointF]::new(0,0), $sf).Width
}

# ================= 左上品牌 =================
$penAcc = New-Object System.Drawing.Pen($cAccent, 2)
$g.DrawRectangle($penAcc, 76, 58, 46, 46)
$aiW = TW $g 'AI' $fMonoMd
$g.DrawString('AI', $fMonoMd, $bAccent, 76 + (46 - $aiW)/2, 58 + 13, $sf)

$g.DrawString('職涯敘事製圖所', $fBrand, $bInk, 138, 58, $sf)
DrawTracked $g 'CAREER NARRATIVE DRAFTING ROOM' $fMonoSm $bMuted 139 88 1.9 | Out-Null

# ================= 主標題 =================
$y1 = 168; $y2 = 262
$g.DrawString('生成可能，', $fDisplay, $bInk, 72, $y1, $sf)

$seg1 = '而非'
$seg2 = '定義未來'
$seg3 = '。'
$x = 72
$g.DrawString($seg1, $fDisplay, $bInk, $x, $y2, $sf);    $x += TW $g $seg1 $fDisplay
$g.DrawString($seg2, $fDisplay, $bAccent, $x, $y2, $sf); $x += TW $g $seg2 $fDisplay
$g.DrawString($seg3, $fDisplay, $bInk, ($x - 20), $y2, $sf)

# ================= 分隔線與副標 =================
$g.DrawLine($penRule, 76, 392, 690, 392)
$g.DrawString('MBTI × RIASEC × 真實任務偏好　—　三語人格整合模型', $fBody, $bInk, 74, 414, $sf)
$g.DrawString('對接技術型高中 6 大類 · 15 群 · 94 專業類科', $fBody, $bMuted, 74, 456, $sf)

# ================= 底部標題欄 =================
$g.DrawLine($penRule, 76, 536, $W-76, 536)
DrawTracked $g '新北市立鶯歌工商　顏龍源、盧淑惠' $fMonoSm $bMuted 76 556 1.2 | Out-Null
$rightTx = 'NO LOGIN · NO UPLOAD · NO TRACKING'
$rw = (TW $g $rightTx $fMonoSm) + ($rightTx.Length * 1.6)
DrawTracked $g $rightTx $fMonoSm $bMuted ($W - 76 - $rw) 556 1.6 | Out-Null

# ================= 霍蘭德六角形 =================
$cx = 952.0; $cy = 268.0; $R = 138.0
function HexPts([single]$cx,[single]$cy,[single]$r,[single[]]$scale){
  $pts = @()
  for ($i = 0; $i -lt 6; $i++) {
    $ang = [Math]::PI / 180.0 * (60 * $i)
    $rr  = $r * $scale[$i]
    $pts += New-Object System.Drawing.PointF(($cx + $rr * [Math]::Sin($ang)), ($cy - $rr * [Math]::Cos($ang)))
  }
  return $pts
}
$one = @(1,1,1,1,1,1)
foreach ($f in @(1.0, 0.666, 0.333)) {
  $g.DrawPolygon($penRule, (HexPts $cx $cy ($R*$f) $one))
}
$penSpoke = New-Object System.Drawing.Pen($cRule, 1)
$penSpoke.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
foreach ($p in (HexPts $cx $cy $R $one)) { $g.DrawLine($penSpoke, $cx, $cy, $p.X, $p.Y) }

# 示範資料（與網站首頁六角圖一致）
$data = @(0.82, 0.66, 0.45, 0.38, 0.55, 0.60)
$dPts = HexPts $cx $cy $R $data
$fillAcc = New-Object System.Drawing.SolidBrush((C 255 129 70 54))
$penData = New-Object System.Drawing.Pen($cAccent, 2.6)
$penData.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
$g.FillPolygon($fillAcc, $dPts)
$g.DrawPolygon($penData, $dPts)
foreach ($p in $dPts) { $g.FillEllipse($bAccent, ($p.X-4.5), ($p.Y-4.5), 9, 9) }

# 頂點標籤
$labels    = @('R','I','A','S','E','C')
$labelsCjk = @('實作型','研究型','藝術型','社會型','企業型','事務型')
$lPts = HexPts $cx $cy ($R + 40) $one
for ($i = 0; $i -lt 6; $i++) {
  $w1 = TW $g $labels[$i] $fHex
  $w2 = TW $g $labelsCjk[$i] $fHexCjk
  $g.DrawString($labels[$i],    $fHex,    $bInk,   ($lPts[$i].X - $w1/2), ($lPts[$i].Y - 15), $sf)
  $g.DrawString($labelsCjk[$i], $fHexCjk, $bMuted, ($lPts[$i].X - $w2/2), ($lPts[$i].Y + 8),  $sf)
}

# 六角圖說明
$cap = 'FIG. 01 — HOLLAND HEXAGON'
$cw = (TW $g $cap $fMonoSm) + ($cap.Length * 1.5)
DrawTracked $g $cap $fMonoSm $bMuted ($cx - $cw/2) 498 1.5 | Out-Null

# ================= 存檔 =================
if (Test-Path $out) { Remove-Item $out -Force }
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
"OG image saved: $out ({0:N0} bytes)" -f (Get-Item $out).Length
