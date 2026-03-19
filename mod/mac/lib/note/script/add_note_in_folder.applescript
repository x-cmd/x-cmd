-- e.g. osascript add_note_in_folder.applescript <folder> <note>

on run argv
    set theFolder to item 1 of argv
    set theNote to item 2 of argv
    try
        tell application "Notes"
            if (exists folder theFolder) then
                if not (exists note named theNote in folder theFolder) then
                    make new note at folder theFolder with properties {name:theNote}
                    return "success"
                else
                    return "error-exists-note"
                end if
            else
                make new folder with properties {name:theFolder}
                make new note at folder theFolder with properties {name:theNote}
                return "success"
            end if
        end tell
    end try
end run
