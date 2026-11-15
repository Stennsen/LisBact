(import-macros {: init-require!} :mod)

(local hc (require :lib.HC))

(local require-mod! (init-require! :core.collisions))

(local {: find : pair-eq } (require-mod! :core.utils))

(fn new-circle [id x y size] 
    (let [c (hc.circle x y size) 
          _ (c:setMeta { :type :swarm : id })] 
            c))

(fn remove-circle [circle] (hc.remove circle))

(fn move-circle [circle dx dy] (circle:move dx dy))

(fn in-shape [shape x y] (shape:contains x y))

(fn collides-with [shape] (hc.collisions shape))

(fn get-meta [shape] (shape:getMeta))

{ : new-circle : remove-circle : move-circle : in-shape : collides-with : get-meta}
