-- 添加备忘录到指定父文件夹的子文件夹
-- osascript add_note_in_child_folder.applescript <parent_folder> <child_folder> <note>
on run argv
    set theFolder to item 1 of argv
    set theChildFolder to item 2 of argv
    set theNote to item 3 of argv
    try
        tell application "Notes"
            if (exists folder theFolder) then
                if (exists folder theChildFolder of folder theFolder) then
                    if (exists note named theNote of folder theChildFolder in folder theFolder) then
                        return "error-exists-note"
                    else
                        make new note of folder theChildFolder in folder theFolder with properties {name:theNote}
                        return "success"
                    end if
                else
                    make new folder at folder theFolder with properties {name:theChildFolder}
                    make new note of folder theChildFolder in folder theFolder with properties {name:theNote}
                    return "success"
                end if
            else
                make new folder with properties {name:theFolder}
                make new folder at folder theFolder with properties {name:theChildFolder}
                make new note of folder theChildFolder in folder theFolder with properties {name:theNote}
                return "success"
            end if
        end tell
    end try
end run
