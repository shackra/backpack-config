;; -*- no-byte-compile: t; -*-

(gear!
 :ui
 (theme doom-one)
 diff-hl

 :completion
 (corfu auto-for-prog auto-for-text auto-idle)
 (vertico quick repeat suspend)
 (consult eglot dir project-extra todo)
 orderless
 marginalia
 embark
 cape

 :email
 mu4e

 :ai
 anvil
 eca

 :term
 (eshell eat)

 :tools
 (magit difftastic)
 direnv
 (eldoc box)
 (dired icons)
 activities

 :checkers
 spellchecking

 :editing
 ;; C
 (c lsp)
 make

 ;; C++
 (cpp lsp)
 (cmake lsp)

 ;; modos mayores para trabajo `backend`
 (go lsp)
 (rust lsp)
 (python lsp)
 (haskell lsp)

 ;; modos mayores para trabajo `frontend`
 (javascript lsp)
 (typescript lsp)
 (html lsp web)
 (svelte lsp)
 (css lsp)

 ;; lenguajes de programación para configurar cosas
 (nix lsp)
 (terraform lsp doc)
 emacs-lisp

 ;; modos mayores para archivos de datos
 (json lsp)
 (yaml lsp)
 (toml lsp)
 kdl

 ;; modos mayores para cosas muy "niche"
 hyprland

 ;; modos mayores para escribir prosa
 latex
 (typst lsp)
 markdown

 ;; org-mode y amigos
 (org roam noter)

 :config
 (default no-splash hide-tool-bar hide-menu-bar))
;; fin de macro gear!

(set-face-attribute 'default nil :family "Iosevka Nerd Font Mono" :height 160)

;; Fuente variable (para textos con variable-pitch)
(set-face-attribute 'variable-pitch nil :family "Iosevka Comfy")

(set-face-attribute 'fixed-pitch nil :family "Iosevka Nerd Font Mono")

;; Fuente de símbolos
(set-fontset-font t 'symbol (font-spec :family "JuliaMono"))

;;(setq org-roam-directory (file-truename "~/Documentos/org"))

(leaf dm-log
  :ensure (dm-log :host github :repo "shackra/dm-log")
  :after org
  :commands dm-log
  :custom
  (dm-log-campaigns-directory . "~/Documentos/OSR/Magía y Acero/campañas"))

;; email — extensions for mu4e
(load-file (expand-file-name "email.el" backpack-user-dir))
;; ERC — connect to ZNC bouncer
(load-file (expand-file-name "irc.el" backpack-user-dir))

;; Instapaper — guardar URLs
(load-file (expand-file-name "instapaper.el" backpack-user-dir))
