(require 'elsa-undercover)

(defmacro elsa-test-with-buffer (initial &rest body)
  (declare (indent 1))
  `(with-temp-buffer
     (emacs-lisp-mode)
     (insert ,initial)
     (goto-char (point-min))
     (when (search-forward "|" nil t)
       (delete-char -1))
     ,@body))

(defmacro elsa-test-with-read-form (initial form-var &rest body)
  (declare (indent 2))
  `(elsa-test-with-buffer ,initial
     (let ((,form-var (elsa-read-form)))
       ,@body)))

(defmacro elsa-test-with-analysed-form (initial form-var &rest body)
  (declare (indent 2))
  (let ((state (or (plist-get body :state-var) (make-symbol "state")))
        (errors (or (plist-get body :errors-var) (make-symbol "errors"))))
    `(elsa-test-with-buffer ,initial
       (let ((,form-var (elsa-read-form))
             (,state (elsa-state)))
         (elsa--analyse-form ,form-var (oref ,state scope) ,state)
         (let ((,errors (oref ,state errors)))
           ,@body)))))

(buttercup-define-matcher-for-binary-function :to-be-type-equivalent elsa-type-equivalent-p
  :expect-match-phrase "Expected %A to be equivalent to %B, was %a."
  :expect-mismatch-phrase "Expected %A to not to be equivalent to %B, was %a")

(provide 'elsa-test-helpers)
