cwlVersion: v1.0
class: CommandLineTool
baseCommand:
- spades.py
- --test
stdout: res1.txt
inputs: []
outputs:
  example_out:
    type: stdout

