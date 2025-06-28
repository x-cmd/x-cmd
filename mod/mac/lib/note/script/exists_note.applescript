-- 判断备忘录是否存在（支持文件夹/子文件夹）
-- osascript exists_note.applescript <note>
-- osascript exists_note.applescript <folder> <note>
-- osascript exists_note.applescript <parent_folder> <child_folder> <note>
on run argv
    set theFolder to missing value
    set theChildFolder to missing value
    set theNote to missing value
    if (count of argv) = 1 then
        set theNote to item 1 of argv
    else if (count of argv) = 2 then
        set theFolder to item 1 of argv
        set theNote to item 2 of argv
    else if (count of argv) = 3 then
        set theFolder to item 1 of argv
        set theChildFolder to item 2 of argv
        set theNote to item 3 of argv
    end if
    try
        tell application "Notes"
            if theFolder is not missing value and theChildFolder is not missing value then
                if (exists folder theFolder) then
                    if (exists folder theChildFolder of folder theFolder) then
                        if not (exists note named theNote of folder theChildFolder in folder theFolder) then
                            return "failure"
                        else
                            return "success"
                        end if
                    else
                        return "success"
                    end if
                else
                    return "success"
                end if
            else if theFolder is not missing value then
                if (exists folder theFolder) then
                    if (exists note named theNote in folder theFolder) then
                        return "success"
                    else
                        return "failure"
                    end if
                else
                    return "success"
                end if
            else if theNote is not missing value then
                if (exists note named theNote) then
                    return "success"
                else
                    return "failure"
                end if
            else
                return "error-none-params"
            end if
        end tell
    end try
end run
