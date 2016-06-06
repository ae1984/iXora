/* sgn.i
 * MODULE
        Клиентская база
 * DESCRIPTION
        Управление хранилищем карточек - импорт, замена, списки файлов
        Файл общих настроек
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13
 * AUTHOR
        29.02.2004 nadejda
 * CHANGES
*/

{sgn0.i}

def {1} shared var s-sgnpath as char init "\/data\/9\/export\/signs\/".
def {1} shared var s-tmppath as char init "tmpsgn".
def {1} shared var s-hostmy as char.
def {1} shared var s-fileext as char init ".gif".

/* определить общие переменные */
if "{1}" = "new" then do:
  /* каталог с карточками на сервере */
  find sysc where sysc.sysc = "SGNPTH" no-lock no-error.
  if avail sysc then s-sgnpath = trim(sysc.chval).
  else do transaction on error undo, retry:
    create sysc.
    assign sysc.sysc = "SGNPTH"
           sysc.des = "Путь к файлу карточек подписей"
           sysc.chval = s-sgnpath.
  end.
  if substr(s-sgnpath, length(s-sgnpath), 1) <> "/" then s-sgnpath = s-sgnpath + "/".

  /* каталог временных файлов на сервере */
  find sysc where sysc.sysc = "SGNTMP" no-lock no-error.
  if avail sysc then s-tmppath = trim(sysc.chval).
  else do transaction on error undo, retry:
    create sysc.
    assign sysc.sysc = "SGNTMP"
           sysc.des = "Каталог времен.файлов карточек"
           sysc.chval = s-tmppath.
  end.
  if substr(s-tmppath, length(s-tmppath), 1) <> "/" then s-tmppath = s-tmppath + "/".

  /* локальная машина юзера */
  input through askhost.
  repeat:
    import s-hostmy.
  end.
  input close.

end.
