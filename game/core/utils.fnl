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

{ : pprint : find : map : pair-eq }
