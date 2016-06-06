/* tdaget4.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Частичное изъятие сумм с депозитов "метро-VIP"
 * RUN
        вызов из процедуры
 * CALLER
        tdacls2.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU

 * AUTHOR
        31/12/99 pragma
 * CONNECT 
         bank
 * CHANGES 
         04.02.2009 id00004 Установил неснижаемый остаток для счета 199759966 на алмате (СЗ от Бояркиной И.Я)
*/

{mainhead.i}


def input parameter v-aaa like aaa.aaa.
def var d_1%    as decimal decimals 2. /* Сумма удерживаемая с 1 уровня  */
def var d_2%    as decimal decimals 2. /* Сумма удерживаемая со 2 уровня */   
def var d_3%    as decimal decimals 2. /* Сумма для выплаты на 1 уровень */
def var d-brate2 as decimal decimals 2 . /*ставка до востребования в sysc*/
def var d-tstart as date. 
def var d-tstart1 as date. 
def var e-fire as logi.
def var vdel    as char initial "^".
def var vparam as char.
def var rcode  as inte.
def var rdes   as char.
def var v-jh like jh.jh.
def var s-amt2  as decimal decimals 2.
def var s-amt11 as decimal decimals 2.
def var s-amt1  as decimal decimals 2.
def var i-out  as integer.
def var v-sumchkamt as decimal.
def var v-sum as decimal.
def var v-allsum as decimal.
def var d_sumfreez as decimal decimals 2.  /* Минимальный остаток на депозите   */
def var d_sumost as decimal decimals 2. /* Сумма остатка                        */
  def var t-iza as decimal decimals 2.    /* Сумма которую можно взять с взноса   */
def buffer b-crc for crc.


Function rDAY returns integer (input dt1 as date, input dt2 as date, input dt3 as date).
def var i as date.
def var f as integer.
do i = dt1 to dt3:
   if day(dt1) = 31 and  i >= dt2 then do:
     if lookup(string(month(i)),"3,5,10,12") <> 0 and day(i) = 1 then do:
        f = f + 1.
     end.
   end.

   if i >= dt2 and (day(dt1) = 30 or day(dt1) = 29) then do:
      if month(i) = 2 and day(i) = 28 then do: f = f + 1. end.
   end.

   if i >= dt2 and day(i) = day(dt1) then 
   do:
      f = f + 1. 
   end.
end.
   if f < 0 then f = 0.
   return f - 1.
End Function.



    find last aaa where aaa.aaa = v-aaa exclusive-lock no-error.
    if not avail aaa then do:
       message "не найден счет" aaa. pause. return.
    end.
    find last crc where crc.crc = aaa.crc no-lock no-error.
    find last lgr where lgr.lgr = aaa.lgr no-lock no-error.

    if aaa.sta = "E"  or aaa.sta = "C" then do:
       message "  Депозит уже закрыт  " view-as alert-box title "". return.
    end.



   if aaa.sta = "A"  or aaa.sta = "N"  then 
   do transaction:


      if g-today = aaa.regdt then do:
         aaa.opnamt = aaa.cr[1] - aaa.dr[1].
      end.



   find last aaa where aaa.aaa = v-aaa exclusive-lock no-error.
     if aaa.crc = 1  then do: find sysc "ratekz" no-lock no-error. if available sysc then d-brate2 = sysc.deval. end. 
     if aaa.crc = 2  then do: find sysc "rateus" no-lock no-error. if available sysc then d-brate2 = sysc.deval. end. 
     if aaa.crc = 3 then do: find sysc "rateeu" no-lock no-error. if available sysc then d-brate2 = sysc.deval. end.

   if not avail aaa then do:
      message "Не найден счет" aaa. pause. return.
   end.
 
   if aaa.opnamt = 0 then do:
      message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip " дата открытия не совпадает с взносом основной суммы или " skip " сделана неверная операция " skip " ПРОВЕРЬТЕ КОРРЕКТНОСТЬ СУММ И ВЫПОЛНИТЕ НАЧИСЛЕНИЕ % " view-as alert-box question buttons ok title "".
      return.
   end.

   find last acvolt where acvolt.aaa =  aaa.aaa exclusive-lock no-error.
   if not avail acvolt then do:
      message "Внимание счет" aaa.aaa "открыт НЕКОРРЕКТНО " skip "" view-as alert-box question buttons ok title "".
      return.
   end.



   v-sum = 0.
   update v-sum format 'z,zzz,zzz,zz9.99-' label 'Введите сумму частичного изъятия' with row 8 centered  side-label frame opt.



   /*проверка на допустимый лимит из настроек lgr*/
   if lgr.usdval = False then d_sumfreez = lgr.tlimit[1].
   else 
   do:
        find last b-crc where b-crc.crc = lgr.crc no-lock no-error.
        if avail b-crc then d_sumfreez = lgr.tlimit[1] / b-crc.rate[1].
   end.

if aaa.aaa = "199759966" and aaa.cif = "A11511" then d_sumfreez = 4483.

   if d_sumfreez > ((aaa.cr[1] - aaa.dr[1]) - v-sum ) then do:
      message "Минимально допустимый остаток " trim(string(d_sumfreez,'z,zzz,zz9.99-')) skip
              "----------------------------------------" skip
              "СУММА ИЗЪЯТИЯ НЕ ДОЛЖНА ПРЕВЫШАТЬ" trim(string((aaa.cr[1] - aaa.dr[1]) - d_sumfreez, 'z,zzz,zz9.99-')) view-as alert-box.
      return.
   end.



   message "ЧАСТИЧНОЕ ИЗЪЯТИЕ!" skip "ПОДТВЕРДИТЕ ЧАСТИЧНОЕ ИЗЪЯТИЕ." view-as alert-box question buttons yes-no title "" update v-ans as logical.
   if not v-ans then  return.

   for each aas where aas.aaa eq aaa.aaa and aas.ln <> 7777777  no-lock: 
       find sic of aas.
       display aas.sic sic.des label "НАИМЕНОВАНИЕ" FORMAT "X(20)"  aas.regdt LABEL "ДАТ.РЕГ." format "99/99/9999" aas.chkamt LABEL "СУММА" aas.payee format "x(20)"  with row 9  9 down  overlay  top-only centered title " СПЕЦИАЛЬНОЕ СОСТОЯНИЕ СЧЕТА (" + string(aas.aaa) + ")" frame aas.
   end.
   hide frame aas.






   d_sumost = v-sum.

   if d_sumost <= aaa.stmgbal then do:
      aaa.stmgbal = aaa.stmgbal - d_sumost.
      d_sumost = 0.
   end.
   else
   do:

      d_sumost = d_sumost - aaa.stmgbal.
      aaa.stmgbal = 0.
      if d_sumost < 0 then d_sumost = 0. 
      for each aad where aad.aaa = aaa.aaa and aad.who <> 'bankadm' exclusive-lock break by aad.regdt desc.
          t-iza = 0.
          if d_sumost > 0 and aad.sumg > 0 then do: /* если есть деньги*/
             t-iza = min(aad.sumg, d_sumost).      /* сумма изъятия */
             d_sumost = d_sumost - t-iza.          /* сумма остатка */
             aad.sumg = aad.sumg - t-iza.
             aad.dam = aad.dam + t-iza.
          end.
      end.
      if d_sumost > 0 then do:
         aaa.opnamt = aaa.opnamt - d_sumost.
      end.
   end.

   run tdaremhold(aaa.aaa, v-sum).





def var v-dbpath as char.
find sysc where sysc.sysc = "stglog" no-lock no-error.
v-dbpath = sysc.chval.
if substr (v-dbpath, length(v-dbpath), 1) <> "/" then v-dbpath = v-dbpath + "/".

    output to value(v-dbpath + "Deposit.log") append.
    put unformatted
        g-today " "
        string(time, "hh:mm:ss") " "
        userid("bank") format "x(8)" " "
        aaa.aaa " Частичное изъятие " v-sum " " g-ofc
        skip.
    output close.



   message "Произведена разблокировка суммы для частичного изъятия!".
   pause.

end.







