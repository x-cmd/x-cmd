-- e.g. osascript rm_note_in_folder.applescript <folder> <note>

on run argv
    set theFolder to item 1 of argv
    set theNote to item 2 of argv
    try
        tell application "Notes"
            if (exists folder theFolder) then
                if not (exists note named theNote in folder theFolder) then
                    return "error-none-note"
                else
                    delete first note in folder theFolder whose name is theNote
                    return "success"
                end if
            else
                return "error-none-folder"
            end if
        end tell
    end try
end run
