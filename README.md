###**RhinodeGUI (windows)**###

以 Adobe AIR (NativeProcess) 開發的桌面應用程式，目前功能只有幫你打 "node xxx.js"。適合不喜歡開 command line 來打字的朋友。

***

##HOW##

0. 下載 https://github.com/downloads/RhinoLu/RhinodeGUI/RhinodeGUI.air.zip

1. 解壓縮後，執行 RhinodeGUI.exe (建議先掃毒)

2. 首次使用需先設置 node.exe 的路徑。
開啟檔案總管，找到 node.exe，拖拉進去即可。程式記住位置之後就可以跳過這步驟。(通常在 C:\Program Files (x86)\nodejs )

3. 在檔案總管找到你要執行的 *.js，拖拉進去試看看。( 壓縮包裡附兩隻 sample js 檔，app.js 和 hello.js )

4. 若你的 js 是長駐型，例如 web server，則可以按「stop」停止運行中的 node。

5. 「repeat last command」按鈕是重複上一個動作，等同在 command line 按「↑上」鍵的功能。

6. output 視窗太滿時，請按「Clean output」。

***

##TODO##

- 介面
- output 視窗顯示問題(一直往下長...)
- output 網址要下連結
- mac 支援

