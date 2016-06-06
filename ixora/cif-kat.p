/* cif-kat.p
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
*/

/* cifkat1.p
* Модуль
            Клиенты и их счета
* Назначение 
            Редактирование категории клиента (I, II, III) 
            для справочника codfr.codfr = 'cifkat'
* Применение
            
* Вызов 
            nmenu.p
* Меню 
            8.1.15.4
* Автор
            sasco
* Дата создания
            31.07.03
* Изменения
*/                                        

define shared variable s-cif like cif.cif.
define variable v-trw as character no-undo format 'x(2)'.
define variable v-des as character no-undo format 'x(15)'.

define frame gettrw v-trw format "x(2)" label "Категория клиента (F2 - выбор)"
             validate (can-find(first codfr where codfr.codfr = 'cifkat' and codfr.code = v-trw), 
                       'Нет такого кода категории!')
             skip
             ">> " v-des no-label
             with row 5 centered overlay side-labels title "".

find cif where cif.cif = s-cif no-error.
if not available cif then return.

on 'value-changed' of v-trw in frame gettrw do:
   find first codfr where codfr.codfr = 'cifkat' and codfr.code = v-trw:screen-value no-lock no-error.
   if available codfr then v-des = codfr.name[1].
                      else v-des = ''.
   v-des:screen-value = v-des.
end.

v-trw = cif.trw.
displ v-trw with frame gettrw.
apply 'value-changed' to v-trw in frame gettrw.

update v-trw with frame gettrw
       editing: readkey.
                apply last-key.
                if frame-field = "v-trw" then apply 'value-changed' to v-trw in frame gettrw.
       end.

cif.trw = v-trw.
