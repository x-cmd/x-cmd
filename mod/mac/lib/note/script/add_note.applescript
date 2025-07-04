-- e.g. osascript add_note.applescript <note>

on run argv
    set theNote to item 1 of argv
    try
        tell application "Notes"
            if not (exists note named theNote) then
                make new note with properties {name:theNote}
                return "success"
            else
                return "error-exists-note"
            end if
        end tell
    end try
end run
