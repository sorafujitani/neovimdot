-- プラグイン設定の読み込み（起動クリティカルパス最小化: その他は lazy の config で遅延）
require("plugins.snacks")
require("plugins.blink-cmp")

-- DAP/Neotest は遅延読み込み用コマンドで読み込み
