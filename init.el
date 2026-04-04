;; -*- no-byte-compile: t; -*-

(gear!
 :ui
 (theme doom-one)

 :completion
 (corfu auto-for-prog)

 :email
 mu4e

 :tools
 magit
 direnv
 (eldoc box)

 :checkers
 spellchecking

 :editing
 (c lsp)
 (cmake lsp)
 (cpp lsp)
 (css lsp)
 (go lsp)
 (html lsp)
 (haskell lsp)
 (json lsp)
 (less lsp)
 (lua lsp)
 (nix lsp)
 (python lsp)
 (terraform lsp doc)
 (yaml lsp)
 (toml lsp)
 emacs-lisp
 hyprland
 kdl
 latex
 make
 markdown
 org

 :config
 (default no-splash hide-tool-bar hide-menu-bar))

(set-face-attribute 'default nil :family "Iosevka Nerd Font Mono" :height 160)

;; Fuente variable (para textos con variable-pitch)
(set-face-attribute 'variable-pitch nil :family "Iosevka Comfy")

(set-face-attribute 'fixed-pitch nil :family "Iosevka Nerd Font Mono")

;; Fuente de símbolos
(set-fontset-font t 'symbol (font-spec :family "JuliaMono"))

(with-eval-after-load "mu4e-query"
    (setq email-query-one-of '(one-of "emacs-devel@gnu.org"
				      "help-gnu-emacs@gnu.org"
				      "mu-discuss@googlegroups.com"
				      "golang-nuts@googlegroups.com"
				      "python-list@python.org"))
    (setq email-query-mailing-lists  `(contact ,email-query-one-of))
    (setq email-query-maildir-trash  '(or (flag trashed) (maildir ("/.*\\/Trash/"))))

    ;; (man "mu-query") -- para saber más sobre las consultas con mu
    (setq mu4e-bookmarks
	  `((:name "Sin leer"
		   :key ?u
		   :query ,(mu4e-make-query `(and (flag unread) (not ,email-query-maildir-trash) (not ,email-query-mailing-lists))))
	    (:name "Listas de correo"
		   :key ?l
		   :query ,(mu4e-make-query `(and (flag unread) (not ,email-query-maildir-trash) ,email-query-mailing-lists)))
	    (:name "Marcado"
		   :key ?f
		   :query ,(mu4e-make-query '(flag flagged)))
	    (:name "Correos de hoy"
		   :key ?t
		   :query ,(mu4e-make-query `(and (date (today .. now)) (not ,email-query-mailing-lists)))))))

(with-eval-after-load "mu4e"
  (setq mu4e-get-mail-command "mbsync --all") ;; descarga y sube correos
  (setq mu4e-update-interval nil) ;; quiero manejar el correo de manera manual

  (setq mu4e-headers-date-format "%b %d, %Y")
  (setq mu4e-headers-time-format "%b %d, %H:%M")

  (setq mu4e-contexts
	`(,(backpack/mu4e-easy-context
	    :c-name "personal"
	    :maildir "principal"
	    :mail "jorge@esavara.cr"
	    :sig "Jorge Araya\n\nContacto:\n Telegram: t.me/shackra · Signal: Shackra.28")
	  ,(backpack/mu4e-easy-context
	    :c-name  "gmail"
	    :maildir "gmail"
	    :mail    "shackrasislock0@gmail.com"
	    :sent-action delete)
	  ,(backpack/mu4e-easy-context
	    :c-name "yahoo"
	    :maildir "yahoo"
	    :mail "jorgejavieran@yahoo.com.mx")
	  ,(backpack/mu4e-easy-context
	    :c-name "jorgearaya.dev"
	    :maildir "hey"
	    :mail "hey@jorgearaya.dev"
	    :sig "Jorge Araya\nFreelance Software Engineer — https://jorgearaya.dev"))))
