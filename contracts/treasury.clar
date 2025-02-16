;; Treasury Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-transfer-failed (err u102))

;; Data Variables
(define-data-var total-balance uint u0)

;; Public Functions

;; Deposit funds into the treasury
(define-public (deposit (amount uint))
  (begin
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set total-balance (+ (var-get total-balance) amount))
    (ok true)
  )
)

;; Withdraw funds from the treasury (only contract owner)
(define-public (withdraw (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= amount (var-get total-balance)) err-insufficient-balance)
    (try! (as-contract (stx-transfer? amount tx-sender recipient)))
    (var-set total-balance (- (var-get total-balance) amount))
    (ok true)
  )
)

;; Read-only Functions

;; Get the current balance of the treasury
(define-read-only (get-balance)
  (var-get total-balance)
)

;; Initialize contract
(begin
  (var-set total-balance u0)
)

