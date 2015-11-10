(in-package :arfe.dc-ds-eq)

(defun equivalence-classes (list &key (test #'eql) (key #'identity))
  (labels ((rec (list classes)
             (cond ((null list)
                    (nreverse (mapcar (compose #'nreverse #'cdr) classes)))
                   (t
                    (if-let ((class (find (car list) classes
                                          :key #'second
                                          :test (lambda (a b)
                                                  (funcall test
                                                           (funcall key a)
                                                           (funcall key b))))))
                      (rplacd class
                              (cons (car list) (cdr class)))
                      (push (list nil (car list)) classes))
                    (rec (cdr list) classes)))))
    (rec list nil)))

(declaim (inline eqv))
(defun eqv (a b)
  (eql (not a) (not b)))

(defun find-semantic (semantic)
  (ecase semantic
    (:co #'complete-extension-p)
    (:pr #'preferred-extension-p)
    (:gr #'grounded-extension-p)
    (:st #'stable-extension-p)))

(defun find-task (task)
  (ecase task
    (:ds #'every)
    (:dc #'some)))

(defun sub-dc-ds-eq (argument task-a task-b
                     extensions-a extensions-b)
  (let ((member-argument (curry #'member argument)))
    (eqv
     (funcall (find-task task-a) member-argument extensions-a)
     (funcall (find-task task-b) member-argument extensions-b))))

(defun dc-ds-eq (problem-a problem-b graph)
  (bind ((arguments (nodes graph))
         (argument-sets (powerset arguments))
         ((task-a sem-a) problem-a)
         ((task-b sem-b) problem-b)
         (extensions-a (remove-if-not (curry (find-semantic sem-a) graph)
                                      argument-sets))
         (extensions-b (remove-if-not (curry (find-semantic sem-b) graph)
                                      argument-sets)))
    (every (lambda (argument)
             (sub-dc-ds-eq argument task-a task-b
                           extensions-a extensions-b))
           arguments)))

(defun estimate-dc-ds-eq-classes
    (&optional
       (graphs (mapcar #'from-adj
                       (generate-non-isomorphic 3))))
  (labels ((mytest (a b)
             (every (curry #'dc-ds-eq a b)
                    graphs)))
    (equivalence-classes '((:dc :gr) (:ds :gr)
                           (:dc :co) (:ds :co)
                           (:dc :st) (:ds :st)
                           (:dc :pr) (:ds :pr))
                         :test #'mytest)))
