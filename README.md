# Disabled Users License Report

This PowerShell script retrieves all disabled users from Microsoft 365 and their assigned licenses, providing both a detailed report and summary.

## Features

- Retrieves disabled Microsoft 365 users
- Lists assigned licenses for each user
- Formats license names for better readability
- Outputs results to console and CSV file
- Automatically installs required Microsoft Graph modules

## Requirements

The script requires these PowerShell modules:
- Microsoft.Graph.Authentication
- Microsoft.Graph.Users  
- Microsoft.Graph.Identity.DirectoryManagement

These modules will be automatically installed if missing.

## Usage

Run the script with:

```powershell
.\disabledUsers-Licenses-Report.ps1
```

### Output

- Console display of:
  - Detailed user licenses
  - Summary of license counts
- CSV file with detailed results (saved in script directory with timestamp)

### Example Output

```text
Disabled Users and Their Licenses:

DisplayName          UserPrincipalName       LicenseName               SkuPartNumber
-----------          -----------------       -----------               ------------
John Doe             john@contoso.com        Microsoft 365 E5         SPE_E5
Jane Smith           jane@contoso.com        Power BI Pro             POWER_BI_STANDARD

License Summary:

Microsoft 365 E5: 1 users
Power BI Pro: 1 users
```

## License

BSD License - See [LICENSE](LICENSE)

## Author

Edward Crotty
