(local hc (require :lib.HC))

(fn new-circle [x y size] (hc.circle x y size))

(fn remove-circle [circle] (hc.remove circle))

(fn move-circle [circle dx dy] (circle:move dx dy))

(fn shapes-at [x y] (hc.shapesAt x y))

{ : new-circle : remove-circle : move-circle : shapes-at }
