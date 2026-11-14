(import-macros {: init-require!} :mod)

(local hc (require :lib.HC))

(local require-mod! (init-require! :core.collisions))

(local {: find : pair-eq } (require-mod! :core.utils))

(fn new-circle [id x y size] 
    (let [c (hc.circle x y size) 
          _ (c:setId id)] 
            c))

(fn remove-circle [circle] (hc.remove circle))

(fn move-circle [circle dx dy] (circle:move dx dy))

(fn in-shape [shape x y] (shape:contains x y))

(fn all-collisions [shapes]
    (let [collisions {}]
        (each [_k shape (ipairs shapes)]
            (each [other _separating-vec (hc.collisions shape)]
                (let [pair [shape._id other._id] antipair [other._id shape._id]] 
                    (if (not (find (fn [p] (or (pair-eq p pair) (pair-eq p antipair))) collisions))
                        (table.insert collisions pair)))))
    collisions))

{ : new-circle : remove-circle : move-circle : in-shape : all-collisions }
