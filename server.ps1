$HomePage = "index.html"
$Port = "8080"
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
    # $listener.Prefixes.Add("http://+:" + $Port + "/Temporary_Listen_Addresses/")

    $listener.Start()
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        If ($page = $context.Request.Url.LocalPath -eq "/") {
            $page = $HomePage
        } else {
            $page = $context.Request.RawUrl
        }
        $response = $context.Response
        If ($context.Request.IsLocal) {
            fileSendToClient ([ref]$response) $page
        }
        Write-Output $context.Request.RawUrl
        Write-Output $context.Response
        $response.Close()
    }
}

main