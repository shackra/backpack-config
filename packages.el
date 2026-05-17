(leaf playerctl
  :ensure t
  :doctor ("playerctl" . ("Command-line utility and library for controlling media players that implement MPRIS" 'required))
  :bind
  (("C-c C-SPC" .	playerctl-play-pause-song)
   ("C-c C-n"	.	playerctl-next-song)
   ("C-c C-p"	.	playerctl-previous-song)
   ("C-c C-f"	.	playerctl-seek-foward)
   ("C-c C-b"	.	playerctl-seek-backward)))

(leaf doom-modeline
  :ensure t
  :global-minor-mode doom-modeline-mode
  :custom-face
  (doom-modeline-bar . '((t (:background "black" :inherit mode-line))))
  :custom
  (doom-modeline-height			.	45)
  (doom-modeline-bar-width		.	0)
  (doom-modeline-enable-word-count	.	t)
  (doom-modeline-env-version		.	t))
