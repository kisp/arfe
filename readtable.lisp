;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package :arfe)

(defreadtable arfe
  (:merge :standard)
  (:dispatch-macro-char
   #\# #\?
   #'cl-interpol::interpol-reader))
