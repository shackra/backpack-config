;; -*- no-byte-compile: t; lexical-binding: t; -*-
;;
;; Instapaper — guardar URLs via Simple API
;;
;; Requiere entrada en ~/.authinfo.gpg:
;;   machine instapaper.com login EMAIL password PASSWORD

(require 'auth-source)
(require 'url)

(defun my/instapaper--credentials ()
  "Return (USER . PASSWORD) from auth-source for instapaper.com."
  (let ((found (car (auth-source-search :host "instapaper.com" :max 1))))
    (unless found
      (user-error "No credentials for instapaper.com in auth-source"))
    (let ((user (plist-get found :user))
          (secret (plist-get found :secret)))
      (cons user (if (functionp secret) (funcall secret) secret)))))

(defun my/instapaper--resolve-url (url callback)
  "Resolve redirects for URL asynchronously, then call CALLBACK with final URL."
  (let ((output ""))
    (make-process
     :name "instapaper-resolve"
     :command (list "curl" "-Ls" "-o" "/dev/null" "-w" "%{url_effective}" url)
     :filter (lambda (_proc string)
               (setq output (concat output string)))
     :sentinel (lambda (_proc event)
                 (when (string-match-p "finished" event)
                   (funcall callback (string-trim output)))))))

(defun my/instapaper--add (url)
  "Add URL to Instapaper via Simple API."
  (let* ((creds (my/instapaper--credentials))
         (url-request-method "POST")
         (url-request-extra-headers
          '(("Content-Type" . "application/x-www-form-urlencoded")))
         (url-request-data
          (url-build-query-string
           `(("username" ,(car creds))
             ("password" ,(cdr creds))
             ("url" ,url)))))
    (url-retrieve
     "https://www.instapaper.com/api/add"
     (lambda (status)
       (if (plist-get status :error)
           (message "Instapaper error: %S" (plist-get status :error))
         (message "Saved to Instapaper: %s" url))
       (kill-buffer (current-buffer))))))

(defun my/instapaper-add (url)
  "Add URL to Instapaper, resolving redirects first.
If point is on a URL, use it; otherwise prompt for one."
  (interactive
   (list (or (get-text-property (point) 'shr-url)
             (thing-at-point 'url t)
             (read-string "URL: "))))
  (message "Resolving %s..." url)
  (my/instapaper--resolve-url
   url
   (lambda (resolved)
     (message "Adding %s to Instapaper..." resolved)
     (my/instapaper--add resolved))))

(with-eval-after-load 'mu4e-view
  (keymap-set mu4e-view-mode-map "C-," #'my/instapaper-add))
