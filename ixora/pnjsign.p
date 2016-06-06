/* pnjsign.p
 * MODULE
        Платежная система
 * DESCRIPTION
        Копирование на локальную машину пользователя файла(-ов) в локальный каталог:
        1. файл факсимиле руководителя - для подписи писем клиентам по возвратам пенсионок
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5.9.13.4
 * AUTHOR
        12.12.2003 sasco
 * CHANGES
        18.12.2003 sasco добавил и-шку для перекомпиляции
*/
{pnjcommon.i}

{global.i}
{comm-dir.i}

define variable v-path as character.
define variable v-host as character format "x(50)".
define variable v-ipaddr as character format "x(30)".
define variable s-tempfolder as character.
define variable v as character.
define variable v-str as character.

find sysc where sysc.sysc = "PNJRCP" no-lock no-error.
if not available sysc then do:
   message "Ошибка! В таблице sysc не настроен PNJRCP!" view-as alert-box title ' '.
   return.
end.
v-path = sysc.chval.

displ skip(1) "    Ждите...   " skip(1) with row 8 centered frame f-wait.

/* определение хоста */
input through askhost.
repeat:
  import v-host.
end.

input close.
pause 5 no-message.

/* определение каталога для копий файлов на локальной машине юзера */
input through localtemp.
repeat:
  import s-tempfolder.
end.
input close.

pause 5 no-message.
if substr(s-tempfolder, length(s-tempfolder), 1) <> "\\" then s-tempfolder = s-tempfolder + "\\".

/* получим список файлов */
run comm-cleardir.
run comm-dir (v-path, "", FALSE).

/* копируем файлы */
v-str = "".
run savelog("pnjrcp", "Начало предварительной настройки...").
run savelog("pnjrcp", "Хост: " + v-host). 
run savelog("pnjrcp", "Временный каталог: " + s-tempfolder).
run savelog("pnjrcp", "Путь к файлам: " + v-path).

for each comm-dir where comm-dir.type = "F":
  run savelog("pnjrcp", "... " + comm-dir.fname).
  input through value("rcp " + comm-dir.fullname + " " + v-host + ":" + replace(s-tempfolder, "\\", "/") + ";echo $?").
  repeat:
    import v.
  end.
  input close.
  pause 3 no-message.

  if v <> "0" then do:
    if v-str <> "" then v-str = v-str + "; ".
    v-str = v-str + " " + comm-dir.fname.
  end.

  run savelog("pnjrcp","  result: " + v).
end.

run comm-cleardir.

run savelog ("pnjrcp", "Завершение настройки").

hide frame f-wait no-pause.
if v-str = "" then
  message skip " Предварительная настройка завершена !" skip(1) view-as alert-box title "".
else
  message skip " Во время предварительной настройки произошла ошибка !" 
          skip " Файлы :" v-str
          skip(1) " Обратитесь к системному администратору !"
          skip(1) view-as alert-box title " ОШИБКА ! ".
