import sys
from pylint.lint import Run

code = sys.stdin.read()

# Run pylint on the code
results = Run([code], do_exit=False)

# Process and print the analysis results
for pylint_result in results.linter.stats['by_module'].values():
  for msg in pylint_result:
    print(msg)
