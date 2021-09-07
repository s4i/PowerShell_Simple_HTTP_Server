# ���[�g(/)�ŌĂяo�����t�@�C��
$HomePage = "index.html"
# �|�[�g�ԍ�
$Port = "8080"
# �R���e���c�^�C�v����(�u���E�U�ɑ���f�[�^�̎��)
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
    # localhost�Ɍq���Ȃ����Ή�
    # $listener.Prefixes.Add("http://+:" + $Port + "/Temporary_Listen_Addresses/")

    $listener.Start()
    while ($listener.IsListening) {
        # GetContext�Ńu���b�L���O����邽�߁ACtrl+C�������Ȃ��Ȃ�
        $context = $listener.GetContext()
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
}

main