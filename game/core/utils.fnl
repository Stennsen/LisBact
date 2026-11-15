(local fennel (require :lib.fennel))

(fn pprint [obj]
  "pretty prints objects"
  (print (fennel.view obj)))

(fn find [cnd tbl]
  (var res nil)
  (each [_key value (ipairs tbl) &until res]
    (if (cnd value) (set res value)))
  res)

(fn map [mapper tbl]
  (icollect [_key value (ipairs tbl)] (mapper value)))

(fn pair-eq [[a1 b1] [a2 b2]] (and (= a1 b1) (= a2 b2)))

(fn car [cons]
  (. cons 1))

(fn cdr [cons]
  (. cons 2))

(fn foreach [func tbl]
  (each [_k v (ipairs tbl)] (func v)))

(fn unset [tbl & keywords]
  "takes a table and unsets the give &keywords for the returned table"
  (let [new-tbl {}]
    (each [k v (pairs tbl)]
      (when (not (find (fn [el] (= k el)) keywords))
        (tset new-tbl k v)))
    new-tbl))

(fn point-on-circle [x y rad angle]
  "returns the point [px py] on the circle around x/y with radius rad at angle (radians)"
  [(+ x (* rad (math.cos angle)))
   (+ y (* rad (math.sin angle)))])

(fn random-color [a]
  "returns a random color"
  [(math.random)
   (math.random)
   (math.random)
   (or a (math.random))])

{: pprint : find : map : pair-eq : car : cdr : unset : foreach : point-on-circle : random-color}
