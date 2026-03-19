-- e.g. osascript rm_note.applescript <note>

on run argv
    set theNote to item 1 of argv
    try
        tell application "Notes"
            set matchedNotes to notes whose name is theNote
            if (count of matchedNotes) > 0 then
                delete (first item of matchedNotes)
                return "success"
            else
                return "error-none-note"
            end if
        end tell
    end try
end run
