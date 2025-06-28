-- 从指定父文件夹的子文件夹删除备忘录
-- osascript rm_note_in_child_folder.applescript <parent_folder> <child_folder> <note>
on run argv
    set theFolder to item 1 of argv
    set theChildFolder to item 2 of argv
    set theNote to item 3 of argv
    try
        tell application "Notes"
            if (exists folder theFolder) then
                if (exists folder theChildFolder of folder theFolder) then
                    if not (exists note named theNote of folder theChildFolder in folder theFolder) then
                        return "error-none-note"
                    else
                        delete first note of folder theChildFolder in folder theFolder whose name is theNote
                        return "success"
                    end if
                else
                    return "error-none-child-folder"
                end if
            else
                return "error-none-folder"
            end if
        end tell
    end try
end run
