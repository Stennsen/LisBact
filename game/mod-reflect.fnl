(fn get-dependencies [mn] 
    (let [deps (. _G.mods-loaded mn)] (if deps deps {})))

(fn reset-dependencies [mn]
    (set (. _G.mods-loaded mn) {}))

{ : get-dependencies : reset-dependencies }