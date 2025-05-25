Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Dark mode colors
$bgColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$fgColor = [System.Drawing.Color]::FromArgb(230, 230, 230)
$btnColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
$btnHoverColor = [System.Drawing.Color]::FromArgb(90, 90, 90)
$labelColor = [System.Drawing.Color]::FromArgb(200, 200, 200)
$errorColor = [System.Drawing.Color]::FromArgb(255, 90, 90)
$successColor = [System.Drawing.Color]::FromArgb(144, 238, 144)
$infoColor = [System.Drawing.Color]::FromArgb(255, 165, 0)  # Orange

function Set-DarkControl($ctrl) {
    $ctrl.BackColor = $bgColor
    $ctrl.ForeColor = $fgColor
    if ($ctrl -is [System.Windows.Forms.Button]) {
        $ctrl.BackColor = $btnColor
        $ctrl.FlatStyle = 'Flat'
        $ctrl.FlatAppearance.BorderSize = 0
        $ctrl.Cursor = [System.Windows.Forms.Cursors]::Hand
        # Add hover effects
        $ctrl.Add_MouseEnter({
            $ctrl.BackColor = $btnHoverColor
        })
        $ctrl.Add_MouseLeave({
            $ctrl.BackColor = $btnColor
        })
    }
    elseif ($ctrl -is [System.Windows.Forms.TextBox]) {
        $ctrl.BorderStyle = 'FixedSingle'
        $ctrl.ForeColor = $fgColor
        $ctrl.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    }
    elseif ($ctrl -is [System.Windows.Forms.Label]) {
        $ctrl.ForeColor = $labelColor
        $ctrl.BackColor = 'Transparent'
    }
    elseif ($ctrl -is [System.Windows.Forms.Panel]) {
        $ctrl.BackColor = $btnColor
        $ctrl.BorderStyle = 'FixedSingle'
    }
    elseif ($ctrl -is [System.Windows.Forms.PictureBox]) {
        $ctrl.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
        $ctrl.BorderStyle = 'FixedSingle'
    }
}

# Load properties from gradle.properties if exists
$propsPath = ".\gradle.properties"
$defaults = @{}
if (Test-Path $propsPath) {
    Get-Content $propsPath | ForEach-Object {
        if ($_ -match "^\s*([^=]+)=(.+)$") {
            $defaults[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Launcher Setup"
$form.Size = New-Object System.Drawing.Size(620, 740)
$form.BackColor = $bgColor
$form.ForeColor = $fgColor
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.MinimizeBox = $true
$form.StartPosition = 'CenterScreen'
$form.Topmost = $true
$form.Padding = New-Object System.Windows.Forms.Padding(10)

# Helper to center controls horizontally
function Get-CenteredX($controlWidth) {
    return [math]::Round(($form.ClientSize.Width - $controlWidth) / 2)
}

# Status Labels
$labelWidth = 580

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Fill out all fields to enable Submit"
$statusLabel.TextAlign = 'MiddleCenter'
$statusLabel.Size = New-Object System.Drawing.Size($labelWidth, 30)
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$statusLabel.Location = New-Object System.Drawing.Point((Get-CenteredX $labelWidth), 10)
$statusLabel.ForeColor = $infoColor
$form.Controls.Add($statusLabel)
Set-DarkControl $statusLabel

$errorLabel = New-Object System.Windows.Forms.Label
$errorLabel.Text = ""
$errorLabel.TextAlign = 'MiddleCenter'
$errorLabel.Size = New-Object System.Drawing.Size($labelWidth, 25)
$errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$errorLabel.Location = New-Object System.Drawing.Point((Get-CenteredX $labelWidth), 45)
$errorLabel.ForeColor = $errorColor
$form.Controls.Add($errorLabel)
Set-DarkControl $errorLabel

$imageStatus = New-Object System.Windows.Forms.Label
$imageStatus.Size = New-Object System.Drawing.Size($labelWidth, 25)
$imageStatus.TextAlign = 'MiddleCenter'
$imageStatus.Location = New-Object System.Drawing.Point((Get-CenteredX $labelWidth), 70)
$imageStatus.ForeColor = $successColor
$form.Controls.Add($imageStatus)
Set-DarkControl $imageStatus

# Inputs
$inputs = @{}
$padding = 15
$y = 110

$fields = @(
    @{Label = "Final Name:"; Var = 'finalName'},
    @{Label = "Lower Name:"; Var = 'lowerName'},
    @{Label = "Website:"; Var = 'website'},
    @{Label = "Launcher Description:"; Var = 'launcherDescription'}
)

foreach ($field in $fields) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $field.Label
    $label.Size = New-Object System.Drawing.Size(180, 25)
    $label.Location = New-Object System.Drawing.Point($padding, $y)
    $label.TextAlign = 'MiddleRight'    # <== right-align text inside label box
    Set-DarkControl $label
    $form.Controls.Add($label)

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point(200, $y)
    $textbox.Size = New-Object System.Drawing.Size(380, 25)
    $textbox.Text = $defaults[$field.Var]
    Set-DarkControl $textbox
    $form.Controls.Add($textbox)

    $inputs[$field.Var] = $textbox
    $y += 40
}

# Image section
$imageLabel = New-Object System.Windows.Forms.Label
$imageLabel.Text = "Image (≥512x512):"
$imageLabel.Size = New-Object System.Drawing.Size(180, 25)
$imageLabel.Location = New-Object System.Drawing.Point($padding, $y)
$imageLabel.TextAlign = 'MiddleRight'
Set-DarkControl $imageLabel
$form.Controls.Add($imageLabel)


$imagePathBox = New-Object System.Windows.Forms.TextBox
$imagePathBox.Location = New-Object System.Drawing.Point(200, $y)
$imagePathBox.Size = New-Object System.Drawing.Size(260, 28)
$imagePathBox.ReadOnly = $true
Set-DarkControl $imagePathBox
$form.Controls.Add($imagePathBox)

$imageButton = New-Object System.Windows.Forms.Button
$imageButton.Text = "Browse"
$imageButton.Location = New-Object System.Drawing.Point(470, $y)
$imageButton.Size = New-Object System.Drawing.Size(110, 28)
Set-DarkControl $imageButton
$form.Controls.Add($imageButton)

$y += 50

$imagePreview = New-Object System.Windows.Forms.PictureBox
$imagePreview.Location = New-Object System.Drawing.Point(185, $y)
$imagePreview.Size = New-Object System.Drawing.Size(250, 250)
$imagePreview.SizeMode = "Zoom"
$form.Controls.Add($imagePreview)
Set-DarkControl $imagePreview

$y += 270

# Color picker
$colorBox = New-Object System.Windows.Forms.Panel
$colorBox.Location = New-Object System.Drawing.Point(200, $y)
$colorBox.Size = New-Object System.Drawing.Size(50, 28)
$colorBox.BorderStyle = 'FixedSingle'
$form.Controls.Add($colorBox)

$colorButton = New-Object System.Windows.Forms.Button
$colorButton.Text = "Pick Color Scheme"
$colorButton.Location = New-Object System.Drawing.Point(260, $y)
$colorButton.Size = New-Object System.Drawing.Size(130, 28)
Set-DarkControl $colorButton
$form.Controls.Add($colorButton)

$colorSelected = $false
try {
    if ($defaults['colorScheme']) {
        $color = [System.Drawing.ColorTranslator]::FromHtml($defaults['colorScheme'])
        $colorBox.BackColor = $color
        $colorSelected = $true
    }
} catch {}

$colorButton.Add_Click({
    $colorDialog = New-Object System.Windows.Forms.ColorDialog
    if ($colorDialog.ShowDialog() -eq "OK") {
        $colorBox.BackColor = $colorDialog.Color
        $colorSelected = $true
       
    }
})

$y += 50

# Submit button
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = "Submit"
$submitButton.Location = New-Object System.Drawing.Point(240, $y)
$submitButton.Size = New-Object System.Drawing.Size(140, 40)
Set-DarkControl $submitButton
$form.Controls.Add($submitButton)

# Helper functions for image resizing and saving icon files
function Resize-Image {
    param(
        [System.Drawing.Image]$image,
        [int]$width,
        [int]$height
    )
    $newBitmap = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($newBitmap)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($image, 0, 0, $width, $height)
    $graphics.Dispose()
    return $newBitmap
}

function Save-IconFile {
    param(
        [System.Drawing.Image]$image,
        [string]$path
    )
    # Save as PNG icon file (Windows .ico format requires special encoding,
    # here just saving PNG with .ico extension, usually okay for modern Windows)
    $image.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

# Validation function to enable Submit button only if all fields valid


# Initialize validation on text change
foreach ($tb in $inputs.Values) {
    $tb.Add_TextChanged({ ValidateForm })
}

# Image validation and loading
$imageValid = $false
$imagePath = "src/main/resources/net/runelite/launcher/runelite_splash.png"
if (Test-Path $imagePath) {
    try {
        $img = [System.Drawing.Image]::FromFile($imagePath)
        if ($img.Width -ge 512 -and $img.Height -ge 512) {
            $imagePreview.Image = $img
            $imageStatus.Text = "✅ Valid image: $($img.Width)x$($img.Height)"
            $imageStatus.ForeColor = $successColor
            $imageValid = $true
            $imagePathBox.Text = $imagePath
        }
    } catch {}
}

$imageButton.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp"
    if ($dialog.ShowDialog() -eq "OK") {
        $imagePathBox.Text = $dialog.FileName
        try {
            $img = [System.Drawing.Image]::FromFile($dialog.FileName)
            if ($img.Width -ge 512 -and $img.Height -ge 512) {
                $imagePreview.Image = $img
                $imageStatus.Text = "✅ Valid image: $($img.Width)x$($img.Height)"
                $imageStatus.ForeColor = $successColor
                $imageValid = $true
                $errorLabel.Text = ""
            } else {
                $imageStatus.Text = ""
                $errorLabel.Text = "❌ Image must be ≥512x512"
                $imageValid = $false
                $imagePreview.Image = $null
            }
        } catch {
            $imageStatus.Text = ""
            $errorLabel.Text = "❌ Error loading image"
            $imageValid = $false
        }
    }
})


function Resize-Image($img, $width, $height) {
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($img, 0, 0, $width, $height)
    $graphics.Dispose()
    return $bmp
}

# Submit button click handler
$submitButton.Add_Click({
    # Save to gradle.properties
    $content = @()
    $content += "finalName=$($inputs['finalName'].Text)"
    $content += "lowerName=$($inputs['lowerName'].Text)"
    $content += "website=$($inputs['website'].Text)"
    $color = $colorBox.BackColor
    $hex = "#{0:X2}{1:X2}{2:X2}" -f $color.R, $color.G, $color.B
    $content += "colorScheme=$hex"
    $content += "launcherDescription=$($inputs['launcherDescription'].Text)"

    $content | Set-Content $propsPath -Encoding UTF8

    # Process images and icons based on the selected base image
    $imageBasePath = $imagePathBox.Text
    if (-not (Test-Path $imageBasePath)) {
        [System.Windows.Forms.MessageBox]::Show("❌ Base image not found at $imageBasePath", "Error", 'OK', 'Error')
        return
    }

    try {
        $baseImage = [System.Drawing.Image]::FromFile($imageBasePath)
    } catch {
        [System.Windows.Forms.MessageBox]::Show("❌ Failed to load base image.", "Error", 'OK', 'Error')
        return
    }

    $outputs = @(
        @{ Path = "appimage/runelite.png"; Size = 128; Format = "Png" },
        @{ Path = "src/resources/main/net/runelite/launcher/runelite_128.png"; Size = 128; Format = "Png" },
        @{ Path = "src/resources/main/net/runelite/launcher/runelite_splash.png"; Size = 200; Format = "Png" },
        @{ Path = "innosetup/runelite_small.bmp"; Size = 55; Format = "Bmp" },
        @{ Path = "innosetup/runelite.ico"; Size = 128; Format = "Ico" },
        @{ Path = "native/src/win32/runelite.ico"; Size = 128; Format = "Ico" }
    )

    foreach ($out in $outputs) {
        $dir = Split-Path $out.Path
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        $resized = Resize-Image $baseImage $out.Size $out.Size
        switch ($out.Format) {
            "Png" {
                $resized.Save($out.Path, [System.Drawing.Imaging.ImageFormat]::Png)
            }
            "Bmp" {
                $resized.Save($out.Path, [System.Drawing.Imaging.ImageFormat]::Bmp)
            }
            "Ico" {
                Save-IconFile $resized $out.Path
            }
        }
        $resized.Dispose()
    }
    $baseImage.Dispose()

    [System.Windows.Forms.MessageBox]::Show("✅ Properties saved and images/icons generated successfully!", "Success", 'OK', 'Information')
})


$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void] $form.ShowDialog()