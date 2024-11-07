;extends

((string_content) @injection.content
 (#match? @injection.content "#include")
 (#set! injection.language "c"))

((string_content) @injection.content
 (#match? @injection.content "#ifdef")
 (#set! injection.language "c"))

((string_content) @injection.content
 (#match? @injection.content "#ifndef")
 (#set! injection.language "c"))

((string_content) @injection.content
 (#match? @injection.content "__global__")
 (#set! injection.language "cuda"))

((string_content) @injection.content
 (#match? @injection.content "__device__")
 (#set! injection.language "cuda"))

((string_content) @injection.content
 (#match? @injection.content "__host__")
 (#set! injection.language "cuda"))

