cwlVersion: v1.0
class: CommandLineTool
baseCommand:
- spades.py
- --version
stdout: res2.txt
inputs: []
outputs:
  example_out:
    type: stdout

