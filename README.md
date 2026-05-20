# GodotStarterTemplate.NET
Starter template for Godot projects in .NET.

## Initialize this project

From the repo root, run the PowerShell script from the `Scripts` folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Scripts\InitializeProject.ps1
```

Or run the batch wrapper with the new project name:

```bat
Scripts\InitializeProject.bat MyGame
```

If you want to provide the new name interactively, run the PowerShell script without parameters and type the new name when prompted.

### VS Code task

Use the configured task in `.vscode/tasks.json`:

- `Initialize Godot Template`

This runs `Scripts\InitializeProject.ps1` from the workspace root.
