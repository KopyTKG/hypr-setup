function mkcomp --description 'Scaffold a React component: mkcomp <Name> [dir]'
    set -l name $argv[1]
    set -l dir $argv[2]
    test -z "$dir"; and set dir .
    command mkdir -p "$dir/$name"
    printf "import React from 'react';\nimport './%s.css';\n\ninterface %sProps {}\n\nexport const %s: React.FC<%sProps> = () => {\n  return (\n    <div className=\"%s\">\n      <h1>%s Component</h1>\n    </div>\n  );\n};\n" \
        $name $name $name $name $name $name >"$dir/$name/$name.tsx"
    touch "$dir/$name/$name.css"
    echo "Component $name created in $dir/$name"
end
