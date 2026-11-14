(local fennel (require :fennel))

(fn pprint [obj]
  "pretty prints objects"
  (print (fennel.view obj)))

{ : pprint }
