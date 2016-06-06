/* com_p.p
 * MODULE
     Коммунальные платежи. Поиск платежей по соц. отчислениям
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
       5.2.1.8.14
 * AUTHOR
        14/04/06 u00600
 * CHANGES
        08/06/06 u00600 - изменила поле commonpl.euid на commonpl.uid
*/

{comm-txb.i}
def var ourbank as char no-undo.
def var ourcode as integer no-undo.
ourbank = comm-txb().
ourcode = comm-cod().

def var v-dat1 as date label "Период с..." init today no-undo.
def var v-dat2 as date label "Период по..." init today no-undo.
def var v-rnn as char label "РНН" init ? format 'x(12)' no-undo.
def var v-s1  as decimal label "Сумма с..." format "z,zzz,zzz,zzz,zz9.99" init 0 no-undo.
def var v-s2  as decimal label "Сумма по..." format "z,zzz,zzz,zzz,zz9.99" init 999999999 no-undo.

define frame inframe
       v-dat1 v-dat2 skip
       v-rnn format 'x(12)' skip
       v-s1 skip
       v-s2
     with row 4 side-labels centered.

update v-dat1 v-dat2 
       v-rnn 
       v-s1 
       v-s2
       with centered side-labels frame inframe.

hide frame inframe.

form 
     commonpl.date label "Дата"
     commonpl.dnum label "N.док." format 'zzzzzz9' skip
     commonpl.sum label "Сумма" 
     commonpl.uid label "Кассир"
     commonpl.deluid label "Было удалено" skip
     commonpl.rnn  label "PHH" format 'x(12)' skip
     commonpl.joudoc label "Проводки - на АРП" format "x(10)"
     commonpl.comdoc label "комиссия" format "x(10)"
     commonpl.rmzdoc label "RMZ" format "x(10)"
     commonpl.fioadr label "ФИО и адрес" format "x(65)"
     with row 2 centered side-labels frame dispframe.

  if v-rnn = ? then
    for each commonpl where commonpl.txb = ourcode and
                      commonpl.date >= v-dat1 and
                      commonpl.date <= v-dat2 and
                      commonpl.sum >= v-s1 and commonpl.sum <= v-s2 and commonpl.grp = 15
                      no-lock.
    displ commonpl.date commonpl.dnum commonpl.sum  commonpl.uid commonpl.deluid commonpl.rnn commonpl.joudoc commonpl.comdoc commonpl.fioadr commonpl.rmzdoc
             with frame dispframe.
             pause.
    end.           
  else
    for each commonpl where commonpl.txb = ourcode and
                      commonpl.rnn = v-rnn and
                      commonpl.date >= v-dat1 and
                      commonpl.date <= v-dat2 and
                      commonpl.sum >= v-s1 and commonpl.sum <= v-s2 and commonpl.grp = 15
                      no-lock.
    displ commonpl.date commonpl.dnum commonpl.sum  commonpl.uid commonpl.deluid commonpl.rnn commonpl.joudoc commonpl.comdoc commonpl.fioadr commonpl.rmzdoc
             with frame dispframe.
             pause.
    end.

 pause 0.
displ "Нажмите F4 для выхода" with row 17 centered overlay frame fend title "Конец поиска".

{wait.i}
hide frame fend. pause 0.
