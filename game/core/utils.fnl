(local fennel (require :fennel))

(fn pprint [obj]
  "pretty prints objects"
  (print (fennel.view obj)))

(fn render [obj]
  "calls an objects render method"
  (obj:render))

(fn new [class ...]
  "calls `Class:new ...` to create instance of an table"
  (class:new ...))

{: pprint : render : new}
