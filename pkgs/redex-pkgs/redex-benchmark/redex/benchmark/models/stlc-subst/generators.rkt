#lang racket/base

(require redex/examples/stlc+lists+subst
         (only-in redex/private/generate-term pick-an-index)
         redex/reduction-semantics
         racket/bool)

(provide (all-defined-out))

(module+ adhoc-mod
  (provide generate get-generator type)
  (define (get-generator) generate)
  (define type 'grammar)
  (define (generate)
    (generate-term stlc M 5)))

(module+ enum-mod
  (provide generate get-generator type)
  (define (get-generator) generate)
  (define type 'enum)
  (define (generate [p-value 0.035])
    (generate-term stlc M #:i-th (pick-an-index p-value))))

(module+ ordered-mod
  (provide generate get-generator type)
  (define (get-generator)
    (let ([index 0])
      (λ () (begin0
              (generate index)
              (set! index (add1 index))))))
  (define type 'ordered)
  (define (generate [index 0])
    (generate-term stlc M #:i-th index)))

(module+ check-mod
  (provide check)
  (define (check term)
    (or (not term)
        (v? term)
        (let ([t-type (type-check term)])
          (implies
           t-type
           (let ([red-res (apply-reduction-relation red term)])
             (and (= (length red-res) 1)
                  (let ([red-t (car red-res)])
                    (or (equal? red-t "error")
                        (let ([red-type (type-check red-t)])
                          (equal? t-type red-type)))))))))))
