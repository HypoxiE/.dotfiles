(global-set-key (kbd "<left>")  (lambda () (interactive) (message "no arrows")))
(global-set-key (kbd "<right>") (lambda () (interactive) (message "no arrows")))
(global-set-key (kbd "<up>")    (lambda () (interactive) (message "no arrows")))
(global-set-key (kbd "<down>")  (lambda () (interactive) (message "no arrows")))

(load-theme 'doom-one t)

(setq-default tab-width 4)
(defun my/fix-tabs ()
  (setq tab-width 4))
(add-hook 'prog-mode-hook #'my/fix-tabs)
(setq-default indent-tabs-mode nil)

(require 'editorconfig)
(editorconfig-mode 1)

(add-hook 'python-mode-hook
          (lambda ()
            (setq python-indent-offset 4)
            (setq python-indent-guess-indent-offset nil)
            ))

(add-hook 'yaml-mode-hook
          (lambda ()
            (setq tab-width 2)
            (setq indent-tabs-mode nil)))

(use-package nix-mode
  :mode "\\.nix\\'")
(use-package lsp-mode
  :hook
  (nix-mode . lsp-deferred))
(setq lsp-nix-nixd-server-path "nixd")
(use-package apheleia
  :config
  (setf (alist-get 'nix-mode apheleia-mode-alist)
        '(alejandra))

  (setf (alist-get 'alejandra apheleia-formatters)
        '("alejandra" "-"))

  :hook
  (nix-mode . apheleia-mode))


(vertico-mode 1)
(marginalia-mode 1)
(corfu-mode 1)

(require 'orderless)
(setq completion-styles
      '(basic partial-completion orderless))
(setq completion-category-overrides
      '((file (styles basic partial-completion orderless))))
(setq orderless-matching-styles
      '(orderless-literal
        orderless-prefixes
        orderless-initialism
        orderless-regexp))


(use-package markdown-mode
  :hook
  (markdown-mode . visual-line-mode))
