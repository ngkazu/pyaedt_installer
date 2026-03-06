# pyaedt_installer

This repository contains scripts to install PyAEDT using either a Batch file or a PowerShell script. These scripts automate the setup of a Python virtual environment and the installation of the required dependencies.

## Prerequisites

- Ensure that ANSYS Electronics Desktop is installed on your system.
- The environment variable `ANSYSEM_ROOTxxx` (where `xxx` is the version number) must be set.
- Python 3.10 (included with ANSYS) is required.

## Usage

### Batch Script

1. Open a Command Prompt.
2. Navigate to the directory containing `pyaedt_installer.bat`.
3. Run the script:
   ```
   pyaedt_installer.bat
   ```
4. The script will:
   - Detect the highest version of `ANSYSEM_ROOTxxx`.
   - Verify that the version is 232 or higher.
   - Create a Python virtual environment in `%APPDATA%\.pyaedt_env\3_10`.
   - Install PyAEDT and its dependencies.

### PowerShell Script

1. Open a PowerShell terminal.
2. Navigate to the directory containing `pyaedt_installer.ps1`.
3. Run the script:
   ```powershell
   powershell -ExecutionPolicy Bypass -File pyaedt_installer.ps1
   ```
4. The script will:
   - Detect the highest version of `ANSYSEM_ROOTxxx`.
   - Verify that the version is 232 or higher.
   - Create a Python virtual environment in `$env:APPDATA\.pyaedt_env\3_10`.
   - Install PyAEDT and its dependencies.

## Notes

- If the detected `ANSYSEM_ROOTxxx` version is less than 232, the script will terminate with an error message.
- Ensure that the required permissions are available to create directories and install Python packages.

## Troubleshooting

- If the script cannot find `ANSYSEM_ROOTxxx`, ensure that ANSYS Electronics Desktop is properly installed and the environment variables are set.
- For PowerShell, ensure that the execution policy allows running scripts. Use `Set-ExecutionPolicy` to modify it if necessary.

## License

This project is licensed under the MIT License.
