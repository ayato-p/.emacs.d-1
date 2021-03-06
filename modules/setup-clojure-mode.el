;;; setup-clojure-mode.el --- clojure-mode-settings

;;; Commentary:

;;; Code:

;; Clojure
(use-package clojure-mode
  :mode "\\.boot\\'"
  :config
  ;; custom indentations
  (define-clojure-indent
    (let-test-data 1)
    (fact :defn)
    (facts :defn))

  (use-package clojure-mode-extra-font-locking)

  (use-package midje-mode)

  ;; alignment
  ;; (setq clojure-align-forms-automatically t)
  (defun my/clojure-reindent-defun (&optional argument)
    (interactive "P")
    (if (or (paredit-in-string-p)
            (paredit-in-comment-p))
        (lisp-fill-paragraph argument)
      (paredit-preserving-column
        (save-excursion
          (let ((e (progn (end-of-defun) (point)))
                (b (progn (beginning-of-defun) (point))))
            (indent-region b e))))))

  (defun my/paredit-reindent-defun-advice (f &rest args)
    (if (derived-mode-p 'clojure-mode)
        (apply 'my/clojure-reindent-defun args)
      (apply f args)))

  (advice-add 'paredit-reindent-defun :around 'my/paredit-reindent-defun-advice)

  (use-package clj-refactor
    :diminish clj-refactor-mode
    :config
    (cljr-add-keybindings-with-prefix "C-c j")
    (setq cljr-eagerly-build-asts-on-startup nil)
    (setq cljr-populate-artifact-cache-on-startup nil)
    (setq cljr-favor-prefix-notation nil)

    (bind-keys :map clj-refactor-map
               ("M-r" . (lambda ()
                          (interactive)
                          (let (cljr-warn-on-eval)
                            (cljr-find-usages)))))

    (use-package smartrep
      :config
      (smartrep-define-key
          clj-refactor-map "C-c j c"
        '(("c" . cljr-cycle-coll)))
      (smartrep-define-key
          clj-refactor-map "C-c j e"
        '(("l" . cljr-expand-let)))

      (smartrep-define-key
          clj-refactor-map "C-c j t"
        '(("f" . cljr-thread-first-all)
          ("h" . cljr-thread)
          ("l" . cljr-thread-last-all)
          ("w" . cljr-unwind)
          ("a" . cljr-unwind-all)))

      (smartrep-define-key
          clj-refactor-map "C-c j u"
        '(("f" . cljr-thread-first-all)
          ("h" . cljr-thread)
          ("l" . cljr-thread-last-all)
          ("w" . cljr-unwind)
          ("a" . cljr-unwind-all)))))

  (use-package cider
    :config
    (setq nrepl-hide-special-buffers nil)
    (setq cider-repl-history-file (locate-user-emacs-file ".nrepl-history"))

    (use-package ac-cider
      :init
      (eval-after-load "auto-complete"
        '(progn (add-to-list 'ac-modes 'cider-mode)
                (add-to-list 'ac-modes 'cider-repl-mode))))

    (defun my/cider-mode-hook ()
      (rainbow-delimiters-mode 1)
      (eldoc-mode 1)
      (ac-flyspell-workaround)          ; ?
      (ac-cider-setup))

    (add-hook 'cider-mode-hook 'my/cider-mode-hook)
    (add-hook 'cider-repl-mode-hook 'my/cider-mode-hook)

    (defun my/cider-clj-eval (s)
      (with-current-buffer (cider-current-connection "clj")
        (cider-interactive-eval s)))

    (defun my/cider-namespace-refresh ()
      (interactive)
      (my/cider-clj-eval
       "(require 'clojure.tools.namespace.repl)(clojure.tools.namespace.repl/refresh)"))

    (defun my/cider-reload-project ()
      (interactive)
      (my/cider-clj-eval
       "(require 'alembic.still)(alembic.still/load-project)"))

    (defun my/cider-midje-run-autotest ()
      (interactive)
      (my/cider-clj-eval
       "(require 'midje.repl)(midje.repl/autotest)"))

    (defun my/cider-midje-stop-autotest ()
      (interactive)
      (my/cider-clj-eval
       "(midje.repl/autotest :stop)"))

    (defun my/cider-test-clear-last-results ()
      (interactive)
      (setq cider-test-last-results '(dict)))

    (defun my/cider-toggle-load-tests ()
      (interactive)
      (my/cider-clj-eval
       "(alter-var-root #'clojure.test/*load-tests* not)"))

    (defun my/zou-go ()
      (interactive)
      (if current-prefix-arg
          (progn
            (save-some-buffers)
            (my/cider-clj-eval
             "(zou.framework.repl/reset)"))
        (my/cider-clj-eval
         "(zou.framework.repl/go)")))

    (when my/use-ergonomic-key-bindings
      (bind-keys :map cider-mode-map
                 ("C-j" . nil)
                 ("s-;" . my/zou-go))
      (bind-keys :map cider-repl-mode-map
                 ("C-j" . nil)
                 ("s-;" . my/zou-go))))

  (defun my/clojure-mode-hook ()
    (add-hook 'before-save-hook 'my/cleanup-buffer nil t)
    (clj-refactor-mode 1)
    (paredit-mode 1)
    (rainbow-delimiters-mode 1)
    (prettify-symbols-mode 1))

  (add-hook 'clojure-mode-hook 'my/clojure-mode-hook))

;;; setup-clojure-mode.el ends here
