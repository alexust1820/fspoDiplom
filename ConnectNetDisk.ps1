Import-Module SmbShare
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Подключение сетевого диска"
$form.Size = New-Object System.Drawing.Size(350, 200)
$form.StartPosition = "CenterScreen"

$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Логин:"
$labelUser.Size = New-Object System.Drawing.Size(60, 20)
$labelUser.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelUser)

$textBoxUser = New-Object System.Windows.Forms.TextBox
$textBoxUser.Size = New-Object System.Drawing.Size(200, 20)
$textBoxUser.Location = New-Object System.Drawing.Point(80, 20)
$form.Controls.Add($textBoxUser)

$labelPassword = New-Object System.Windows.Forms.Label
$labelPassword.Text = "Пароль:"
$labelPassword.Size = New-Object System.Drawing.Size(60, 20)
$labelPassword.Location = New-Object System.Drawing.Point(10, 60)
$form.Controls.Add($labelPassword)

$textBoxPassword = New-Object System.Windows.Forms.TextBox
$textBoxPassword.Size = New-Object System.Drawing.Size(200, 20)
$textBoxPassword.Location = New-Object System.Drawing.Point(80, 60)
$textBoxPassword.UseSystemPasswordChar = $true
$form.Controls.Add($textBoxPassword)

$buttonLogin = New-Object System.Windows.Forms.Button
$buttonLogin.Text = "Подключить"
$buttonLogin.Size = New-Object System.Drawing.Size(100, 30)
$buttonLogin.Location = New-Object System.Drawing.Point(90, 100)
$form.Controls.Add($buttonLogin)

$buttonDisconnectDisk = New-Object System.Windows.Forms.Button
$buttonDisconnectDisk.Text = "Отключить Диск"
$buttonDisconnectDisk.Size = New-Object System.Drawing.Size(100, 30)
$buttonDisconnectDisk.Location = New-Object System.Drawing.Point(200, 100)
$form.Controls.Add($buttonDisconnectDisk)

$buttonLogin.Add_Click({
    $username = $textBoxUser.Text
    $password = $textBoxPassword.Text
    
    Remove-SmbMapping -LocalPath 'H:' `
                      -Force `
                      -UpdateProfile

    try {
         
         New-SmbMapping -LocalPath 'H:' `
                        -UserName "$username" `
                        -Password "$password" `
                        -RemotePath "\\Dcm149\fsposuai" `
                        -ErrorAction Stop

        Stop-Process -Name 'explorer' | Start-Process -FilePath 'C:\Windows\explorer.exe'
        start H:\
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Сетевой диск не удалось подключить. Проверьте логин и пароль! Возможно, другой диск уже подключен.")
    }


})

$buttonDisconnectDisk.Add_Click({

    try {
        Remove-SmbMapping -LocalPath 'H:' -Force -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Сетевой отключен.")
        Stop-Process -Name 'explorer' | Start-Process -FilePath 'C:\Windows\explorer.exe'
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Ниодного сетевого диска не подключено.")
    }
})

$form.ShowDialog()