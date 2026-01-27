$jsonBlock = @'
  "paymentSettings": "Payment Management",
  "noAccounts": "No saved accounts",
  "addAccount": "Add Account",
  "deleteAccountTitle": "Delete Account",
  "deleteAccountContent": "Do you want to delete \"{alias}\"?",
  "deleteAction": "Delete",
  "newAccount": "New Account",
  "editAccount": "Edit Account",
  "aliasLabel": "Alias (Identity Name)",
  "bankLabel": "Bank",
  "ciLabel": "ID / RIF",
  "phoneLabel": "Phone",
  "accountNumberLabel": "Account Number (20 digits)",
  "pagoMovil": "Mobile Payment",
  "bankTransfer": "Transfer",
  "requiredField": "Required field",
  "selectBank": "Select a bank",
  "onlyAmount": "Text Only / Amount",
  "configureAccounts": "Configure Accounts",
  "configureAccountsDesc": "Add your data to share fast",
  "yourAccounts": "YOUR ACCOUNTS",
  "manageAccounts": "Manage Accounts",
  "transferData": "Transfer Data",
  "nameLabel": "Name",
  "accountLabel": "Account"
}
'@

$path = "lib/l10n"
$files = Get-ChildItem "$path/app_*.arb" | Where-Object { $_.Name -ne "app_es.arb" -and $_.Name -ne "app_en.arb" }

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        # Remove empty lines and trailing spaces at end
        $content = $content.TrimEnd()
        # Remove last closing brace
        if ($content.EndsWith("}")) {
            $content = $content.Substring(0, $content.Length - 1)
        }
        # Add comma if needed (check last non-space char)
        $trimmedContent = $content.TrimEnd()
        if (-not $trimmedContent.EndsWith(",") -and -not $trimmedContent.EndsWith("{")) {
            $content += ","
        }
        
        $newContent = $content + "`n" + $jsonBlock
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        Write-Host "Updated $($file.Name)"
    } catch {
        Write-Error "Error updating $($file.Name): $_"
    }
}
