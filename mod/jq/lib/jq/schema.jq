module {
  "name": "schema",
  "description": "JSON Schema Inference",
  "version": "0.0.3.1",
  "homepage": "https://gist.github.com/pkoppstein/a5abb4ebef3b0f72a6ed",
  "license": "MIT",
  "author": "pkoppstein at gmail dot com"
};

def typeUnion($a; $b):

  def unionType: type == "array" and .[0] == "+" ;
  def nullable: $ARGS.named.nullable;
  def scalarp: . == "boolean" or . == "string" or . == "number" or . == "scalar";

  def addNull:
    if nullable then .
    elif unionType or . == "null" or . == "scalar" or . == "JSON" then .
    else ["+", "null", .]
    end;

  def addNull($x;$y): typeUnion($x;$y) | addNull;

  if   $a == null or $a == $b then $b
  elif $b == null then $a                        # @2021
  elif $a == "null" then $b | addNull
  elif $b == "null" then $a | addNull
  elif ($a|unionType) and ($b|unionType) then addNull($a[2];$b[2])
  elif $a|unionType then addNull($a[2]; $b)
  elif $b|unionType then addNull($a; $b[2])
  elif ($a | scalarp) and ($b | scalarp) then "scalar"
  elif $a == "JSON" or $b == "JSON" then "JSON"
  elif $a == [] then typeUnion($b; $a)           # @2021
  elif $b == [] and ($a|type) == "array" then $a # @2021
  elif ($a|type) == "array" and ($b|type) == "array" then [ typeUnion($a[0]; $b[0]) ]
  elif ($a|type) == "object" and ($b|type) == "object" then
    ((($a|keys) + ($b|keys)) | unique) as $keys
    | reduce $keys[] as $key ( {} ; .[$key] = typeUnion( $a[$key]; $b[$key]) )
  else "JSON"
  end ;

def typeof:
  def typeofArray:
    if length == 0 then []  # @2021
    else [reduce .[] as $item (null; typeUnion(.; $item|typeof))]
    end ;
  def typeofObject:
    reduce keys[] as $key ( . ; .[$key] |= typeof ) ;

  . as $in
  | type
  | if . == "null" then "null"
    elif . == "string" or . == "number" or . == "boolean" then .
    elif . == "object" then $in | typeofObject
    else $in | typeofArray
    end;

def schema(stream):
  reduce stream as $x (null; typeUnion(.; $x|typeof));

# Omit the outermost [] for an array
def schema:
  if type == "array" then schema(.[])
  else typeof
  end ;


