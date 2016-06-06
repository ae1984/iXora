/* h-countnum.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Выбор страны (3-значный цифровой код)
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
        05/01/2004 sasco
 * CHANGES
        05/02/2004 sasco переделал так, чтобы список - по алфавиту и с запросом 
                         на часть названия страны
*/

define temp-table tmp  
                  field code as char format "x(3)"
                  field name as char format "x(30)"
                  index idx_tmp is primary name.

define variable vs as char label "Введите часть названия страны" format "x(40)".

update vs with row 8 centered overlay frame getstframe.
hide frame getstframe.
vs = "*" + CAPS(TRIM(vs)) + "*".


for each codfr where codfr.codfr = 'countnum' and codfr.code <> 'msc' and 
                     CAPS(TRIM(codfr.name[1])) matches vs no-lock:
    create tmp.
    tmp.code = codfr.code.
    tmp.name = codfr.name[1].
end.

{global.i}
{itemlist.i 
       &file = "tmp"
       &frame = "  row 5 centered scroll 1 10 down overlay title ' СПРАВОЧНИК СТРАН ' "
       &where = " TRUE "
       &flddisp = "
                   tmp.name FORMAT 'x(30)' LABEL 'НАЗВАНИЕ СТРАНЫ'
                   tmp.code FORMAT 'x(3)' LABEL 'КОД'
                   " 
       &chkey = "code"
       &chtype = "string"
       &index  = "idx_tmp" }

