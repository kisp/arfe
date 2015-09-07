(defpackage :arfe.pl2af
  (:use :common-lisp :alexandria :argsem-soundness :graph :clpl)
  (:import-from :metabang.bind #:bind)
  (:export
   #:pl2af))

(defpackage :arfe.local-arfex
  (:use :common-lisp :alexandria :iterate)
  (:export
   #:generate-example
   #:generate-examples
   #:slow))

(defpackage :arfe.gtfl-output-graph
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot)
  (:export
   #:gtfl-output-graph
   #:gtfl-output-graphs))

(defpackage :arfe.generate-non-isomorphic
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot
   :lparallel)
  (:export #:generate-non-isomorphic))

(defpackage :arfe.good-example
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot
   :lparallel
	:arfe.generate-non-isomorphic
   :argsem-soundness)
  (:import-from :metabang.bind #:bind)
  (:export
   #:find-good-example
   #:good-example-p
   #:list-good-examples))

(defpackage :arfe.dot
  (:use :common-lisp :alexandria :graph :graph-dot)
  (:export
   #:print-af-to-dot
   #:print-af-to-dot-with-extension))

(defpackage :arfe.directg
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot)
  (:export
   #:map-directg-file))

(defpackage :arfe.dc-ds-eq
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot
   :lparallel
	:arfe.generate-non-isomorphic)
  (:import-from :metabang.bind #:bind)
  (:export
   #:dc-ds-eq
   #:equivalence-classes
   #:estimate-dc-ds-eq-classes))

(defpackage :arfe
  (:use
   :named-readtables
   :alexandria
   :arfe.dc-ds-eq
   :arfe.directg
   :arfe.dot
   :arfe.generate-non-isomorphic
   :arfe.good-example
   :arfe.gtfl-output-graph
   :arfe.pl2af
   :arfe.local-arfex
   :argsem-soundness
   :clpl
   :common-lisp
   :graph
   :graph-adj
   :graph-apx
   :graph-dot
   :graph-tgf
   :gtfl
   :lparallel
   :trivial-graph-canonization
   )
  #+sbcl(:import-from :sb-ext #:quit #:exit)
  (:export
   #:load-data
   #:list-data
   #:with-open-gzip-file))
