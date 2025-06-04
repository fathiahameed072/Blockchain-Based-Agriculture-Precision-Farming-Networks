;; Farmer Verification Contract
;; Validates and manages precision farming practitioners

(define-map farmers
  { farmer-id: uint }
  {
    wallet-address: principal,
    farm-name: (string-ascii 100),
    location: (string-ascii 100),
    farm-size: uint,
    verified: bool,
    registration-date: uint
  }
)

(define-map farmer-by-address
  { wallet-address: principal }
  { farmer-id: uint }
)

(define-data-var next-farmer-id uint u1)
(define-data-var contract-owner principal tx-sender)

;; Register a new farmer
(define-public (register-farmer (farm-name (string-ascii 100)) (location (string-ascii 100)) (farm-size uint))
  (let ((farmer-id (var-get next-farmer-id)))
    (asserts! (is-none (map-get? farmer-by-address { wallet-address: tx-sender })) (err u1))
    (map-set farmers
      { farmer-id: farmer-id }
      {
        wallet-address: tx-sender,
        farm-name: farm-name,
        location: location,
        farm-size: farm-size,
        verified: false,
        registration-date: block-height
      }
    )
    (map-set farmer-by-address { wallet-address: tx-sender } { farmer-id: farmer-id })
    (var-set next-farmer-id (+ farmer-id u1))
    (ok farmer-id)
  )
)

;; Verify a farmer (only contract owner)
(define-public (verify-farmer (farmer-id uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u2))
    (match (map-get? farmers { farmer-id: farmer-id })
      farmer-data
      (begin
        (map-set farmers
          { farmer-id: farmer-id }
          (merge farmer-data { verified: true })
        )
        (ok true)
      )
      (err u3)
    )
  )
)

;; Get farmer information
(define-read-only (get-farmer (farmer-id uint))
  (map-get? farmers { farmer-id: farmer-id })
)

;; Check if farmer is verified
(define-read-only (is-farmer-verified (farmer-id uint))
  (match (map-get? farmers { farmer-id: farmer-id })
    farmer-data (get verified farmer-data)
    false
  )
)

;; Get farmer ID by wallet address
(define-read-only (get-farmer-id-by-address (wallet-address principal))
  (map-get? farmer-by-address { wallet-address: wallet-address })
)
