;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe.pl2af)

(defun sorted-powerset (list)
  (sort (copy-list (powerset list)) #'< :key #'length))

(defun formula-set-entails-p (formulas formula)
  (valid-enumerate-p `(imp (and ,@formulas) ,formula)))

(defun formula-set-consistent-p (formulas)
  (satisfiable-enumerate-p `(and ,@formulas)))

(defun negate-formula (formula)
  (simplify `(not ,formula)))

(defun add-negated-formulas (formulas)
  (remove-duplicates
   (append formulas
           (mapcar #'negate-formula formulas))
   :test #'formula-eqv))

(defun formula-eqv (a b)
  (valid-enumerate-p `(eqv ,a ,b)))

(defstruct argument
  name formulas conclusion)

(defun undercuts-p (a b)
  "Does argument a undercut argument b?"
  (find-if (lambda (x)
             (formula-eqv (argument-conclusion a)
                          (negate-formula x)))
           (argument-formulas b)))

(defun build-arguments-from-formulas (formulas)
  (let (arguments
        (counter 0))
    (labels ((get-name ()
               (intern (format nil "A~D" (incf counter))))
             (find-argument (conclusion)
               (find conclusion arguments :key #'argument-conclusion
                                          :test #'equal)))
      (let ((goals (add-negated-formulas formulas)))
        (dolist (xs (remove-if-not #'formula-set-consistent-p
                                   (cdr (sorted-powerset formulas))))
          (dolist (goal goals)
            (when (and (not (find-argument goal))
                       (formula-set-entails-p xs goal))
              (push (make-argument
                     :name (get-name)
                     :formulas xs :conclusion goal)
                    arguments))))))
    (nreverse arguments)))

(defun build-graph-from-arguments (arguments)
  (let ((graph (make-instance 'digraph)))
    (dolist (argument arguments)
      (add-node graph (argument-name argument)))
    (map-combinations
     (lambda (x)
       (bind (((a b) x))
         (when (undercuts-p a b)
           (add-edge graph (list (argument-name a) (argument-name b))))
         (when (undercuts-p b a)
           (add-edge graph (list (argument-name b) (argument-name a))))))
     arguments :length 2)
    graph))

(defun pl2af (formulas)
  (let ((arguments (build-arguments-from-formulas formulas)))
    (values (build-graph-from-arguments arguments)
            arguments)))
