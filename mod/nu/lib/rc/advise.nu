# advise
let ___x_cmd_advise_run_nu = {|spans|
  let alias_check = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

  let spans = (if $alias_check != null  {
    let first_word = $alias_check | split row " " | get 0
    $spans | skip 1 | prepend $first_word
  } else {
    $spans
  })

  x advise complete nu ...$spans | from json
}

mut current = (($env | default {} config).config | default {} completions)
$current.completions = ($current.completions | default {} external)
$current.completions.external = ($current.completions.external | default true enable | default $___x_cmd_advise_run_nu completer)
$env.config = $current
