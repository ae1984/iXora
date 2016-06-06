/* comrstr.p
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

/******************************************************************************/
/*  Создан: 13/06/2003 Pragma                                                 */
/*  Описание: Отчет по отправленным налоговым пачкам                          */
/*  Последние изменения: Аяпбергенов К.А. написал процедуру                   */
/******************************************************************************/



{global.i}
{comm-txb.i}


if not connected ("comm") then run comm-con. /*:))*/

def buffer ttax for tax.

def var date_begin   as date.
def var d_tax_sum    as decimal format '>>>,>>>,>>>,>>9.99'.
def var s_rnn        as char    format 'x(12)'.
def var i_kbk        as integer format '>>>>>9'.
def var d_whole_sum_1  as decimal init 0.
def var d_whole_sum_2  as decimal init 0.
def var d_whole_sum_3  as decimal init 0.
def var i_txb 	     as integer.
def var i_grp        as integer. 
def var s_rnnnk	     as char.
def var choice       as logical.
def var s_nk_name    as char.
def var s_dsenddoc    as char format "x(10)".
def var s_sendpac    as char.
 	
i_txb = comm-cod().

update date_begin   label "Введите дату платежа: " with centered side-label.
update d_tax_sum    label "Введите сумму платежа: " with centered side-label.
update s_rnn        label "Введите РНН плательщика: " with centered side-label.
update i_kbk        label "Введите код бюджетной классификации: " with centered side-label.


    message "Выбрать налоговый комитет?"
    view-as alert-box question buttons yes-no
    title "НК РК:" update choice.


if choice then do:
run taxnkall.
s_rnnnk = string(return-value).
end.
else
s_rnnnk = 'ALL'.

output to comrstr.img.
put unformatted 'Информация по реестру отправленных налоговых платежей за ' date_begin skip.
put fill("-",70) format "x(70)" skip.
put unformatted 'Квитанция    Номер пачки РНН           КБК                 Сумма' skip.
put fill("-",70) format "x(70)" skip.


for each tax where tax.duid = ? and 
		   tax.date = date_begin and 
		   tax.txb  = i_txb and 
                   (tax.rnn  = s_rnn or s_rnn = '') and 
                   (tax.kb   = i_kbk) and 
		   (tax.rnn_nk = s_rnnnk or s_rnnnk = 'ALL') and
                   tax.sum  = d_tax_sum no-lock break by tax.grp:

if first-of(tax.grp) then do:
find first taxnk where taxnk.rnn = tax.rnn_nk no-lock no-error.
if avail taxnk then
s_nk_name = taxnk.name.
put unformatted s_nk_name skip.
put fill("-",70) format "x(70)" skip.
end.

put unformatted tax.dnum format 'zzzzz9' ' ' 
                tax.grp  format 'zzzzzzzzzzz9' '      ' 
                tax.rnn  format 'x(12)' '  ' 
                tax.kb   format 'zzzzz9' ' '
                tax.sum  format 'zzz,zzz,zzz,zz9.99' skip.

accumulate tax.sum (sub-total by tax.grp).

if last-of(tax.grp) then do:

d_whole_sum_1 = accum sub-total by tax.grp tax.sum.
put fill("-",70) format "x(70)" skip.

for each ttax where ttax.txb = tax.txb and ttax.date = tax.date and ttax.grp = tax.grp and ttax.duid = ? no-lock:
    accumulate ttax.sum (total).
end.
d_whole_sum_2 = accum total (ttax.sum).

s_dsenddoc = tax.senddoc.

find first remtrz where remtrz.remtrz = s_dsenddoc no-lock no-error.
if avail remtrz then do:
s_sendpac = trim(substring(remtrz.sqn,19,8)).
d_whole_sum_3 = remtrz.amt.
end.

put unformatted 'Референс: ' s_dsenddoc skip.
put fill("-",70) format "x(70)" skip.
put unformatted 'Итого по отправленной пачке ї: ' s_sendpac ' - ' d_whole_sum_3 format ">>,>>>,>>>,>>>,>>9.99" " KZT " skip.
put fill("-",70) format "x(70)" skip.
end.

end.            

output close.
run menu-prt ('comrstr.img').

