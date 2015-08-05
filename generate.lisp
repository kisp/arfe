(defpackage :arfe.generate-non-isomorphic
  (:use :common-lisp :alexandria :argsem-soundness
   :graph-adj :trivial-graph-canonization :graph-apx :graph-tgf
   :graph :graph-dot
   :lparallel)
  (:export #:generate-non-isomorphic))

(in-package :arfe.generate-non-isomorphic)

(defun invoke-with-broken-list (list-size part-size fn)
  (LPARALLEL.COGNATE::WITH-PARTS list-size (ceiling list-size part-size)
    (loop
      while (LPARALLEL.COGNATE::NEXT-PART)
      do (funcall fn (loop for i from (LPARALLEL.COGNATE::PART-OFFSET)
                             below (+ (LPARALLEL.COGNATE::PART-OFFSET)
                                      (LPARALLEL.COGNATE::PART-SIZE))
                           collect i)
                  (+ (LPARALLEL.COGNATE::PART-OFFSET)
                     (LPARALLEL.COGNATE::PART-SIZE))))))

(defmacro do-broken-list (((var done) list-size part-size) &body body)
  `(invoke-with-broken-list ,list-size ,part-size (lambda (,var ,done) ,@body)))

(defun diagonal (order)
  (loop for i below order
        summing (expt 2 (+ (* order i) i))))

(defun generate-non-isomorphic (order &key (part-size 100000)
                                        irreflexive)
  (let ((diagonal (diagonal order)))
    (flet ((irreflexive-p (x)
             (zerop (logand diagonal x)))
           (doit (x)
             (list
              (trivial-graph-canonization:graph-canonization
               (graph-adj:from-adj (cons order x)))
              x)))
      (let ((hash (make-hash-table :test #'equal)))
        (let ((size (expt 2 (* order order))))
          (do-broken-list ((items done) size part-size)
            (when irreflexive
              (setq items (premove-if-not #'irreflexive-p items)))
            (loop for (key value) in (pmapcar #'doit items)
                  do (setf (gethash key hash) value))
            (format t "~10,1F % done. found ~D~%"
                    (* 100 (/ done size))
                    (hash-table-count hash))))
        hash))))

(defun write-hash-to-stream (hash order stream)
  (with-standard-io-syntax
    (maphash-values
     (lambda (value)
       (prin1 (cons order value) stream)
       (terpri stream))
     hash)))
