import std/os except execShellCmd
import std/strutils
import ../utils/shell_commands

type InstallationStatus = tuple[success: bool, message: string]

proc installJenv*(): InstallationStatus =
    when defined(windows):
        return (false, "jEnv is not supported on Windows")
    else:
        when defined(macosx):
            if execShellCmd("brew install jenv") == 0:
                discard execShellCmd("echo 'export PATH=\"$HOME/.jenv/bin:$PATH\"' >> ~/.zshrc")
                discard execShellCmd("echo 'eval \"$(jenv init -)\"' >> ~/.zshrc")
                return (true, "jEnv installed successfully. Please restart your terminal.")
        else: # Linux
            if execShellCmd("git clone https://github.com/jenv/jenv.git ~/.jenv") == 0:
                discard execShellCmd("echo 'export PATH=\"$HOME/.jenv/bin:$PATH\"' >> ~/.bashrc")
                discard execShellCmd("echo 'eval \"$(jenv init -)\"' >> ~/.bashrc")
                return (true, "jEnv installed successfully. Please restart your terminal.")
        return (false, "Failed to install jEnv")

proc installJabba*(): InstallationStatus =
    when defined(windows):
        let cmd = """
            powershell -NoProfile -ExecutionPolicy Bypass -Command "
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
                iwr -useb 'https://github.com/shyiko/jabba/raw/master/install.ps1' | iex;
            "
        """
        let result = execShellCmd(cmd)
        if result == 0:
            return (true, "Jabba installed successfully. Please restart your terminal to use jabba.")
    else:
        let result = execShellCmd("curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash && . ~/.jabba/jabba.sh")
        if result == 0:
            return (true, "Jabba installed successfully")
    return (false, "Failed to install Jabba")

proc ensureVersionManager*(): InstallationStatus =
    # Check if jabba is available in PATH using PowerShell's Get-Command
    when defined(windows):
        if execShellCmd("powershell -Command \"if (Get-Command jabba -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }\"") == 0:
            return (true, "Jabba is already installed")
    else:
        if execShellCmd("which jabba") == 0 or fileExists(getEnv("HOME") / ".jabba" / "bin" / "jabba"):
            return (true, "Jabba is already installed")
    
    # Try to install Jabba first
    let jabbaResult = installJabba()
    if jabbaResult.success:
        return jabbaResult

    # If Jabba fails and we're not on Windows, try jEnv
    when not defined(windows):
        return installJenv()
    
    return (false, "Could not install any version manager")
