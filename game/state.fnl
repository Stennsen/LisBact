;; a module that holds data across hot reloads

;; it's helpful to add fields you will set later even if they have no
;; initial value, both for documentation purposes and to help the linter.

{;; these are used by intro mode; replace them with whatever defaults you want
 :version nil :counter 0 :time 0

 ;; these are used by wrap.fnl; keep them
 :mode {} :mode-name nil}
