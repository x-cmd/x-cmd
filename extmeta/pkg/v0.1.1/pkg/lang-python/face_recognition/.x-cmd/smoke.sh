# shellcheck    shell=dash
if ! face_recognition --help 2>&1;then
  pkg:error "fail to get version"
  return 1
fi
