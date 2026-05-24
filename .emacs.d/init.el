(global-set-key (kbd "<left>")  (lambda () (interactive) (message "no arrows")))
(global-set-key (kbd "<right>") (lambda () (interactive) (message "no arrows")))
(global-set-key (kbd "<up>")    (lambda () (interactive) (message "no arrows")))
(global-set-key (kbd "<down>")  (lambda () (interactive) (message "no arrows")))

(load-theme 'doom-one t)

(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)
