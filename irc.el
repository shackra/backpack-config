;; --- Top-level: available before ERC loads ---

;; Prevent server/status buffers from stealing windows
(add-to-list 'display-buffer-alist
             '("\\*status\\|znc\\.jorgearaya\\.dev"
               (display-buffer-no-window)
               (allow-no-window . t)))

(defvar my/erc-znc-networks
  `(("liberachat" . (:nick "shackra"))
    ("oftc"       . (:nick "shackra_"))
    ("undernet"   . (:nick ,(base64-decode-string "a3JhZWxfdg==")))
    ("rizon"      . (:nick ,(base64-decode-string "b255eF9kcmlmdA==")))
    ("efnet"      . (:nick ,(base64-decode-string "Z2xhc3NwaW5l"))))
  "ZNC network definitions. Each entry: (name . (:nick nick)).")

(autoload 'erc-tls "erc" "ERC TLS connection." t)
(autoload 'erc-switch-to-buffer "erc" "Switch to ERC buffer." t)

(defun my/erc-znc (network)
  "Connect to a ZNC NETWORK."
  (interactive
   (list (completing-read "ZNC network: "
                          (mapcar #'car my/erc-znc-networks) nil t)))
  (let* ((conf (alist-get network my/erc-znc-networks nil nil #'string=))
         (nick (plist-get conf :nick))
         (user (concat "znc-admin/" network))
         (password (auth-source-pick-first-password
                    :host "znc.jorgearaya.dev" :port "6697" :user user)))
    (erc-tls :server "znc.jorgearaya.dev" :port 6697
             :nick nick :user user
             :password (or password
                           (read-passwd (format "ZNC password for %s: " network))))))

(defun my/erc-znc-all ()
  "Connect to all IRC networks via ZNC."
  (interactive)
  (dolist (entry my/erc-znc-networks)
    (my/erc-znc (car entry))))

(global-set-key (kbd "C-c i") #'erc-switch-to-buffer)
(autoload 'erc-nickbar-mode "erc-speedbar" "Toggle ERC nickbar." t)
(global-set-key (kbd "C-c I") #'erc-nickbar-mode)

;; --- ERC-dependent settings: deferred until ERC loads ---

(with-eval-after-load "erc"
  (setq erc-side-panel-nick-position 'left)

  (setq erc-user-full-name "Jorge Araya")

  (setq erc-track-enable-keybindings nil)
  (require 'erc-track)
  (erc-track-mode -1)

  (setq erc-join-buffer 'bury)
  (setq erc-auto-query 'bury)
  (setq erc-server-auto-reconnect t)
  (setq erc-server-reconnect-function #'erc-server-delayed-reconnect)
  (setq erc-hide-list '("JOIN" "PART" "QUIT" "NICK" "MODE"))

  (defun my/erc-notify-on-mention (_proc parsed)
    "Show echo area message when nick is mentioned."
    (let* ((channel (erc-response.contents parsed))
           (sender (car (erc-parse-user (erc-response.sender parsed))))
           (target (car (erc-response.command-args parsed)))
           (nick (erc-current-nick)))
      (when (and nick (string-match (regexp-quote nick) channel))
        (message "[IRC] %s mentioned you in %s" sender target)))
    nil)

  (add-hook 'erc-server-PRIVMSG-functions #'my/erc-notify-on-mention))
