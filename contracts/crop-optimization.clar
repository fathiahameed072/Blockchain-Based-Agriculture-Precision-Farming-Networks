;; Crop Optimization Contract
;; Optimizes crop management decisions

(define-map crop-plans
  { plan-id: uint }
  {
    farmer-id: uint,
    crop-type: (string-ascii 50),
    planting-date: uint,
    expected-harvest: uint,
    irrigation-schedule: uint,
    fertilizer-amount: uint,
    status: (string-ascii 20)
  }
)

(define-map optimization-recommendations
  { recommendation-id: uint }
  {
    farmer-id: uint,
    plan-id: uint,
    recommendation-type: (string-ascii 50),
    description: (string-ascii 200),
    priority: uint,
    created-at: uint
  }
)

(define-data-var next-plan-id uint u1)
(define-data-var next-recommendation-id uint u1)

;; Create crop plan
(define-public (create-crop-plan
  (farmer-id uint)
  (crop-type (string-ascii 50))
  (planting-date uint)
  (expected-harvest uint)
  (irrigation-schedule uint)
  (fertilizer-amount uint)
)
  (let ((plan-id (var-get next-plan-id)))
    (map-set crop-plans
      { plan-id: plan-id }
      {
        farmer-id: farmer-id,
        crop-type: crop-type,
        planting-date: planting-date,
        expected-harvest: expected-harvest,
        irrigation-schedule: irrigation-schedule,
        fertilizer-amount: fertilizer-amount,
        status: "active"
      }
    )
    (var-set next-plan-id (+ plan-id u1))
    (ok plan-id)
  )
)

;; Add optimization recommendation
(define-public (add-recommendation
  (farmer-id uint)
  (plan-id uint)
  (recommendation-type (string-ascii 50))
  (description (string-ascii 200))
  (priority uint)
)
  (let ((recommendation-id (var-get next-recommendation-id)))
    (map-set optimization-recommendations
      { recommendation-id: recommendation-id }
      {
        farmer-id: farmer-id,
        plan-id: plan-id,
        recommendation-type: recommendation-type,
        description: description,
        priority: priority,
        created-at: block-height
      }
    )
    (var-set next-recommendation-id (+ recommendation-id u1))
    (ok recommendation-id)
  )
)

;; Update crop plan status
(define-public (update-plan-status (plan-id uint) (new-status (string-ascii 20)))
  (match (map-get? crop-plans { plan-id: plan-id })
    plan-data
    (begin
      (map-set crop-plans
        { plan-id: plan-id }
        (merge plan-data { status: new-status })
      )
      (ok true)
    )
    (err u1)
  )
)

;; Get crop plan
(define-read-only (get-crop-plan (plan-id uint))
  (map-get? crop-plans { plan-id: plan-id })
)

;; Get recommendation
(define-read-only (get-recommendation (recommendation-id uint))
  (map-get? optimization-recommendations { recommendation-id: recommendation-id })
)
