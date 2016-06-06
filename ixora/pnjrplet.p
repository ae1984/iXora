/* pnjrplet.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Отчет по письмам клиентам по возвратам пенсионных платежей за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.9.13.3
 * AUTHOR
        11.12.2003 sasco
 * CHANGES
        12.12.2003 sasco Добавил обработку типов "pnjrmz" и "pnjcas"
        18.12.2003 sasco добавил и-шку для перекомпиляции
*/
{pnjcommon.i}

{comm-txb.i}
{trim.i}

define shared variable g-ofc as char.
define shared variable g-today as date.

define variable v-d1 as date.
define variable v-d2 as date.
define variable ourbnk as character.

define temp-table tmp like letters.

v-d1 = g-today.
v-d2 = g-today.

ourbnk = comm-txb ().

update v-d1 label "Период с..." v-d2 label "по..." with row 2 centered side-labels frame getdat.
hide frame getdat.

/* возвраты RMZ */
for each letters where letters.bank = ourbnk and letters.type = "pnjrmz" no-lock:
    create tmp.
    buffer-copy letters to tmp.
end.
/* возвраты кассовых платежей */
for each letters where letters.bank = ourbnk and letters.type = "pnjcas" no-lock:
    create tmp.
    buffer-copy letters to tmp.
end.

output to rpt.csv.
put unformatted "Дата письма;Номер письма;Офицер;Номер платежа(RMZ);Дата платежа(RMZ);Номер платежа(касса);Дата платежа(касса)" skip.
for each tmp by tmp.rdt:
    put unformatted tmp.rdt ";" 
                    tmp.docnum ";"
                    tmp.rwho ";".
    if tmp.type = "pnjrmz" then put unformatted tmp.ref ";" tmp.refdt ";;;" skip.
    if tmp.type = "pnjcas" then put unformatted ";;" tmp.ref ";" tmp.refdt skip.
end.
output close.
unix silent cptwin rpt.csv excel.
unix silent rm rpt.csv.
