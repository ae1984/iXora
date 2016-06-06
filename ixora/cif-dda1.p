/* cif-dda1.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Создает/изменяет DDA тех. овердрафт
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.6.1.1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        18.01.02 anonymous - При открытии технического оведрафта идет проверка на сумму прогнозных платежей
        07.04.03 sasco - комиссия за открытие овердрафта (2 * ставка REFIN).
        24.09.03 sasco - овердрафт берется из тарификатора sysc."MINRFN".inval (должен быть = 216 тариф)
        03.11.03 marinav - оставлена возможность только технического оведрафта
        01.09.04 dpuchkov - добавил ограничение доступа на CIF
        08.09.04 dpuchkov - перекомпиляция.
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        01.07.2005 saltanat - Выборка льгот по счетам.
        21.10.2005 dpuchkov - запретьл редактировать % ставку ТЗ 151.
        07.02.2005 dpuchkov - Добавил проверку - предупреждение на статус C 
*/

{mainhead.i "CAM"}
{yes-no.i}

def var h-aaa like aaa.aaa NO-UNDO.
def var s-cif like cif.cif NO-UNDO.
def var v-lgr like lgr.lgr NO-UNDO.
def var dss as dec NO-UNDO.
def var v-ost as dec NO-UNDO.
def var ans as log NO-UNDO.

def buffer b-aaa for aaa.
def var qaaa like aaa.aaa NO-UNDO.

define new shared variable s-jh as int.
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.

{cif-dda1.f}

repeat:
update h-aaa with frame a side-label centered. 
find aaa where aaa.aaa eq h-aaa no-lock no-error.
if available aaa then do :
    find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
    if lgr.led ne "DDA" then do:
        message "Счет не типа DDA".
        pause 5.
    end.
    else do:
        find b-aaa where b-aaa.aaa eq aaa.craccnt no-lock no-error.
        if not available b-aaa then do:
            message "Нет парного счета типа ODA". 
            pause 5.
        end.
        else
        if available b-aaa and b-aaa.sta = "C"  then do:
            message "Нет парного счета типа ODA". 
            pause 5.
        end.
        else leave.
    end.
end.
else do:
 message "Счет не найден".
 pause 5.
end.
end.

if keyfunction(lastkey) eq "end-error" then return.





find last cifsec where cifsec.cif = aaa.cif no-lock no-error.
if avail cifsec then
  do:
     find last cifsec where cifsec.cif = aaa.cif and cifsec.ofc = g-ofc no-lock no-error.
     if not avail cifsec then
     do:
        message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
        create ciflog.
        assign
          ciflog.ofc = g-ofc
          ciflog.jdt = today
          ciflog.cif = aaa.cif
          ciflog.sectime = time
          ciflog.menu = "1.6.1.1 Настройка файла овердрафта".
          return.
     end.
     else
     do:
        create ciflogu.
        assign
          ciflogu.ofc = g-ofc
          ciflogu.jdt = today
          ciflogu.sectime = time
          ciflogu.cif = s-cif
          ciflogu.menu = "1.6.1.1 Настройка файла овердрафта".
     end.
  end.




def var MIN_REFIN as decimal format "-z,zzz,zzz,zz9.99" NO-UNDO.
def var RFN_RATE  as decimal format "-z,zzz,zzz,zz9.99" NO-UNDO.
def var AVL_SUM   as decimal format "-z,zzz,zzz,zz9.99" NO-UNDO.
def var COM_SUM   as decimal format "-z,zzz,zzz,zz9.99" NO-UNDO.
def var OLD_COM   as decimal format "-z,zzz,zzz,zz9.99" NO-UNDO.
def var NEW_COM   as decimal format "-z,zzz,zzz,zz9.99" NO-UNDO.
def var RFN_QTY   as decimal format "-z,zzz,zzz,zz9.99" NO-UNDO.
def var RFN_TARIF as character NO-UNDO.
def var TAKE_COM  as logical NO-UNDO.


/* - - - - - - - - - - - - - - - - - - - - */
function CALC_REFIN returns decimal (s0 as decimal).
    def var sm as decimal NO-UNDO.
    if s0 = 0.0 then return 0.0.
    sm = TRUNCATE (TRUNCATE (s0 * RFN_QTY * RFN_RATE / 36500, 3), 2).
    if sm = 0 then return 0.0.
              else if sm > MIN_REFIN then return sm.
                                     else return MIN_REFIN.
end function.
/* - - - - - - - - - - - - - - - - - - - - */




/* sasco -> get current avail. balance */
if lgr.led = "DDA" then AVL_SUM = aaa.cbal + b-aaa.cbal - aaa.hbal.
else 
if lgr.led = "ODA" then AVL_SUM = aaa.cbal + b-aaa.cbal - b-aaa.hbal.
else 
    AVL_SUM = aaa.cbal - aaa.hbal.
TAKE_COM = no.

/* - - - - - - - - - - - - - - - - - - - - */

{cif-dda1.f}

v-lgr = b-aaa.lgr.

/*
if not available aaa then do:
  bell.
  {mesg.i 8813}.
  undo, return.
end.

if aaa.cif ne s-cif then do:
  bell.
  {mesg.i 8813}.
  undo, return.
end.
*/

s-cif = aaa.cif.


find sysc where sysc.sysc = "MINRFN" no-lock no-error.
if not avail sysc then do:
   message "В SYSC не найдена переменная MINRFN!". pause 5.
   return.
end.
MIN_REFIN = sysc.deval.
if sysc.inval <> 0 then RFN_TARIF = string (sysc.inval).
                   else RFN_TARIF = "216".

find last taxrate where taxrate.taxrate = "RFN" and 
                        taxrate.regdt <= g-today
                        no-lock no-error.
if not avail taxrate then do:
   message "Не установлена ставка REFIN!". pause 5.
   return.
end.
RFN_RATE = TRUNCATE (taxrate.val[12], 2).

/* сколько ставок рефинансирования по умолчанию ... */
find tarif2 where tarif2.str5 = RFN_TARIF 
              and tarif2.stat = 'r' no-lock no-error.
if available tarif2 then RFN_QTY = tarif2.ost.
                    else RFN_QTY = 2.

/* исключения по тех. овердрафту... */
find first tarifex where tarifex.cif = s-cif and tarifex.str5 = RFN_TARIF 
                     and tarifex.stat = 'r' no-lock no-error.
if available tarifex then RFN_QTY = tarifex.ost.

/* 01/07/2005 saltanat - Добавлена выборка исключений по счетам, с учетом неснижаемого остатка по комиссиям 105, 419 */
{curs_conv.i}
find first tarifex2 where tarifex2.aaa = h-aaa and tarifex2.cif = s-cif
                      and tarifex2.str5 = RFN_TARIF and tarifex2.stat = 'r' no-lock no-error.
if available tarifex2 then do:
   find cif where cif.cif = aaa.cif no-lock no-error.
   if (avail cif and cif.type = 'p') and (tarifex2.str5 = '105' or tarifex2.str5 = '419') and tarifex2.nsost ne 0 then do:
      if konv2usd(AVL_SUM,aaa.crc,g-today) < tarifex2.nsost then
         RFN_QTY = tarifex2.ost.
      else RFN_QTY = 0.   
   end.
   else RFN_QTY = tarifex2.ost.
end.                     
/* 01/07/2005 saltanat - Добавлена выборка исключений по счетам, с учетом неснижаемого остатка по комиссиям 105, 419 */

run kcmr-fr1(input h-aaa, output dss).

qaaa = h-aaa.
if aaa.craccnt ne "" then find b-aaa where b-aaa.aaa eq aaa.craccnt
exclusive-lock no-error .
if not available b-aaa then aaa.craccnt = "".
                v-lgr = b-aaa.lgr.
                display             
                aaa.aaa
                aaa.cif
                aaa.rate
                aaa.pri
                aaa.craccnt
                v-lgr
                b-aaa.rate
                b-aaa.pri
                b-aaa.opnamt
                b-aaa.cbal
                with frame ddaoda.

find lgr where lgr.lgr eq b-aaa.lgr no-lock.
if lgr.lookaaa eq true then
/*update b-aaa.svc with frame ddaoda.*/
b-aaa.svc = yes.
displ b-aaa.svc with frame ddaoda.
/* update b-aaa.rate with frame ddaoda. */

v-ost = b-aaa.opnamt.
if b-aaa.svc = yes then do:
   repeat:
          message 'Сумма прогнозных платежей для этого счета ' string(dss) .
          update b-aaa.opnamt with frame ddaoda.
          if b-aaa.opnamt > dss then b-aaa.opnamt = v-ost.
                                else leave. 
   end.
 
   /* sasco : если превышаем предыдущую сумму овердрафта, то снимем комиссию */
   if v-ost < b-aaa.opnamt then do:
   
      NEW_COM = CALC_REFIN (b-aaa.opnamt).
      OLD_COM = CALC_REFIN (v-ost).
      COM_SUM = NEW_COM - OLD_COM.
      
      /* если сумма комиссии не 0 ... */
      if COM_SUM > 0.0 then do:

         if (AVL_SUM - v-ost + b-aaa.opnamt) < COM_SUM then do:
             message "Вы не можете открыть овердрафт на сумму " + trim(string(b-aaa.opnamt)) + 
                     "~n потому что комиссия за открытие составит " + trim(string(COM_SUM)) +
                     "~n остатке на счете будет "  + trim(string(AVL_SUM - v-ost + b-aaa.opnamt - COM_SUM)) + " тенге" 
                     view-as alert-box title "".
             b-aaa.opnamt = v-ost.
         end.
         else do: /* разрешаем -> комиссия */
              if yes-no ("", "Итого: тех. офердрафт на сумму " + trim(string(b-aaa.opnamt)) + 
                         "~nкомиссия составит " + trim(string(COM_SUM)) + " тенге" +
                         "~nитоговый остаток на счете будет " + trim(string(AVL_SUM - v-ost + b-aaa.opnamt - COM_SUM)) + " тенге" + 
                         "~nВы уверены?") then TAKE_COM = yes.
                                          else b-aaa.opnamt = v-ost.
         end.
      end.
      else do:
              if yes-no ("", "Итого: тех. офердрафт на сумму " + trim(string(b-aaa.opnamt)) + 
                         "~n   без комиссии (исключение по клиенту) ! " +
                         "~nитоговый остаток на счете будет " + trim(string(AVL_SUM - v-ost + b-aaa.opnamt - COM_SUM)) + " тенге" + 
                         "~nВы уверены?") then TAKE_COM = no.
                                          else b-aaa.opnamt = v-ost.
      end.

   end.

   if v-ost <> b-aaa.opnamt then b-aaa.who = g-ofc.

end.
else 
    update b-aaa.opnamt with frame ddaoda.

    b-aaa.cbal = b-aaa.opnamt - b-aaa.dr[1] + b-aaa.cr[1].

    display b-aaa.cbal with frame ddaoda.
    pause 5.

/* sasco : транзакция по снятию комиссии */
if TAKE_COM and COM_SUM > 0.0 then do transaction:
   s-jh = 0.
   run trxgen ("UNI0047", vdel, string(COM_SUM) + vdel + aaa.aaa, "", "", output rcode, output rdes, input-output s-jh).
   if rcode <> 0 then do:
      message rcode rdes.
      undo, return.
   end.
   if s-jh = ? or s-jh = 0 then do:
      message "Invalid transaction number " s-jh.
      pause 5.
      undo, return.
   end.
   run vou_bank(2).
end.

