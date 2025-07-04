-- e.g. osascript add_folder.applescript <folder>
-- e.g. osascript add_folder.applescript <parent_folder> <child_folder>

on run argv
    set parentFolderName to item 1 of argv
    set childFolderName to missing value
    if (count of argv) > 1 then
        set childFolderName to item 2 of argv
    end if
    try
        tell application "Notes"
            if childFolderName is not missing value then
                if (exists folder parentFolderName) then
                    if (exists folder childFolderName of folder parentFolderName) then
                        return "error-exists-folder"
                    else
                        make new folder at folder parentFolderName with properties {name:childFolderName}
                        return "success"
                    end if
                else
                    make new folder with properties {name:parentFolderName}
                    make new folder at folder parentFolderName with properties {name:childFolderName}
                    return "success"
                end if
            else
                if (exists folder parentFolderName) then
                    return "error-exists-folder"
                else
                    make new folder with properties {name:parentFolderName}
                    return "success"
                end if
            end if
        end tell
    end try
end run
