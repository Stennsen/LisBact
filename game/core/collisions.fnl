(local hc (require :lib.HC))

(fn new-circle [id x y size] 
    (let [c (hc.circle x y size) 
          _ (c:setId id)] 
            c))

(fn remove-circle [circle] (hc.remove circle))

(fn move-circle [circle dx dy] (circle:move dx dy))

(fn in-shape [shape x y] (shape:contains x y))

{ : new-circle : remove-circle : move-circle : in-shape }
