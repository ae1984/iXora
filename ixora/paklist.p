/* paklist.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Получить список пользователей по пакетам
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
        26.08.2004 sasco
 * CHANGES
        19.04.2005 sasco исправил условие на matches 
*/


define variable v-paks as character initial "*" format "x(12)".
define variable uvol as logical initial no.

define temp-table tmp like ofc 
                  index idx_tmp is primary titcd ofc.

update v-paks label "Введите часть названия пакета" skip(1)
       " пусто - вывести всех без пакетов" skip
       "   *   - вывести всех, имеющих 1 пакет (и больше)" skip
       " пакет - вывести всех, имеющих этот пакет" skip
       " маска - вывести всех, имеющих  пакет(ы) по маске" skip(1)
       uvol label "Показать только уволенных" skip(1)
       "  yes  - список будет из уволенных" skip
       "   no  - список будет из работающих" skip
       with side-labels color messages centered frame getpaks.
hide frame getpaks.

v-paks = "*" + trim(v-paks) + "*".

v-paks = replace (v-paks, "**", "*").
v-paks = replace (v-paks, "**", "*").
v-paks = replace (v-paks, "**", "*").

for each ofc where (ofc.expr[1] matches v-paks and v-paks <> "*") or (ofc.expr[1] <> "" and v-paks = "*") no-lock:
    find ofcblok where ofcblok.sts = "u" and ofcblok.ofc = ofc.ofc no-lock no-error.
    if avail ofcblok and not uvol then next.
    if not avail ofcblok and uvol then next.
    create tmp.
    buffer-copy ofc to tmp.
end.

output to paks.csv.
put unformatted "Профит-центр;Логин;ФИО;Пакеты" skip.
for each tmp:
    put unformatted tmp.titcd ";" tmp.ofc ";" tmp.name ";" tmp.expr[1] skip.
end.
output close.

unix silent cptwin paks.csv excel.
