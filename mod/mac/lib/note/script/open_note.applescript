-- 打开指定名称的备忘录
-- osascript open_note.applescript <keyword>
on run argv
    set noteName to item 1 of argv
    try
        tell application "Notes"
            set noteList to notes whose name contains noteName
            if (count of noteList) > 0 then
                show (first item of noteList)
                activate
                return "success"
            else
                return "error-none-note"
            end if
        end tell
    end try
end run
