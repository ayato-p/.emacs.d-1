;;; bootstrap.el

(eval-when-compile (require 'cl))

(when load-file-name
  (setq user-emacs-directory (expand-file-name
                              (file-name-directory load-file-name))))

;; Cask
(let ((cask-path
       (car (delq nil (mapcar (lambda (x) (and (file-exists-p x) x))
                              ;; Assume cask's location is one of the following:
                              '("/usr/local/share/emacs/site-lisp/cask.el"
                                "/usr/local/share/emacs/site-lisp/cask/cask.el"
                                "~/.cask/cask.el"))))))
  (if cask-path
      (progn (require 'cask cask-path)
             (cask-initialize)
             (require 'pallet)
             (pallet-mode t))
    (error "Can't find cask.el")))

;; Turn off mouse interface early in startup to avoid momentary display
(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))

;; Set Emacs' `exec-path' and $PATH from the shell path
(setq exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH"))
(exec-path-from-shell-initialize)

;; Add core module directory to the load path
(add-to-list 'load-path (expand-file-name "core" user-emacs-directory))

;; Add external projects to the load path
(add-to-list 'load-path (expand-file-name "site-lisp" user-emacs-directory))
(defun my/update-load-path ()
  (interactive)
  (dolist (project (directory-files (expand-file-name "site-lisp" user-emacs-directory) t "\\w+"))
    (when (file-directory-p project)
      (add-to-list 'load-path project))))
(my/update-load-path)

;; Define constants
(defconst mac? (eq system-type 'darwin))

;; Use `use-package' globally
(require 'use-package)
(setq use-package-verbose t)

;;; bootstrap.el ends here
