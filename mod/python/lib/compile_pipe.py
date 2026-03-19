import sys, os
import py_compile

code = sys.stdin.read()

# Create a temporary file with the code
temp_file = '123.456.789.__temp__.py'
compiled_file = '123.456.789.__temp__.pyc'
with open(temp_file, 'w') as f:
  f.write(code)

try:
  # Compile the temporary file to perform linting
  py_compile.compile(temp_file, cfile=compiled_file, doraise=True)
  print('No linting errors.')
except py_compile.PyCompileError as e:
  # print(f'Linting error: {e.msg}')
  print('Linting error:' + e.msg)
finally:
    os.remove(temp_file)
    os.remove(temp_file + "c")