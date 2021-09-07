# リクエストがルート(/)の場合、呼び出されるファイル
$HomePage = "index.html"
# ポート番号
$Port = "8080"
# コンテンツタイプ辞書(ブラウザに送るデータの種類)
$ContentType = @{
    "css" = "text/css"
    "js" = "application/javascript"
    "html" = "text/html"
    "pdf" = "application/pdf"
    "txt" = "text/plain"
    "jpg" = "image/jpeg"
    "png" = "image/png"
    "*" = "application/octet-stream"
}

# リクエストがなくなるまでファイル送信を行う
function fileSendToClient([ref]$response, $fileName) {
    $currentDirectory = Convert-Path .
    $fullPath = Join-Path $currentDirectory $fileName
    if ([IO.File]::Exists($fullPath)) {
        $extension = $(Get-Item $fullPath).Extension.Replace(".", "")
        if ($ContentType.ContainsKey($extension)) {
            $response.Value.ContentType = $ContentType[$extension]
        } else {
            $response.Value.ContentType = $ContentType["*"]
        }
        $content = [IO.File]::ReadAllBytes($fullPath)
        $response.Value.ContentLength64 = $content.Length
        $output = $response.Value.OutputStream
        $output.Write($content, 0, $content.Length)
        $output.Close()
    } else {
        $response.Value.StatusCode = 404
    }
}

function main {
    $listener = New-Object Net.HttpListener
    $listener.Prefixes.Add("http://+:" + $Port + "/")
    # localhostに繋げない環境への対応
    # $listener.Prefixes.Add("http://+:" + $Port + "/Temporary_Listen_Addresses/")

    try {
        $listener.Start()
        while ($listener.IsListening) {
            $task = $listener.GetContextAsync()
            # ブロッキングでCtrl+Cが効かなくなることへの対策
            while ($task.AsyncWaitHandle.WaitOne(500) -eq $false) {}
            $context = $task.GetAwaiter().GetResult()

            If ($page = $context.Request.Url.LocalPath -eq "/") {
                # 最初のページ送信
                $page = $HomePage
            } else {
                # CSS,Javascriptなどのファイルが要求された場合
                $page = $context.Request.RawUrl
            }
            $response = $context.Response
            If ($context.Request.IsLocal) {
                # ローカルPCからの接続の場合
                fileSendToClient ([ref]$response) $page
            }
            Write-Output $context.Request.RawUrl
            Write-Output $context.Response
            $response.Close()
        }
    } catch {
        Write-Error($_.Exception)
    } finally {
        $listener.Close()
    }
}

main
exit