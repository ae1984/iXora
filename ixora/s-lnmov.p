/* s-lnmov.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        Перенос %% и штрафов, начисленных за балансом, в баланс
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        4.1.1 верхнее меню
 * AUTHOR
        06.02.2006 natalya D.
 * CHANGES
        04.04.2006 Natalya D. - добавила печать ордера
        13.07.2006 Natalya D. - добавлена проверка юзера на наличие у него пакета прав, разрешающих проведение транзакций
        12.01.2009 galina - добавила обработку "F4" для фрейма info и обработку нажатия btn2
        28/10/2013 Luiza  - ТЗ 1937 конвертация депозит lon0115

*/



{global.i}
{lonlev.i}
def shared var s-lon like lon.lon.
define new shared var s-jh  like jh.jh.
def var v-bal4 like jl.dam no-undo.
def var v-bal5 like jl.dam no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def var s-glremx as char extent 5.
def var vdel as char initial "^".
def var v-param as char no-undo.
def var v-crc4 like crc.code no-undo.
def var v-crc5 like crc.code no-undo.
def var v-choose as log no-undo.
def var v-amt as dec no-undo.
def var ja as log no-undo.
def var v-lev as int no-undo.
def var vop  as int format "z".

def temp-table t-wrk no-undo
       field acc like lon.lon
       field crc like lon.crc      column-label "Вал."
       field lev like trxbal.level column-label "Ур."
       field dr  like trxbal.dam   column-label "Дебет"
       field cr  like trxbal.cam   column-label "Кредит"
       field ost like trxbal.dam   column-label "Остаток" .

DEFINE VARIABLE v-method AS char FORMAT "x(72)"
VIEW-AS TEXT.
def button btn1 label "Ok".
def button btn2 label "Cancel".
def frame ln1 v-method skip
     btn1 at 10 btn2 at 30 with centered no-label.

empty temp-table t-wrk.

for each trxbal where trxbal.acc = s-lon and trxbal.subled = 'LON' and trxbal.level = 4 no-lock.
    if trxbal.dam - trxbal.cam = 0 then next.
    create t-wrk.
           t-wrk.acc = s-lon.
           t-wrk.crc = trxbal.crc.
           t-wrk.lev = trxbal.level.
           t-wrk.dr  = trxbal.dam.
           t-wrk.cr  = trxbal.cam.
           t-wrk.ost = trxbal.dam - trxbal.cam.
end.
for each trxbal where trxbal.acc = s-lon and trxbal.subled = 'LON' and trxbal.level = 5 no-lock.
    if trxbal.dam - trxbal.cam = 0 then next.
    message "5 lev" view-as alert-box.
    create t-wrk.
           t-wrk.acc = s-lon.
           t-wrk.crc = trxbal.crc.
           t-wrk.lev = trxbal.level.
           t-wrk.dr  = trxbal.dam.
           t-wrk.cr  = trxbal.cam.
           t-wrk.ost = trxbal.dam - trxbal.cam.
end.

def query q1-wt for t-wrk scrolling.
DEFINE BROWSE wt-brws QUERY q1-wt
  DISPLAY
  t-wrk.lev t-wrk.crc t-wrk.dr t-wrk.cr t-wrk.ost /*with 5 down.*/

  WITH  8 DOWN TITLE "Information" NO-ASSIGN SEPARATORS.

def frame info
   wt-brws  With no-box width 85.
   .

open query q1-wt for each t-wrk .

ON go OF wt-brws IN FRAME info or return OF wt-brws IN FRAME info DO:
    /*GET CURRENT q1-wt no-LOCK.
    v-lev = t-wrk.lev.*/
    find first t-wrk no-lock no-error.
    if avail t-wrk then do:
       GET CURRENT q1-wt no-LOCK.
       v-lev = t-wrk.lev.
       v-choose = yes.
    end.
    apply "END-ERROR" to browse wt-brws.
end.

on "end-error" of frame info do:
  hide frame info.
end.

v-choose = no.
ENABLE wt-brws WITH FRAME info.
WAIT-FOR END-ERROR OF BROWSE wt-brws.
disable all.
if v-choose then do :

   v-method = "Перенести сумму,начисленную за балансом,в баланс?".

   ja = no.
   on choose of btn1 in frame ln1 do :
     ja = yes.
   end.

   on choose of btn2 in frame ln1 do :
     hide frame info.
     hide frame ln1.
   end.

   displ v-method WITH FRAME ln1.
   ENABLE btn1 btn2 WITH FRAME ln1.

   wait-for choose of btn1 in frame ln1
   or choose of btn2 in frame ln1 focus btn2.

   for each t-wrk where t-wrk.lev = 4 no-lock.
     v-bal4 = v-bal4 + t-wrk.ost.
     find crc where crc.crc = t-wrk.crc no-lock no-error.
     v-crc4 = crc.code.
   end.

   for each t-wrk where t-wrk.lev = 5 no-lock.
     v-bal5 = v-bal5 + t-wrk.ost.
     find crc where crc.crc = t-wrk.crc no-lock no-error.
     v-crc5 = crc.code.
   end.
if ja then do :

   if (v-bal5 > 0) and (v-lev = 5) then do:

                    if v-bal5 ne 0 then
                         s-glremx[1] = "Сумма погашаемого забалансового штрафа" +
                         trim(string(v-bal5,">>>,>>>,>>9.99-"))
                         + " " + v-crc5.
                       else s-glremx[1] = "".

                    v-param = string(v-bal5) + vdel + s-lon + vdel +
                              s-glremx[1] + vdel + string(v-bal5).


                    s-jh = 0.
/*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
                   run usrrights.
                   if return-value = '1' then
                       run trxgen ("lon0119", vdel, v-param, "lon" ,s-lon , output rcode,
                                   output rdes, input-output s-jh).
                   else do:
                     message "У Вас нет прав для создания транзакции!"
                          view-as alert-box.
                      return "exit".
                   end.
/*end*/
                   if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                   end.

                   run lonresadd(s-jh).

                message s-jh view-as alert-box buttons ok.
                find jh where jh.jh eq s-jh no-lock no-error.
                repeat:
                   pause 0.
                   vop = 0.
                   message " 1) Печать"  update vop.
                   if vop eq 1 then do :
                      hide all.
                      run x-jlvou.
                      if jh.sts ne 6 then do :
                         for each jl of jh :
                           jl.sts = 5.
                           find sysc where sysc.sysc eq "CASHGL" no-lock.
                           if avail sysc then do:
                             if jl.gl eq sysc.inval then do:
                                find prev cashofc where cashofc.ofc eq g-ofc and
                                      cashofc.sts eq 2 /* curr.value */ and
                                      cashofc.crc eq jl.crc and
                                      cashofc.whn eq g-today exclusive-lock
                                      no-error.
                                if avail cashofc then cashofc.amt = cashofc.amt + jl.dam - jl.cam.
                                release cashofc.
                             end.
                           end.

                         end.
                        jh.sts = 5.
                      end.
                      {x-jlvf.i}
                   end. /* 3. Print */

                end.
   end.

   if (v-bal4 > 0) and (v-lev = 4) then do:

                    if v-bal4 ne 0 then
                          s-glremx[2] = "Сумма погашаемых забалансовых %% " +
                          trim(string(v-bal4,">>>,>>>,>>9.99-")) + " " + v-crc4.
                       else s-glremx[2] = "".

                    v-param = string(v-bal4) + vdel + s-lon + vdel +
                              s-glremx[2] + vdel + string(v-bal4).

                    s-jh = 0.
/*Natalya D. - перед формированием транзакции проверяет юзера на соответствие пакету доступа*/
                   run usrrights.
                   if return-value = '1' then do:
                       /* для lon0115 */
                       if v-crc4 = "KZT" then v-param = "0" + vdel + s-lon + vdel +
                              s-glremx[2] + vdel + "0" + vdel + string(v-bal4) + vdel + s-lon + vdel +
                              s-glremx[2] + vdel + string(v-bal4).
                       else v-param = string(v-bal4) + vdel + s-lon + vdel +
                              s-glremx[2] + vdel + string(v-bal4) + vdel + "0" + vdel + s-lon + vdel +
                              s-glremx[2] + vdel + "0".
                       run trxgen ("lon0115", vdel, v-param, "lon" ,s-lon , output rcode,
                                   output rdes, input-output s-jh).
                   end.
                   else do:
                     message "У Вас нет прав для создания транзакции!"
                          view-as alert-box.
                      return "exit".
                   end.
/*end*/
                   if rcode ne 0 then do:
                      message rdes.
                      pause 1000.
                      next.
                   end.

                   run lonresadd(s-jh).

                message s-jh view-as alert-box buttons ok.
                find jh where jh.jh eq s-jh no-lock no-error.
                repeat:
                   pause 0.
                   vop = 0.
                   message " 1) Печать"  update vop.
                   if vop eq 1 then do :
                      hide all.
                      run x-jlvou.
                      if jh.sts ne 6 then do :
                         for each jl of jh :
                           jl.sts = 5.
                           find sysc where sysc.sysc eq "CASHGL" no-lock.
                           if avail sysc then do:
                             if jl.gl eq sysc.inval then do:
                                find prev cashofc where cashofc.ofc eq g-ofc and
                                      cashofc.sts eq 2 /* curr.value */ and
                                      cashofc.crc eq jl.crc and
                                      cashofc.whn eq g-today exclusive-lock
                                      no-error.
                                if avail cashofc then cashofc.amt = cashofc.amt + jl.dam - jl.cam.
                                release cashofc.
                             end.
                           end.

                         end.
                        jh.sts = 5.
                      end.
                      {x-jlvf.i}
                   end. /* 3. Print */

                end.
   end.

end.

end.
return.








