;; Add to your config.lisp
(define-configuration browser ((theme (make-instance 'theme:theme
                                                    :dark-p t
                                                    :background-color "#1E1E2E" ;; Base
                                                    :on-background-color "#CDD6F4" ;; Text
                                                    :primary-color "#CBA6F7" ;; Lavender (example primary)
                                                    :on-primary-color "#1E1E2E"
                                                    :secondary-color "#9399B2" ;; Subtext0 (example secondary)
                                                    :on-secondary-color "#1E1E2E"
                                                    :accent-color "#F38BA0" ;; Maroon (example accent)
                                                    :on-accent-color "#1E1E2E"))))

