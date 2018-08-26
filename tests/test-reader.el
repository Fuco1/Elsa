;; -*- lexical-binding: t -*-

(require 'elsa-reader)

(require 'elsa-test-helpers)

(describe "Elsa reader"

  (describe "symbols"

    (it "should read a symbol"
      (elsa-test-with-buffer "| foo"
        (let ((form (elsa-read-form)))
          (expect (elsa-form-symbol-p form) :to-be-truthy)
          (expect (oref form name) :to-be 'foo)
          (expect (oref form start) :to-be 2)
          (expect (oref form end) :to-be 5)))))

  (describe "improper lists"

    (it "should read a simple cons pair"
      (elsa-test-with-read-form "|(a . b)" form
        (expect (elsa-form-improper-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a . b)")))

    (it "should read an improper list containgin a quote."
      (elsa-test-with-read-form "|(a . (quote . c))" form
        (expect (elsa-form-improper-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a quote . c)")))

    (it "should read an expanded improper list"
      (elsa-test-with-read-form "|(a . (b . (c . d)))" form
        (expect (elsa-form-improper-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b c . d)")))

    (it "should read an improper list containing a cons pair"
      (elsa-test-with-read-form "|(a . (b . ((c . d) . e)))" form
        (expect (elsa-form-improper-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b (c . d) . e)"))))

  (describe "lists"

    (it "should read a list written in dot notation"
      (elsa-test-with-read-form "(a . (b))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b)")))

    (it "should read a list with a list cdr in dot notation"
      (elsa-test-with-read-form "(a . ((b)))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a (b))")))

    (it "should read a list with a cons pair in the middle"
      (elsa-test-with-read-form "(a . ((b . c) d))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a (b . c) d)")))

    (it "should read a list split in a head and a dotted cdr which is a list"
      (elsa-test-with-read-form "(a b . (c d))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b c d)")))

    (it "should"
      (elsa-test-with-read-form "(a . ((b) (x)))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a (b) (x))")))

    (it "should read a short proper list in dotted notation"
      (elsa-test-with-read-form "(a . (b . nil))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b)")))

    (it "should"
      (elsa-test-with-read-form "(a . ((b . nil)))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a (b))")))

    (it "should"
      (elsa-test-with-read-form "((((a . (b . nil)))))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "((((a b))))")))

    (it "should"
      (elsa-test-with-read-form "(a . (b . ((c . nil) x)))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b (c) x)")))

    (it "should"
      (elsa-test-with-read-form "(a b c)" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b c)")))

    (it "should"
      (elsa-test-with-read-form "((a b c))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "((a b c))")))

    (it "should"
      (elsa-test-with-read-form "(((a b c)))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(((a b c)))")))

    (it "should read a long proper list in dotted notation"
      (elsa-test-with-read-form "(a . (b . (c . (d . nil))))" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(a b c d)")))

    (describe "with quoted cdr"


      (it "should read a dotted list with a quoted symbol in cdr"
        (elsa-test-with-read-form "|(foo . 'bar)" form
          (expect (elsa-form-list-p form) :to-be-truthy)
          (expect (elsa-form-print form) :to-equal "(foo quote bar)")))

      (it "should read a dotted list with an expanded quoted symbol in cdr"
        (elsa-test-with-read-form "|(foo . (quote bar))" form
          (expect (elsa-form-list-p form) :to-be-truthy)
          (expect (elsa-form-print form) :to-equal "(foo quote bar)")))

      (it "should read a dotted list with a quoted symbol in nested cdr"
        (elsa-test-with-read-form "|(foo . (quote . 'bar))" form
          (expect (elsa-form-list-p form) :to-be-truthy)
          (expect (elsa-form-print form) :to-equal "(foo quote quote bar)")))

      (it "should read a backquoted list with an unquoted symbol in cdr"
        (elsa-test-with-read-form "|`(foo . ,bar)" form
          (expect (elsa-form-list-p form) :to-be-truthy)
          (expect (elsa-form-print form) :to-equal "(` (foo , bar))")))

      (it "should read a list with an unquoted symbol in cdr"
        (elsa-test-with-read-form "|(foo . ,bar)" form
          (expect (elsa-form-list-p form) :to-be-truthy)
          (expect (elsa-form-print form) :to-equal "(foo , bar)")))

      (it "should read a list in dotted notation with expanded quoted last cdr"
        (elsa-test-with-read-form "(foo . (quote . (quote (bar baz))))" form
          (expect (elsa-form-list-p form) :to-be-truthy)
          (expect (elsa-form-print form) :to-equal "(foo quote quote (bar baz))")))

      (it "should read a list in dotted notation with quoted last cdr"
        (elsa-test-with-read-form "(foo . (quote . '(bar baz)))" form
          (expect (elsa-form-list-p form) :to-be-truthy)
          (expect (elsa-form-print form) :to-equal "(foo quote quote (bar baz))")))))


  (describe "quotes"

    (it "should read a quoted symbol"
      (elsa-test-with-read-form "|'foo" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-name form) :to-be 'quote)
        (expect (oref form quote-type) :to-be 'quote)))

    (it "should read an expanded quoted symbol"
      (elsa-test-with-read-form "|(quote foo)" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-name form) :to-be 'quote)
        (expect (oref form quote-type) :to-be 'quote)))

    (it "should read an expanded quoted symbol nested inside a list"
      (elsa-test-with-read-form "|(foo (quote foo) bar)" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(foo (quote foo) bar)")))

    (it "should read a quoted function"
      (elsa-test-with-read-form "|#'foo" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-name form) :to-be 'function)
        (expect (oref form quote-type) :to-be 'function)))

    (it "should read an expanded quoted function"
      (elsa-test-with-read-form "|(function foo)" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-name form) :to-be 'function)
        (expect (oref form quote-type) :to-be 'function)))

    (it "should read an expanded quoted function nested inside a list"
      (elsa-test-with-read-form "|(foo (function foo) bar)" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-print form) :to-equal "(foo (function foo) bar)")))

    (it "should read an unquoted symbol"
      (elsa-test-with-read-form "|,foo" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-name form) :to-be '\,)
        (expect (oref form quote-type) :to-be '\,)))

    (it "should read a backquoted symbol"
      (elsa-test-with-read-form "|`foo" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-name form) :to-be '\`)
        (expect (oref form quote-type) :to-be '\`)))

    (it "should read a spliced symbol"
      (elsa-test-with-read-form "|,@foo" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-name form) :to-be '\,@)
        (expect (oref form quote-type) :to-be '\,@)))

    (it "should read a list containing quoted nil"
      (elsa-test-with-read-form "|(foo 'nil)" form
        (expect (elsa-form-list-p form) :to-be-truthy)
        (expect (elsa-form-list-p (cadr (oref form sequence))) :to-be-truthy)))))
