/* commpayc.p
 * MODULE
     Коммунальные платежи 
 * DESCRIPTION
     Процедура поиска коммунальных платежей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.2.10.7.6
 * AUTHOR
        03.12.02 pragma
 * CHANGES
     01.08.03 kanat Добавил новый параметр для выборки по платежам по имени плательщика с РНН = 000000000000 
     29.20.03 sasco Добавил запрос на F4 после завершения поиска
     14.06.04 kanat ДОбавил grp по АПК
     05.09.06 u00124 добавил прочие платежи Алматытелеком
*/

{comm-txb.i}
def var seltxb as int.
seltxb = comm-cod().

def var v-dat1 as date label "Период с..." init today.
def var v-dat2 as date label "Период по..." init today.
def var v-grp as integer label "Группа" init 1.
def var v-uid as char label "Офицер" init ?.
def var v-rnn as char label "РНН" init ? format 'x(12)'.
def var v-s1  as decimal label "Сумма с..." format "z,zzz,zzz,zzz,zz9.99" init 0.
def var v-s2  as decimal label "Сумма по..." format "z,zzz,zzz,zzz,zz9.99" init 999999999.
def var v-dnum like commonpl.dnum label "Номер документа" init ?.
def var v-accnt like commonpl.accnt label "Л/Счет" format ">>>>>>>>>9" init ?.
def var v-fioadr like commonpl.fioadr format "x(40)" init ?.
def var v-cha as char.

define frame inframe
       v-dnum v-grp help "F2 - ВЫБОР" skip
       v-uid skip
       v-dat1 v-dat2 skip             
       v-s1 skip
       v-s2 skip
       v-rnn format 'x(12)' 
       v-accnt 
       v-fioadr format 'x(40)'
       skip
     with row 4 side-labels centered.

on help of v-grp in frame inframe do:
   run sel ("Выберите из списка", "1. Ст. диагностики   |" +
                                  "3. АлматыТелеком     |" +
                                  "4. K`Cell / K-Mobile |" +
                                  "5. ИВЦ               |" +
                                  "6. Алсеко            |" +
                                  "7. Водоканал         |" + 
                                  "8. АПК               |" +
                                  "9. АлматыТелеком прочие").
   if return-value <> ? then do:
       case return-value:
          when "1" then v-cha = "1".
          when "2" then v-cha = "3".
          when "3" then v-cha = "4".
          when "4" then v-cha = "5".
          when "5" then v-cha = "6".
          when "6" then v-cha = "7".
          when "7" then v-cha = "8".
          when "8" then v-cha = "3".
          otherwise v-cha = ?.
       end.
       if v-cha <> ? then do:
          v-grp:screen-value = v-cha.
          v-grp = integer (v-grp:screen-value).
       end.
   end.
end.

update v-dnum v-grp v-uid v-dat1 v-dat2 v-s1 v-s2 v-rnn v-accnt v-fioadr
       with frame inframe.

hide frame inframe.

form 
     commonpl.date label "Дата" commonpl.dnum label "N.док." format 'zzzzzz9' commonpl.grp format "z9" skip
     commonpl.sum label "Сумма" skip
     commonpl.uid label "Кассир"
     commonpl.deluid label "Было удалено" skip
     commonpl.rnn label "PHH" format 'x(12)' skip
     commonpl.joudoc label "Зачисление на АРП" format "x(10)" 
     commonpl.comdoc label "комиссия" format "x(10)" 
     commonpl.rmzdoc label "RMZ" format "x(10)"
     commonpl.accnt label "Л/Счет" format ">>>>>>>>>9"
     commonpl.fioadr label "ФИО" format "x(40)"
     with row 2 centered side-labels frame dispframe.


form 
     commtk.date label "Дата" commtk.dnum label "N.док." format 'zzzzzz9' commtk.grp format "z9" skip
     commtk.sum label "Сумма" skip
     commtk.uid label "Кассир"
     commtk.deluid label "Было удалено" skip
     commtk.rnn label "PHH" format 'x(12)' skip
     commtk.joudoc label "Зачисление на АРП" format "x(10)" 
     commtk.comdoc label "комиссия" format "x(10)" 
     commtk.rmzdoc label "RMZ" format "x(10)"
     commtk.accnt label "Л/Счет" format ">>>>>>>>>9"
     commtk.fioadr label "ФИО" format "x(40)"
     with row 2 centered side-labels frame dispframe1.


if v-accnt <> ? then
do:
   if v-dnum = ? then do:
      if return-value <> "8" then do:
      for each commonpl where txb = seltxb and accnt = v-accnt and
                              date >= v-dat1 and
                              date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and
                              commonpl.grp = v-grp use-index accnt no-lock.
          displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
                with frame dispframe.
                pause.
      end.
      end.
      if return-value = "8" then do:
         for each commtk where commtk.txb = seltxb and commtk.accnt = v-accnt and commtk.date >= v-dat1 and commtk.date <= v-dat2 and commtk.sum >= v-s1 and commtk.sum <= v-s2 and
                                 commtk.grp = v-grp use-index accnt no-lock.
             displ commtk.date commtk.rnn  commtk.grp commtk.dnum commtk.uid commtk.deluid commtk.sum commtk.joudoc commtk.comdoc commtk.rmzdoc commtk.accnt commtk.fioadr with frame dispframe1.
                   pause.
         end.
      end.
   end.
   else
   do:
      if return-value <> "8" then do:
      for each commonpl where txb = seltxb and accnt = v-accnt and
                              date >= v-dat1 and
                              date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and
                              dnum = v-dnum and
                              commonpl.grp = v-grp use-index accnt no-lock .
          displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
                with frame dispframe.
                pause.
      end.
      end.
      if return-value = "8" then do:
         for each commtk where commtk.txb = seltxb and commtk.accnt = v-accnt and commtk.date >= v-dat1 and commtk.date <= v-dat2 and commtk.sum >= v-s1 and commtk.sum <= v-s2 and commtk.dnum = v-dnum and commtk.grp = v-grp use-index accnt no-lock.
             displ commtk.date commtk.rnn commtk.grp commtk.dnum commtk.uid commtk.deluid commtk.sum commtk.joudoc commtk.comdoc commtk.rmzdoc commtk.accnt commtk.fioadr with frame dispframe.
             pause.
         end.
      end.
   end.
end.
else do:  /* Если нет лицевого счета */

if  v-dnum <> ? then
do:                  
   if v-uid = ? then
   do:
      if return-value <> "8" then do:
         for each commonpl where txb = seltxb and date >= v-dat1 and date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.dnum = v-dnum and commonpl.grp = v-grp no-lock.
             displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr with frame dispframe.
             pause.
         end.
      end.
      if return-value = "8" then do:
         for each commtk where commtk.txb = seltxb and commtk.date >= v-dat1 and commtk.date <= v-dat2 and commtk.sum >= v-s1 and commtk.sum <= v-s2 and commtk.dnum = v-dnum and commtk.grp = v-grp no-lock.
             displ commtk.date commtk.rnn  commtk.grp commtk.dnum commtk.uid commtk.deluid commtk.sum commtk.joudoc commtk.comdoc commtk.rmzdoc commtk.accnt commtk.fioadr with frame dispframe1.
             pause.
         end.
      end.
   end.
   else 
   do:
      if return-value <> "8" then do:
         for each commonpl where txb = seltxb and date >= v-dat1 and date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.dnum = v-dnum and commonpl.uid = v-uid and commonpl.grp = v-grp no-lock.
             displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr with frame dispframe.
             pause.
         end.
      end.
      if return-value = "8" then do:
          for each commtk where commtk.txb = seltxb and commtk.date >= v-dat1 and commtk.date <= v-dat2 and commtk.sum >= v-s1 and commtk.sum <= v-s2 and commtk.dnum = v-dnum and commtk.uid = v-uid and commtk.grp = v-grp no-lock.
              displ commtk.date commtk.rnn  commtk.grp commtk.dnum commtk.uid commtk.deluid commtk.sum commtk.joudoc commtk.comdoc commtk.rmzdoc commtk.accnt commtk.fioadr with frame dispframe1.
              pause.
          end.
      end.
   end.
end.
else do:
if v-uid <> ? then
do:
   if v-rnn <> ? and v-fioadr = ? then do:
      if return-value <> "8" then do:
         for each commonpl where txb = seltxb and date >= v-dat1 and date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.uid = v-uid and commonpl.rnn = v-rnn and commonpl.grp = v-grp no-lock use-index rnn.
             displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr with frame dispframe.
             pause.
         end.
      end.
      if return-value = "8" then do:
         for each commtk where commtk.txb = seltxb and commtk.date >= v-dat1 and commtk.date <= v-dat2 and commtk.sum >= v-s1 and commtk.sum <= v-s2 and commtk.uid = v-uid and commtk.rnn = v-rnn and commtk.grp = v-grp no-lock use-index rnn.
             displ commtk.date commtk.rnn  commtk.grp commtk.dnum commtk.uid commtk.deluid commtk.sum commtk.joudoc commtk.comdoc commtk.rmzdoc commtk.accnt commtk.fioadr with frame dispframe1.
             pause.
         end.
      end.
   end.

   if v-rnn <> ? and v-fioadr <> ? then do:
    v-fioadr = "*" + v-fioadr + "*".
    for each commonpl where txb = seltxb and date >= v-dat1 and date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.uid = v-uid and
                           commonpl.rnn = v-rnn and 
                           commonpl.grp = v-grp and 
                           commonpl.fioadr matches v-fioadr no-lock.
       displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
             with frame dispframe.
             pause.
    end.
   end.


   if v-rnn = ? and v-fioadr = ? then do:
    for each commonpl where txb = seltxb and date >= v-dat1 and
                           date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.grp = v-grp and commonpl.uid = v-uid no-lock.
       displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
             with frame dispframe.
             pause.
    end.
   end.


   if v-rnn = ? and v-fioadr <> ? then do:
    v-fioadr = "*" + v-fioadr + "*".
    for each commonpl where txb = seltxb and date >= v-dat1 and
                           date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.grp = v-grp and commonpl.uid = v-uid and 
                           commonpl.fioadr matches v-fioadr no-lock.
       displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
             with frame dispframe.
             pause.
    end.
   end.

end.
else 
do:

   if v-rnn <> ? and v-fioadr = ? then do:
       if return-value <> "8" then do:
          for each commonpl where txb = seltxb and date >= v-dat1 and
                                 date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and
                                 commonpl.rnn = v-rnn and commonpl.grp = v-grp no-lock use-index rnn.
             displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
                   with frame dispframe.
                   pause.
          end.
       end.
       if return-value = "8" then do:
          for each commtk where commtk.txb = seltxb and commtk.date >= v-dat1 and
                                 commtk.date <= v-dat2 and commtk.sum >= v-s1 and commtk.sum <= v-s2 and
                                 commtk.rnn = v-rnn and commtk.grp = v-grp no-lock use-index rnn.
             displ commtk.date commtk.rnn commtk.grp commtk.dnum commtk.uid commtk.deluid commtk.sum commtk.joudoc commtk.comdoc commtk.rmzdoc commtk.accnt commtk.fioadr with frame dispframe1.
                   pause.
          end.
       end.
   end.

   if v-rnn <> ? and v-fioadr <> ? then do:
    v-fioadr = "*" + v-fioadr + "*".
    for each commonpl where txb = seltxb and date >= v-dat1 and
                           date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and
                           commonpl.grp = v-grp and 
                           commonpl.rnn = v-rnn and 
                           commonpl.fioadr matches v-fioadr no-lock use-index rnn.
       displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
             with frame dispframe.
             pause.
    end.
   end.


   if v-rnn = ? and v-fioadr = ? then do:
    if return-value <> "8" then do:
       for each commonpl where txb = seltxb and date >= v-dat1 and
                              date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.grp = v-grp no-lock.
          displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
                with frame dispframe.
                pause.
       end.
    end.
    if return-value = "8" then do:
       for each commtk where commtk.txb = seltxb and commtk.date >= v-dat1 and
                              commtk.date <= v-dat2 and commtk.sum >= v-s1 and commtk.sum <= v-s2 and commtk.grp = v-grp no-lock.
          displ commtk.date commtk.rnn commtk.grp commtk.dnum commtk.uid commtk.deluid commtk.sum commtk.joudoc commtk.comdoc commtk.rmzdoc commtk.accnt commtk.fioadr with frame dispframe1.
          pause.
       end.
    end.
   end.


   if v-rnn = ? and v-fioadr <> ? then do:
    v-fioadr = "*" + v-fioadr + "*".
    for each commonpl where txb = seltxb and date >= v-dat1 and
                           date <= v-dat2 and sum >= v-s1 and sum <= v-s2 and commonpl.grp = v-grp and 
                           commonpl.fioadr matches v-fioadr no-lock.
       displ commonpl.date commonpl.rnn  commonpl.grp commonpl.dnum commonpl.uid commonpl.deluid commonpl.sum commonpl.joudoc commonpl.comdoc commonpl.rmzdoc commonpl.accnt commonpl.fioadr
             with frame dispframe.
             pause.
    end.
   end.


end.
end.
end.

pause 0.
displ "Нажмите F4 для выхода" with row 17 centered overlay frame fend title "Конец поиска".

{wait.i}
hide frame fend. pause 0.
