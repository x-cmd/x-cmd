# lint.jq — validate rule.yml (as JSON) against meta-rule schema
# Input:  JSON object converted from a rule.yml file
# Output: array of {id, rule, level, hint}
#
# Usage:  jq -L <dir> 'include "lint"; lint'
#         jq -L <dir> 'include "lint"; lint_tsv'

def valid_levels: ["error", "must", "warn", "info", "debug"];

def known_fields: ["name", "apply", "level", "desc", "test-coverage", "tldr", "memo", "testcase", "setup", "teardown"];

def nonempty_string: type == "string" and length > 0;

def check_110($id; $rule):
  if ($rule | type) != "object" then
    {id: $id, rule: "meta-rule-110", level: "error", hint: "Rule value must be a mapping, got \($rule | type)"}
  else empty end;

def check_020($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($id | test("^[a-zA-Z0-9][a-zA-Z0-9_-]*$")) | not then
    {id: $id, rule: "meta-rule-020", level: "error", hint: "Invalid rule ID format: \($id)"}
  else empty end;

def check_030($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("desc") | not) then
    {id: $id, rule: "meta-rule-030", level: "error", hint: "Missing required field: desc"}
  elif ($rule.desc | type) != "array" then
    {id: $id, rule: "meta-rule-030", level: "error", hint: "desc must be a list, got \($rule.desc | type)"}
  elif ($rule.desc | length) == 0 then
    {id: $id, rule: "meta-rule-030", level: "error", hint: "desc list is empty"}
  else empty end;

def check_100($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("desc") | not) then empty
  elif ($rule.desc | type) != "array" then empty
  elif ($rule.desc | map(select(type != "string" or length == 0)) | length) > 0 then
    {id: $id, rule: "meta-rule-100", level: "warn", hint: "desc contains empty or non-string items"}
  else empty end;

def check_040($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("name") | not) then empty
  elif ($rule.name | nonempty_string) | not then
    {id: $id, rule: "meta-rule-040", level: "warn", hint: "name should be a non-empty string"}
  else empty end;

def check_050($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("apply") | not) then empty
  elif ($rule.apply | nonempty_string) | not then
    {id: $id, rule: "meta-rule-050", level: "warn", hint: "apply should be a non-empty string"}
  else empty end;

def check_060($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("level") | not) then empty
  elif ($rule.level | IN(valid_levels[])) | not then
    {id: $id, rule: "meta-rule-060", level: "error", hint: "level must be one of [error must warn info debug], got: \($rule.level)"}
  else empty end;

def check_070($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("tldr") | not) then empty
  elif ($rule.tldr | type) != "array" then
    {id: $id, rule: "meta-rule-070", level: "warn", hint: "tldr must be a list, got \($rule.tldr | type)"}
  else empty end;

def check_080($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("memo") | not) then empty
  elif ($rule.memo | type) != "array" then
    {id: $id, rule: "meta-rule-080", level: "info", hint: "memo should be a list, got \($rule.memo | type)"}
  else empty end;

def check_090($id; $rule):
  if ($rule | type) != "object" then empty
  else
    [ $rule | keys[] | select(IN(known_fields[]) | not) ] as $unknown |
    if ($unknown | length) > 0 then
      {id: $id, rule: "meta-rule-090", level: "warn", hint: ("Unknown field(s): " + ($unknown | join(", ")))}
    else empty end
  end;

# test-coverage must be integer 0-100
def check_120($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("test-coverage") | not) then empty
  elif ($rule["test-coverage"] | type) != "number" then
    {id: $id, rule: "meta-rule-120", level: "error", hint: "test-coverage must be a number, got: \($rule["test-coverage"] | type)"}
  elif ($rule["test-coverage"] | . < 0 or . > 100 or (. != floor)) then
    {id: $id, rule: "meta-rule-120", level: "error", hint: "test-coverage must be integer 0-100, got: \($rule["test-coverage"])"}
  else empty end;

# if testcase exists, test-coverage applies (default 100); warn if explicitly 0
def check_130($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("testcase") | not) then empty
  elif ($rule | has("test-coverage")) and ($rule["test-coverage"] == 0) then
    {id: $id, rule: "meta-rule-130", level: "warn", hint: "testcase exists but test-coverage is 0 — consider removing testcase or raising the value"}
  else empty end;

# testcase must be an object (mapping of named cases)
def check_140($id; $rule):
  if ($rule | type) != "object" then empty
  elif ($rule | has("testcase") | not) then empty
  elif ($rule.testcase | type) != "object" then
    {id: $id, rule: "meta-rule-140", level: "warn", hint: "testcase should be a mapping of named test cases, got \($rule.testcase | type)"}
  else empty end;

def lint:
  [ to_entries[] |
    .key as $id |
    .value as $rule |
    check_110($id; $rule),
    check_020($id; $rule),
    check_030($id; $rule),
    check_100($id; $rule),
    check_040($id; $rule),
    check_050($id; $rule),
    check_060($id; $rule),
    check_070($id; $rule),
    check_080($id; $rule),
    check_090($id; $rule),
    check_120($id; $rule),
    check_130($id; $rule),
    check_140($id; $rule)
  ];

def lint_tsv:
  lint | .[] | "\(.id)\t\(.rule)\t\(.level)\t\(.hint)";
