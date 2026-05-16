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

 :term
 (eshell eat)

 :tools
 magit
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

;;(setq org-roam-directory (file-truename "~/Documentos/org"))

(leaf dm-log
  :ensure (dm-log :host github :repo "shackra/dm-log")
  :after org
  :commands dm-log
  :custom
  (dm-log-campaigns-directory . "~/Documentos/OSR/Magía y Acero/campañas"))

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
	    :sig "Jorge Araya\nFreelance Software Engineer — https://jorgearaya.dev")))

  (defun my/mu4e--mail-to-text (path)
    "Read email at PATH and return its HTML body as plain text."
    (with-temp-buffer
      (insert-file-contents-literally path)
      (goto-char (point-min))
      (when (re-search-forward "<html" nil t)
	(let ((html-start (match-beginning 0)))
          (quoted-printable-decode-region html-start (point-max))
          (decode-coding-region html-start (point-max) 'utf-8)
          (delete-region (point-min) html-start)
          (goto-char (point-min))
          (while (re-search-forward "<style[^<]*\\(<[^/][^<]*\\)*</style>" nil t)
            (replace-match ""))
          (goto-char (point-min))
          (while (re-search-forward "<[^>]+>" nil t)
            (replace-match " "))
          (goto-char (point-min))
          (while (re-search-forward "&nbsp;\\|&#x200[Aa];\\|&#8202;" nil t)
            (replace-match " "))
          (goto-char (point-min))
          (while (re-search-forward "[ \t\n\r]+" nil t)
            (replace-match " "))
          (buffer-string)))))

  (defun my/mu4e--parse-wink-amount (raw)
    "Parse a WINK amount string RAW like \"5,446.37\" into a number."
    (string-to-number (replace-regexp-in-string "," "" raw)))

  (defun my/mu4e--extract-bncr (text)
    "Extract voucher data from Banco Nacional email TEXT."
    (let (place when-str amount)
      (when (string-match "realizada en \\(.+?\\) el \\(.+? [ap]\\.m\\.\\)" text)
	(setq place (match-string 1 text)
              when-str (match-string 2 text)))
      (when (string-match "CRC \\([0-9]+\\),\\([0-9]\\{2\\}\\)" text)
	(setq amount (+ (string-to-number (match-string 1 text))
			(/ (string-to-number (match-string 2 text)) 100.0))))
      (when (and place when-str amount)
	(list :type "Compra" :place place :when when-str :amount amount))))

  (defun my/mu4e--extract-wink (text)
    "Extract voucher data from WINK email TEXT."
    (cond
     ;; Purchase
     ((string-match "Monto de la compra: \\([0-9,]+\\.[0-9]\\{2\\}\\)" text)
      (let ((amount (my/mu4e--parse-wink-amount (match-string 1 text)))
            place when-str)
	(when (string-match "Comercio: \\(.+?\\) Fecha" text)
          (setq place (match-string 1 text)))
	(when (string-match "Fecha y hora: \\(.+?\\) (hora" text)
          (setq when-str (match-string 1 text)))
	(when (and place when-str)
          (list :type "Compra" :place place :when when-str :amount amount))))
     ;; Transfer sent
     ((string-match "Monto transferido: \\([0-9,]+\\.[0-9]\\{2\\}\\)" text)
      (let ((amount (my/mu4e--parse-wink-amount (match-string 1 text)))
            place when-str)
	(when (string-match "Nombre del destinatario: \\(.+?\\) Monto" text)
          (setq place (match-string 1 text)))
	(when (string-match "Fecha de la transferencia: \\([0-9/]+\\)" text)
          (setq when-str (match-string 1 text)))
	(when (and place when-str)
          (list :type "Envío" :place place :when when-str :amount amount))))
     ;; Transfer received
     ((string-match "Monto recibido: \\([0-9,]+\\.[0-9]\\{2\\}\\)" text)
      (let ((amount (my/mu4e--parse-wink-amount (match-string 1 text)))
            when-str)
	(when (string-match "Fecha y hora de la transferencia: \\(.+?\\) (hora" text)
          (setq when-str (match-string 1 text)))
	(when when-str
          (list :type "Recibida" :place "SINPE Móvil" :when when-str :amount amount))))))

  (defun my/mu4e--extract-voucher-data (path from)
    "Extract place, date and amount from a bank voucher email at PATH.
FROM is the sender email address, used to select the right parser."
    (when-let* ((text (my/mu4e--mail-to-text path)))
      (cond
       ((string-match "bncr\\.fi\\.cr" from) (my/mu4e--extract-bncr text))
       ((string-match "holawink\\.com" from) (my/mu4e--extract-wink text)))))

  (defun my/mu4e--signed-amount (data)
    "Return amount from DATA, negative for received transfers."
    (let ((amount (plist-get data :amount))
          (type (plist-get data :type)))
      (if (string= type "Recibida") (- amount) amount)))

  (defun my/mu4e-sum-marked-totals ()
    "Sum amounts from marked transaction emails in mu4e-headers.
Purchases and sent transfers add, received transfers subtract."
    (interactive)
    (let ((sum 0)
          (count 0))
      (with-current-buffer (mu4e-get-headers-buffer)
	(mu4e-headers-for-each
	 (lambda (msg)
           (when (mu4e-mark-docid-marked-p (mu4e-message-field msg :docid))
             (when-let* ((path (mu4e-message-field msg :path))
			 (from (plist-get (car (mu4e-message-field msg :from)) :email))
			 (data (my/mu4e--extract-voucher-data path from)))
               (setq sum (+ sum (my/mu4e--signed-amount data))
                     count (1+ count)))))))
      (message "Sum of %d transactions: CRC %.2f" count sum)))

  (defun my/mu4e-voucher-table ()
    "Show org-table with type, place, date, amount from marked transaction emails."
    (interactive)
    (let (rows (total 0))
      (with-current-buffer (mu4e-get-headers-buffer)
	(mu4e-headers-for-each
	 (lambda (msg)
           (when (mu4e-mark-docid-marked-p (mu4e-message-field msg :docid))
             (when-let* ((path (mu4e-message-field msg :path))
			 (from (plist-get (car (mu4e-message-field msg :from)) :email))
			 (data (my/mu4e--extract-voucher-data path from)))
               (let ((signed (my/mu4e--signed-amount data)))
		 (setq total (+ total signed))
		 (push (list (plist-get data :type)
                             (plist-get data :place)
                             (plist-get data :when)
                             (format "%.2f" signed))
                       rows)))))))
      (if (null rows)
          (message "No marked transaction emails found")
	(setq rows (nreverse rows))
	(let ((buf (get-buffer-create "*Voucher Summary*")))
          (with-current-buffer buf
            (erase-buffer)
            (org-mode)
            (insert "| Tipo | Lugar | Fecha | Monto (CRC) |\n")
            (insert "|---+---+---+---|\n")
            (dolist (row rows)
              (insert (format "| %s | %s | %s | %s |\n"
                              (nth 0 row) (nth 1 row) (nth 2 row) (nth 3 row))))
            (insert "|---+---+---+---|\n")
            (insert (format "| | | TOTAL | %.2f |\n" total))
            (goto-char (point-min))
            (org-table-align))
          (pop-to-buffer buf))))))

;; ERC — connect to ZNC bouncer
(load-file (expand-file-name "irc.el" backpack-user-dir))
