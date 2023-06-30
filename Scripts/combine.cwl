cwlVersion: v1.0
class: Workflow
inputs: []
outputs:
  out:
    type: File
    outputSource: step1/example_out
  res:
    type: File
    outputSource: step2/example_out
steps:
  step1:
    run: test.cwl
    in: []
    out: [example_out]
  step2:
    run: version.cwl
    in: []
    out: [example_out]

