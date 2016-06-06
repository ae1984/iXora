/* func_del.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        29/06/04 sasco Переименовал v-ofc в v-ofc чтобы поиск по F2 срабатывал
        02/07/04 torbaev Добавил вывод помеченных и удаленнных пунктов в блокнот
*/

{yes-no.i}

DEF var num AS char.
DEF VAR by_fname as log.
DEF VAR cnt as int.

define variable v-ofc as char.

define temp-table tmp like sec
                      field log as logical format "X/ " column-label "X"
                      field rid as rowid
                      field name like nmdes.des column-label "Наименование"
                      field path as char
                      field ord as integer.
                      
define query q1 for tmp scrolling.

define stream tfile.

FUNCTION get_menunum RETURNS CHAR (input por as char). 
DEF VAR par as char.
num = "".
par = por.

REPEAT:
      FIND first nmenu WHERE nmenu.fname = par NO-LOCK NO-ERROR.
      IF AVAILABLE nmenu THEN
      DO:
        num = trim(string(nmenu.ln,"z9")) + "." + num.
        IF nmenu.father  =  "menu" THEN LEAVE.
        par = nmenu.father.
      END.
      ELSE
      DO:
        num = "".
        LEAVE.
      END.
END.

 RETURN (num). 

END FUNCTION.

define browse b1 query q1 display tmp.log
              tmp.path format "x(16)"
              tmp.fname column-label "Функция"
              tmp.name format "x(45)"
              with 15 down.

define frame f1
             b1 with no-box.

define var tmp-rid as rowid.

on RETURN of browse b1
do:
   if avail tmp then do:
      tmp.log = NOT tmp.log.
/*      tmp-rid = rowid (tmp).
      close query q1.
      open query q1 for each tmp by tmp.ord.
      reposition q1 to rowid tmp-rid no-error. */
      browse b1:refresh().
   end.
end.

on GO of browse b1
do:
   message 'Удалить права?' view-as alert-box BUTTONS YES-NO title "" 
            UPDATE choice as logical.
            
   if choice then
      do:
           output stream tfile to lst001.txt.
           close query q1. 
           for each tmp where tmp.log:
               find sec where rowid(sec) = tmp.rid no-error.
               put stream tfile unformatted tmp.path ", " .
               delete sec.
               delete tmp.
           end.
           output stream tfile close.
           open query q1 for each tmp by tmp.ord. 
           browse b1:refresh().
      unix silent cptwin "lst001.txt" notepad.
      end.
end.

update "Введите логин пользователя: " v-ofc no-label with frame getofc.
by_fname = yes-no ("СОРТИРОВКА", "YES = по именам функций~nNO = по пути к пункту меню").
hide frame getofc.

for each sec where sec.ofc = v-ofc:
    if trim (sec.fname) = "" then delete sec.
    else
    if trim (get_menunum (sec.fname)) = "" then delete sec.
    else do:
         create tmp.
         buffer-copy sec to tmp.
         assign tmp.log = FALSE
                tmp.rid = rowid (sec).
         tmp.path = get_menunum (sec.fname).
         find first nmdes where nmdes.fname = sec.fname and nmdes.lang = "RR" no-lock no-error.
         if avail nmdes then tmp.name = nmdes.des.
         else do:
              find first nmdes where nmdes.fname = sec.fname no-lock no-error.
              tmp.name = nmdes.des.
         end.
    end.
end.

cnt = 0.
if by_fname then
    for each tmp by tmp.fname:
        cnt = cnt + 1.
        tmp.ord = cnt.
    end.
else
    for each tmp by tmp.path:
        cnt = cnt + 1.
        tmp.ord = cnt.
    end.

open query q1 for each tmp by tmp.ord.
enable all with frame f1.
WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW FOCUS BROWSE b1.

