;; Membership Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-member (err u101))
(define-constant err-already-member (err u102))
(define-constant err-invalid-role (err u103))

;; Data Variables
(define-data-var member-count uint u0)

;; Data Maps
(define-map members principal { role: (string-ascii 20) })

;; Public Functions

;; Add a new member
(define-public (add-member (new-member principal) (role (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (map-get? members new-member)) err-already-member)
    (asserts! (or (is-eq role "basic") (is-eq role "admin")) err-invalid-role)
    (map-set members new-member { role: role })
    (var-set member-count (+ (var-get member-count) u1))
    (ok true)
  )
)

;; Remove a member
(define-public (remove-member (member principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-some (map-get? members member)) err-not-member)
    (map-delete members member)
    (var-set member-count (- (var-get member-count) u1))
    (ok true)
  )
)

;; Change member role
(define-public (change-role (member principal) (new-role (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-some (map-get? members member)) err-not-member)
    (asserts! (or (is-eq new-role "basic") (is-eq new-role "admin")) err-invalid-role)
    (map-set members member { role: new-role })
    (ok true)
  )
)

;; Read-only Functions

;; Check if a principal is a member
(define-read-only (is-member (account principal))
  (is-some (map-get? members account))
)

;; Get member role
(define-read-only (get-role (account principal))
  (get role (default-to { role: "none" } (map-get? members account)))
)

;; Get total member count
(define-read-only (get-member-count)
  (var-get member-count)
)

;; Initialize contract
(begin
  (map-set members contract-owner { role: "admin" })
  (var-set member-count u1)
)

