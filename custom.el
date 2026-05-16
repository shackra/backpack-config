;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((jinx-languages . "en")
     (:yaml
      (:format (:enable t) :validate t :hover t :completion t :schemas
	       (:https://www.schemastore.org/github-workflow.json
		["/.github/workflows/*.yml"])
	       :schemaStore (:enable t)))
     (org-download-image-dir . "./imagenes")
     (org-clock-mode-line-total . today)
     (go-tag-args "-transform" "camelcase"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
