(require 'cask "~/.cask/cask.el")
(cask-initialize)

;; evil
(setq evil-want-C-u-scroll t
      evil-search-module 'evil-search
      evil-ex-search-vim-style-regexp t)
;; enable evil
(require 'evil)
(evil-mode 1)

(defun evil-swap-key (map key1 key2)
  ;; MAP中のKEY1とKEY2を入れ替え
  "Swap KEY1 and KEY2 in MAP."
  (let ((def1 (lookup-key map key1))
        (def2 (lookup-key map key2)))
    (define-key map key1 def2)
    (define-key map key2 def1)))
(evil-swap-key evil-motion-state-map ":" ";")
;;(evil-swap-key evil-motion-state-map ";" ":")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("9bc1eec9b485726318efd9341df6da8b53fa684931d33beba57ed7207f2090d6" "bbb51078321186cbbbcb38f9b74ea154154af10c5d9c61d2b0258cb4401ac038" "a405a0c2ec845e34ecb32a83f477ca36d1858b976f028694e0ee7ff4af33e400" "a3821772b5051fa49cf567af79cc4dabfcfd37a1b9236492ae4724a77f42d70d" "6981a905808c6137dc3a3b089b9393406d2cbddde1d9336bb9d372cbc204d592" "0c5204945ca5cdf119390fe7f0b375e8d921e92076b416f6615bbe1bd5d80c88" "d251c0f968ee538a5f5b54ed90669263f666add9c224ad5411cfabc8abada5a0" "0058b7d3e399b6f7681b7e44496ea835e635b1501223797bad7dd5f5d55bb450" "beeb4fbb490f1a420ea5acc6f589b72c6f0c31dd55943859fc9b60b0c1091468" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;;(require 'color-theme)
;;ld-dark, midnight parus pok-wob
;;(load-theme 'snowish)
(load-theme 'midnight)
(require 'auto-complete)
(global-auto-complete-mode t)

;;(require 'rosemacs)
;;(invoke-rosemacs)
;;(global-set-key "\C-x\C-r" ros-keymap)

;; redoをC-.に設定
;; setupにはM-x byte-compile-file (path-to)/redo.elが必要
;;(require 'redo)
;;(define-key global-map [?\C-.] 'redo)

;; keybindings
;;(define-key global-map "\C-z" ' undo)
;(define-key global-map (kbd "C-/") 'undo)
;;(define-key global-map (kbd "C-x C-/") 'redo)
;;(define-key global-map "\C-c\C-i" ' dabbrev-expand) ;;dynamic abbrev expansion
(global-set-key "\C-h" 'delete-backward-char) ;; C-hをbackspaceにする

;; 外部デバイスとクリップボードを共有
(setq x-select-enable-clipboard t)
;;バックアップファイルを作らない
(setq backup-inhibited t)
;; 終了時にオートセーブファイルを消す
(setq delete-auto-save-files t)
;;; 対応する括弧を光らせる
(show-paren-mode t)
(setq show-paren-style 'mixed)
(set-face-background 'show-paren-match-face "salmon")
(set-face-bold-p 'show-paren-match-face t)
;;(set-face-foreground 'show-paren-match-face "white")
(set-face-background 'show-paren-mismatch-face "black")
(set-face-bold-p 'show-paren-mismatch-face t)
(set-face-foreground 'show-paren-mismatch-face "red")
;;dired
(setq dired-dwim-target t)
(require 'rainbow-delimiters)
;;(global-rainbow-delimiters-mode t)
(rainbow-delimiters-mode)
;; font
(set-face-attribute 'default nil
            :family "Source Code Pro" ;; font
            :height 130)    ;; font size
;(setq face-font-rescale-alist
      ;'(("Ume P Gothic" . 1.2)))

