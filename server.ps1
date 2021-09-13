# �|�[�g�ԍ�
$Port = "8080"
# URL
$url = "http://localhost:" + $Port + "/"
# localhost�Ɍq���Ȃ����ւ̑Ή�
# $url = "http://+:" + $Port + "/Temporary_Listen_Addresses/"
# ���N�G�X�g�����[�g(/)�̏ꍇ�A�Ăяo�����t�@�C��
$HomePage = "index.html"
# �R���e���c�^�C�v����(�u���E�U�ɑ���f�[�^�̎��)
$ContentType = @{
    "css" = "text/css"
    "js" = "application/javascript"
    "json" = "application/json"
    "html" = "text/html"
    "pdf" = "application/pdf"
    "txt" = "text/plain"
    "jpg" = "image/jpeg"
    "png" = "image/png"
    "*" = "application/octet-stream"
}

# ���N�G�X�g���Ȃ��Ȃ�܂Ńt�@�C�����M���s��
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
        $response.Value.ContentType += ";charset=UTF-8"
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
    $listener.Prefixes.Add($url)
    Write-Output "* Running on $url (Press CTRL+C to quit)"

    try {
        $listener.Start()
        while ($listener.IsListening) {
            $task = $listener.GetContextAsync()
            # �u���b�L���O��Ctrl+C�������Ȃ��Ȃ邱�Ƃւ̑΍�
            while ($task.AsyncWaitHandle.WaitOne(500) -eq $false) {}
            $context = $task.GetAwaiter().GetResult()

            If ($page = $context.Request.Url.LocalPath -eq "/") {
                # �ŏ��̃y�[�W���M
                $page = $HomePage
            } else {
                # CSS,Javascript�Ȃǂ̃t�@�C�����v�����ꂽ�ꍇ
                $page = $context.Request.RawUrl
            }
            $response = $context.Response
            If ($context.Request.IsLocal) {
                # ���[�J��PC����̐ڑ��̏ꍇ
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