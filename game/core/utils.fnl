(local fennel (require :lib.fennel))

(fn pprint [obj]
  "pretty prints objects"
  (print (fennel.view obj)))

(fn find [cnd tbl] 
  (var res nil)
  (each [_key value (ipairs tbl) &until res] 
    (if (cnd value) (set res value)))
  res)

{ : pprint : find }
