-- e.g. osascript rm_folder.applescript <folder>
-- e.g. osascript rm_folder.applescript <parent_folder> <child_folder>

on run argv
    set parentFolder to item 1 of argv
    set childFolder to missing value
    set deleteType to "all"
    repeat with i from 2 to count of argv
        if item i of argv is "--only-notes" then
            set deleteType to "only-notes"
        else if childFolder is missing value then
            set childFolder to item i of argv
        end if
    end repeat
    try
        tell application "Notes"
            if childFolder is not missing value then
                if (exists folder parentFolder) then
                    if (exists folder childFolder of folder parentFolder) then
                        if deleteType is equal to "only-notes" then
                            if exists notes of folder childFolder then
                                delete notes of folder childFolder
                            end if
                        else
                            delete folder childFolder
                        end if
                        return "success"
                    else
                        return "error-none-child-folder"
                    end if
                else
                    return "error-none-folder"
                end if
            else
                if (exists folder parentFolder) then
                    if deleteType is equal to "only-notes" then
                        if exists notes of folder parentFolder then
                            delete notes of folder parentFolder
                        end if
                    else
                        delete folder parentFolder
                    end if
                    return "success"
                else
                    return "error-none-folder"
                end if
            end if
        end tell
    end try
end run
