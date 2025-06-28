-- 列出所有 Apple Notes 的备忘录
try
    tell application "Notes"
        set noteList to every note
        set noteNames to {}
        repeat with n in noteList
            set end of noteNames to name of n
        end repeat
        return noteNames
    end tell
end try
