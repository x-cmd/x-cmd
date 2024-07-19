
# chat

fn l        { |@a| use x; x:x chat  --sendalias l           $@a ; }
fn lms      { |@a| use x; x:x chat  --sendalias lms         $@a ; }
fn o        { |@a| use x; x:x chat  --sendalias o           $@a ; }

fn gpt      { |@a| use x; x:x chat  --sendalias gpt         $@a ; }
fn gpt3     { |@a| use x; x:x chat  --sendalias gpt3        $@a ; }
fn gpt4     { |@a| use x; x:x chat  --sendalias gpt4        $@a ; }
fn gpt4t    { |@a| use x; x:x chat  --sendalias gpt4t       $@a ; }
fn gpt4om   { |@a| use x; x:x chat  --sendalias gpt4om      $@a ; }
fn gemini   { |@a| use x; x:x chat  --sendalias gemini      $@a ; }
fn mistral  { |@a| use x; x:x chat  --sendalias mistral     $@a ; }
fn kimi     { |@a| use x; x:x chat  --sendalias kimi        $@a ; }

# writer

fn en       { |@a| use x; x:x writer --sendalias en         $@a ; }
fn zh       { |@a| use x; x:x writer --sendalias zh         $@a ; }

# TODO
# var lang_code = ( re:replace "_[^$]+$" "" $E:LANG )

fn de       { |@a| use x; x:x writer --sendalias German     $@a ; }
fn es       { |@a| use x; x:x writer --sendalias Spanish    $@a ; }
fn fr       { |@a| use x; x:x writer --sendalias French     $@a ; }
fn ja       { |@a| use x; x:x writer --sendalias Japanese   $@a ; }
fn ko       { |@a| use x; x:x writer --sendalias Korean     $@a ; }
fn ua       { |@a| use x; x:x writer --sendalias Ukraine    $@a ; }
fn ru       { |@a| use x; x:x writer --sendalias Russian    $@a ; }
