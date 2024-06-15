Import-module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Изменение пароля"
$form.Size = New-Object System.Drawing.Size(350, 300)
$form.StartPosition = "CenterScreen"

$labelUser = New-Object System.Windows.Forms.Label
$labelUser.Text = "Логин:"
$labelUser.Size = New-Object System.Drawing.Size(60, 30)
$labelUser.Location = New-Object System.Drawing.Point(10, 20)
$form.Controls.Add($labelUser)

$textUser = New-Object System.Windows.Forms.TextBox
$textUser.Size = New-Object System.Drawing.Size(200, 20)
$textUser.Location = New-Object System.Drawing.Point(80, 20)
$form.Controls.Add($textUser)

$labelOldPass = New-Object System.Windows.Forms.Label
$labelOldPass.Text = "Старый пароль:"
$labelOldPass.Size = New-Object System.Drawing.Size(60, 30)
$labelOldPass.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($labelOldPass)

$textOldPass = New-Object System.Windows.Forms.TextBox
$textOldPass.Size = New-Object System.Drawing.Size(200, 20)
$textOldPass.Location = New-Object System.Drawing.Point(80, 100)
$form.Controls.Add($textOldPass)

$labelNewPass = New-Object System.Windows.Forms.Label
$labelNewPass.Text = "Новый Пароль:"
$labelNewPass.Size = New-Object System.Drawing.Size(60, 30)
$labelNewPass.Location = New-Object System.Drawing.Point(10, 150)
$form.Controls.Add($labelNewPass)

$textNewPass = New-Object System.Windows.Forms.TextBox
$textNewPass.Size = New-Object System.Drawing.Size(200, 20)
$textNewPass.Location = New-Object System.Drawing.Point(80, 150)
$form.Controls.Add($textNewPass)

$buttonChange = New-Object System.Windows.Forms.Button
$buttonChange.Text = "Сменить пароль"
$buttonChange.Size = New-Object System.Drawing.Size(100, 30)
$buttonChange.Location = New-Object System.Drawing.Point(110, 200)
$form.Controls.Add($buttonChange)

$buttonChange.Add_Click({
    $User = $textUser.Text
    $OldPass = $textOldPass.Text
    $NewPass = $textNewPass.Text

    try {
        Set-ADAccountPassword -Identity "$User" `
                        -OldPassword (ConvertTo-SecureString -AsPlainText "$OldPass" -Force) `
                        -NewPassword (ConvertTo-SecureString -AsPlainText "$NewPass" -Force) `
                        -Server "DCM149" `
                        -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show("Пароль изменен.`nЗапишите новый пароль в надежное место!")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Пароль не был изменен!`nПроверьте корректность пароля или обратитесь к сис. администратору (кабинет №501).")
    }
})

$form.ShowDialog()