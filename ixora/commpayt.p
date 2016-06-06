/* commpayt.p
 * MODULE
     Коммунальные платежи 
 * DESCRIPTION
     Процедура поиска налоговых платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
       3.2.10.4.14
 * AUTHOR
        31/12/99 pragma
 * CHANGES
     30.07.03 kanat Добавил поиск по ФИО по РНН = 000000000000
     09.10.03 sasco добавил вывод КБК и РНН НК
     29.20.03 sasco Добавил запрос на F4 после завершения поиска
*/

{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
ourbank = comm-txb().
ourcode = comm-cod().

def var v-dat1 as date label "Период с..." init today.
def var v-dat2 as date label "Период по..." init today.
def var v-uid as char label "Офицер" init ?.
def var v-rnn as char label "РНН" init ? format 'x(12)'.
def var v-dnum like tax.dnum label "Номер документа" init ?.
def var v-s1  as decimal label "Сумма с..." format "z,zzz,zzz,zzz,zz9.99" init 0.
def var v-s2  as decimal label "Сумма по..." format "z,zzz,zzz,zzz,zz9.99" init 999999999.
def var v-fioadr as char label "ФИО" init ?.

define frame inframe
       v-dnum v-uid skip
       v-dat1 v-dat2 skip
       v-rnn format 'x(12)' skip
       v-s1 skip
       v-s2
       v-fioadr format "x(40)"
     with row 4 side-labels centered.

update v-dnum v-uid 
       v-dat1 v-dat2 
       v-rnn 
       v-s1 
       v-s2
       v-fioadr 
       with centered side-labels frame inframe.

hide frame inframe.

form 
     tax.date label "Дата"
     tax.dnum label "N.док." format 'zzzzzz9' skip
     tax.sum label "Сумма" 
     tax.uid label "Кассир"
     tax.duid label "Было удалено" skip
     tax.rnn  label "PHH" format 'x(12)' skip
     tax.taxdoc label "Проводки - на АРП" format "x(10)" 
     tax.comdoc label "комиссия" format "x(10)" 
     tax.senddoc label "RMZ" format "x(10)" 
     tax.chval[1] label "ФИО" format "x(40)"
     tax.kb label "КБК" format '999999'
     tax.rnn_nk label "РНН НК" format "x(12)"
     with row 2 centered side-labels frame dispframe.


if  v-dnum <> ? then
do:
   if v-uid = ? then
   for each tax where comm.tax.txb = ourcode and
                      tax.dnum = v-dnum and
                      date >= v-dat1 and
                      date <= v-dat2 and tax.sum >= v-s1 and tax.sum <= v-s2
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
   end.
   else 
   for each tax where comm.tax.txb = ourcode and
                      tax.dnum = v-dnum and
                      date >= v-dat1 and
                      date <= v-dat2 and
                      tax.uid = v-uid and tax.sum >= v-s1 and tax.sum <= v-s2
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
   end.

end.
else do:
if v-uid <> ? then
do:
   if v-rnn <> ? and v-fioadr = ? then do:
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2 and
                      tax.uid = v-uid and
                      tax.rnn = v-rnn and tax.sum >= v-s1 and tax.sum <= v-s2
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

   if v-rnn <> ? and v-fioadr <> ? then do:
    v-fioadr = "*" + v-fioadr + "*".
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2 and
                      tax.uid = v-uid and
                      tax.rnn = v-rnn and tax.sum >= v-s1 and tax.sum <= v-s2 and 
                      tax.chval[1] matches v-fioadr no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

   if v-rnn = ? and v-fioadr = ? then do:
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2 and
                      tax.uid = v-uid  and tax.sum >= v-s1 and tax.sum <= v-s2
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

   if v-rnn = ? and v-fioadr <> ? then do:
    v-fioadr = "*" + v-fioadr + "*".
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2 and
                      tax.uid = v-uid  and tax.sum >= v-s1 and tax.sum <= v-s2 and
                      tax.chval[1] matches v-fioadr 
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

end.
else
do:

   if v-rnn <> ? and v-fioadr = ? then do:
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2 and
                      tax.rnn = v-rnn and tax.sum >= v-s1 and tax.sum <= v-s2
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

   if v-rnn <> ? and v-fioadr <> ? then do:
    v-fioadr = "*" + v-fioadr + "*".
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2 and
                      tax.rnn = v-rnn and tax.sum >= v-s1 and tax.sum <= v-s2 and
                      tax.chval[1] matches v-fioadr
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

   if v-rnn = ? and v-fioadr = ? then do: 
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2  and tax.sum >= v-s1 and tax.sum <= v-s2
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

   if v-rnn = ? and v-fioadr <> ? then do: 
    v-fioadr = "*" + v-fioadr + "*".
    for each tax where comm.tax.txb = ourcode and
                      date >= v-dat1 and
                      date <= v-dat2  and tax.sum >= v-s1 and tax.sum <= v-s2 and
                      tax.chval[1] matches v-fioadr
                      no-lock.
       displ tax.rnn tax.date tax.dnum tax.uid tax.duid tax.sum tax.taxdoc tax.comdoc tax.senddoc tax.chval[1] tax.kb tax.rnn_nk
             with frame dispframe.
             pause.
    end.
   end.

end.
end.

pause 0.
displ "Нажмите F4 для выхода" with row 17 centered overlay frame fend title "Конец поиска".

{wait.i}
hide frame fend. pause 0.
