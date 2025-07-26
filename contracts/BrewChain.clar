;; BrewChain: Brewing and Fermentation Mastery Reward System
;; Version: 1.0.0

;; Constants
(define-constant BREWERY_CAPACITY u1800000)
(define-constant BASE_BREW_REWARD u22)
(define-constant FERMENTATION_BONUS u8)
(define-constant MAX_BREWER_LEVEL u12)
(define-constant ERR_INVALID_BREW_ACTIVITY u1)
(define-constant ERR_NO_BREW_TOKENS u2)
(define-constant ERR_BREWERY_CAPACITY_EXCEEDED u3)
(define-constant BLOCKS_PER_BREW_SEASON u1728)
(define-constant YEAST_PRESERVATION_MULTIPLIER u4)
(define-constant MIN_PRESERVATION_PERIOD u864)
(define-constant EARLY_BREW_PENALTY u15)

;; Data Variables
(define-data-var total-brew-tokens-distributed uint u0)
(define-data-var total-brew-activities uint u0)
(define-data-var brewery-supervisor principal tx-sender)

;; Data Maps
(define-map brewer-activities principal uint)
(define-map brewer-brew-tokens principal uint)
(define-map brew-activity-start-time principal uint)
(define-map brewer-fermentation-level principal uint)
(define-map brewer-last-activity principal uint)
(define-map brewer-preserved-yeast principal uint)
(define-map brewer-preservation-start-block principal uint)

;; Public Functions
(define-public (start-brew-activity (fermentation-time uint))
  (let
    (
      (brewer tx-sender)
    )
    (asserts! (> fermentation-time u0) (err ERR_INVALID_BREW_ACTIVITY))
    (map-set brew-activity-start-time brewer burn-block-height)
    (ok true)
  ))

(define-public (complete-brew-batch (fermentation-time uint))
  (let
    (
      (brewer tx-sender)
      (start-block (default-to u0 (map-get? brew-activity-start-time brewer)))
      (blocks-brewing (- burn-block-height start-block))
      (last-activity-block (default-to u0 (map-get? brewer-last-activity brewer)))
      (fermentation-level (default-to u0 (map-get? brewer-fermentation-level brewer)))
      (capped-fermentation (if (<= fermentation-level MAX_BREWER_LEVEL) fermentation-level MAX_BREWER_LEVEL))
      (brew-reward (+ BASE_BREW_REWARD (* capped-fermentation FERMENTATION_BONUS)))
    )
    (asserts! (and (> start-block u0) (>= blocks-brewing fermentation-time)) (err ERR_INVALID_BREW_ACTIVITY))
    
    (map-set brewer-activities brewer (+ (default-to u0 (map-get? brewer-activities brewer)) u1))
    (map-set brewer-brew-tokens brewer (+ (default-to u0 (map-get? brewer-brew-tokens brewer)) brew-reward))
    
    (if (< (- burn-block-height last-activity-block) BLOCKS_PER_BREW_SEASON)
      (map-set brewer-fermentation-level brewer (+ fermentation-level u1))
      (map-set brewer-fermentation-level brewer u1)
    )
    
    (map-set brewer-last-activity brewer burn-block-height)
    (var-set total-brew-activities (+ (var-get total-brew-activities) u1))
    (var-set total-brew-tokens-distributed (+ (var-get total-brew-tokens-distributed) brew-reward))
    
    (asserts! (<= (var-get total-brew-tokens-distributed) BREWERY_CAPACITY) (err ERR_BREWERY_CAPACITY_EXCEEDED))
    (ok brew-reward)
  ))

(define-public (claim-brew-rewards)
  (let
    (
      (brewer tx-sender)
      (token-balance (default-to u0 (map-get? brewer-brew-tokens brewer)))
    )
    (asserts! (> token-balance u0) (err ERR_NO_BREW_TOKENS))
    (map-set brewer-brew-tokens brewer u0)
    (ok token-balance)
  ))

;; Yeast Preservation Features
(define-public (preserve-yeast (amount uint))
  (let
    (
      (brewer tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_BREW_ACTIVITY))
    (asserts! (>= (var-get total-brew-tokens-distributed) amount) (err ERR_BREWERY_CAPACITY_EXCEEDED))
    
    (map-set brewer-preserved-yeast brewer amount)
    (map-set brewer-preservation-start-block brewer burn-block-height)
    (var-set total-brew-tokens-distributed (- (var-get total-brew-tokens-distributed) amount))
    (ok amount)
  ))

(define-public (release-preserved-yeast)
  (let
    (
      (brewer tx-sender)
      (preserved-amount (default-to u0 (map-get? brewer-preserved-yeast brewer)))
      (preservation-start-block (default-to u0 (map-get? brewer-preservation-start-block brewer)))
      (blocks-preserved (- burn-block-height preservation-start-block))
      (penalty (if (< blocks-preserved MIN_PRESERVATION_PERIOD) (/ (* preserved-amount EARLY_BREW_PENALTY) u100) u0))
      (final-amount (- preserved-amount penalty))
    )
    (asserts! (> preserved-amount u0) (err ERR_NO_BREW_TOKENS))
    
    (map-set brewer-preserved-yeast brewer u0)
    (map-set brewer-preservation-start-block brewer u0)
    (var-set total-brew-tokens-distributed (+ (var-get total-brew-tokens-distributed) final-amount))
    (ok final-amount)
  ))

;; Read-Only Functions
(define-read-only (get-brew-activity-count (user principal))
  (default-to u0 (map-get? brewer-activities user)))

(define-read-only (get-brew-token-balance (user principal))
  (default-to u0 (map-get? brewer-brew-tokens user)))

(define-read-only (get-fermentation-level (user principal))
  (default-to u0 (map-get? brewer-fermentation-level user)))

(define-read-only (get-brewery-stats)
  {
    total-brew-activities: (var-get total-brew-activities),
    total-brew-tokens-distributed: (var-get total-brew-tokens-distributed)
  })

;; Private Functions
(define-private (is-brewery-supervisor)
  (is-eq tx-sender (var-get brewery-supervisor)))