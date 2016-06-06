/* dsr.i
 * MODULE
        Клиентская база
 * DESCRIPTION
    -------------    Копия 1-13 Хранилище карточек подписей -----------------------------
        Управление хранилищем досье - импорт, замена, списки файлов
        Файл общих настроек
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-13-6
 * AUTHOR
        03.02.2005 marinav
 * CHANGES
*/

{dsr0.i}

def {1} shared var s-dsrpath as char init "\/data\/export\/dossier\/".
def {1} shared var s-tmppath as char init "tmpdsr".
def {1} shared var s-hostmy as char.
def {1} shared var s-fileext as char init ".jpg".

/* определить общие переменные */
if "{1}" = "new" then do:
  /* каталог с карточками на сервере */
  find sysc where sysc.sysc = "DSRPTH" no-lock no-error.
  if avail sysc then s-dsrpath = trim(sysc.chval).
  else do transaction on error undo, retry:
    create sysc.
    assign sysc.sysc = "DSRPTH"
           sysc.des = "Путь к файлам досье клиентов"
           sysc.chval = s-dsrpath.
  end.
  if substr(s-dsrpath, length(s-dsrpath), 1) <> "/" then s-dsrpath = s-dsrpath + "/".

  /* каталог временных файлов на сервере */
  find sysc where sysc.sysc = "DSRTMP" no-lock no-error.
  if avail sysc then s-tmppath = trim(sysc.chval).
  else do transaction on error undo, retry:
    create sysc.
    assign sysc.sysc = "DSRTMP"
           sysc.des = "Каталог времен.файлов досье"
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
