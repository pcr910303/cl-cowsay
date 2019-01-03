;;;; balloon.lisp

(defpackage #:cl-cowsay.balloon
  (:use #:cl)
  (:export #:say
           #:think))

(in-package #:cl-cowsay.balloon)

(defclass delimiters ()
  ((first :initarg :first :accessor del-first)
   (middle :initarg :middle :accessor del-middle)
   (last :initarg :last :accessor del-last)
   (only :initarg :only :accessor del-only)))

(defun make-delimiters (first middle last only)
  (make-instance 'delimiters
                 :first first
                 :middle middle
                 :last last
                 :only only))

(defun say (text wrap)
  (let ((delimiters (make-delimiters '("/" . "\\")
                                     '("|" . "|")
                                     '("\\" . "/")
                                     '("<" . ">"))))
    (format-balloon text wrap delimiters)))

(defun think (text wrap)
  (let ((delimiters (make-delimiters '("(" . ")")
                                     '("(" . ")")
                                     '("(" . ")")
                                     '("(" . ")"))))
    (format-balloon text wrap delimiters)))


(defun format-balloon (text wrap delimiters)
  (let* ((lines (split text wrap))
         (max-length (max-length lines))
         balloon)
    (if (null (rest lines))
        (setf balloon
              (list (concatenate 'string " " (top max-length))
                    (concatenate 'string (car (del-only delimiters)) " " (first lines) " " (cdr (del-only delimiters)))
                    (concatenate 'string " " (bottom max-length))))
        (setf balloon
              (append (list (concatenate 'string " " (top max-length)))
                      (loop :with len := (length lines)
                            :for index :from 0 :to len
                            :for line :in lines
                            :for delimiter := (del-first delimiters) :then (if (/= index (- len 1))
                                                                              (del-middle delimiters)
                                                                              (del-last delimiters))
                            :collect (concatenate 'string (car delimiter) " " (pad line max-length) " " (cdr delimiter)))
                      (list (concatenate 'string " " (bottom max-length))))))
    (join balloon)))

(defun join (strings)
  (format nil (concatenate 'string "~{~a~^" (make-string 1 :initial-element #\Newline) "~}") strings))

(defun split (text wrap)
  (loop :with start := 0 :while (< start (length text))
        :for next-newline := (position #\Newline text :start (+ start 1))
        :for wrap-at := (min (or next-newline (length text))
                             (+ start wrap))
        :collect (subseq text start wrap-at)
        :do
           (setf start wrap-at)
           (when (ignore-errors
                  (eql #\Newline (char text start)))
             (incf start))))

;; TODO
(defun string-width (&rest args)
  (apply #'length args))

(defun max-length (lines)
  (loop :for line :in lines
        :maximize (string-width line)))

(defun pad (text length)
  (concatenate 'string text (make-string (- length (length text)) :initial-element #\Space)))

(defun top (length)
  (make-string (+ length 2) :initial-element #\_))

(defun bottom (length)
  (make-string (+ length 2) :initial-element #\-))