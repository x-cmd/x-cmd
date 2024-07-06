
def t:
  def t_arr:
    if      length == 0 then []  # @2021
    else [reduce .[] as $item (null; typeUnion(.; $item|typeof))]
    end ;
  def t_obj:
    reduce keys[] as $key ( . ; .[$key] |= typeof ) ;
