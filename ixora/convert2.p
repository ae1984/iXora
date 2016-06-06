/* convert2.p
 * MODULE
        Клиентские счета
 * DESCRIPTION
        Присваивание параметров нового счета при конвертации депозита из одной валюты в другую
 * RUN
        
 * CALLER
        convert.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1-2
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        10.05.2004 nadejda - исправлена ошибка - теперь новому счету присваивается aaa.nextint (дата для пересмотра ставки), а то раньше ставка менялась при изменении в таблице ставок
        20.05.2004 nadejda - добавлена информация, является ли счет исключением по % ставке
                             добавлен параметр номера счета в вызов tdagetrate
        28.06.2004 nadejda - установка искл. % ставки перенсена в cif-tda%.p, здесь запрещена
        21.10.2004 dpuchkov - при конвертации нет проверки на дату окончания депозита  
        15.12.2004 dpuchkov - добавил new shared переменные ch_date и ch_KS.
*/
def new shared var ch_date as date .
def new shared var ch_KS as char .


def shared var s-cif like cif.cif.   
def shared var s-aaa like aaa.aaa.
def shared var s-lgr like lgr.lgr.
def shared  var v-rate as decimal.
def shared var in_command as decimal .
def shared  Variable V-sel As Integer FORMAT "9" init 1.
def shared  variable st_period as integer initial 30.
def shared var v-usd like aaa.aaa.

def buffer b-aaa for aaa.
def  var termdays as integer.
def  var  mbal as decimal.
def var d-prddate as date.

{global.i}
{print-dolg.i}

{cif-tda.f}

    
               find sysc where sysc.sysc = "branch" no-lock no-error.
               find cif where cif.cif = s-cif no-lock no-error.
               find aaa where aaa.aaa eq s-aaa exclusive-lock.

               find lgr where lgr.lgr eq s-lgr no-lock no-error.
               find led where led.led eq lgr.led no-lock no-error.
               find crc where crc.crc = lgr.crc no-lock no-error.

        /*Меню "Оплата комиссии за открытие счета - только для ЮЛ" - nataly*/
                     
               if cif.type = 'b' and s-aaa <> "" 
               then do:
                 hide message no-pause.
                 {print-dolg2.i }.
                 hide all.
                 aaa.penny = in_command.   /*Величина Комиссии*/
                 aaa.vip = V-sel.      /*  код выбранного пункта меню  */
               end.

               /*
               create aaa.
               aaa.aaa = s-aaa.
               */
               aaa.cif = s-cif.
               aaa.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
               aaa.gl = lgr.gl.
               aaa.lgr = s-lgr.
               if available sysc then aaa.bra = sysc.inval.
               aaa.regdt = g-today.
               aaa.stadt = g-today.
               aaa.stmdt = aaa.regdt - 1.
               aaa.tim = time .
               aaa.who = g-ofc.
               aaa.pass = lgr.type.
               aaa.pri = lgr.pri.
               aaa.rate = lgr.rate.
               aaa.complex = lgr.complex.
               aaa.base = lgr.base.
               aaa.sta = "N".
               aaa.minbal[1] = 9999999999999.99.
               aaa.crc = lgr.crc.
               aaa.base = lgr.base.
               aaa.grp = integer(lgr.alt).
               /* для сбоpа платы за счет для "X" клиентов */
               if cif.type EQ "X" then aaa.sec = true.
                                  else aaa.sec = false. 

               /* зачем это надо, если работает только для TDA, а по ним ставка берется по группе? */
               if lgr.lookaaa then do:
                  {mesg.i 8807} update aaa.rate format "zzzz.9999" . 
               end.
               /*********************/

        /*вывод фрейма с условиями по депозитам */

         find b-aaa   where b-aaa.aaa = v-usd no-lock no-error.
         aaa.cla = b-aaa.cla. 

         aaa.nextint = b-aaa.nextint. /* 10.05.2004 nadejda */

         aaa.lstmdt = g-today.
         aaa.expdt = b-aaa.expdt. 
         aaa.pri = lgr.pri.
         
         aaa.payfre = b-aaa.payfre.
         if aaa.payfre = 1 then v-excl = yes.

         termdays = aaa.expdt - aaa.lstmdt + 1.
         display aaa.aaa aaa.cla aaa.lstmdt aaa.expdt aaa.pri 
                aaa.rate aaa.opnamt mbal v-excl with frame aaa.
  
         update aaa.opnamt with frame aaa.
         run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, aaa.nextint, aaa.opnamt, output aaa.rate).
         mbal = aaa.opnamt * (1 + aaa.rate * termdays / aaa.base / 100).
         disp aaa.rate mbal with frame aaa.
          d-prddate = aaa.expdt.
         {cif-tda-excl.i}

               if keyfunction(lastkey) ne "end-error" 
               then do:
                st_period = 0.
               
                run stnacc(aaa.cif, aaa.aaa, st_period).
                run subcod(s-aaa,"CIF").

                if lgr.led = "CDA" or lgr.led = "TDA" 
                then do:
                   def button btn-yes   label  "  Да  ".
                   def button btn-exit  label  "  Нет  ".
                   def frame frame2
                     skip(1) btn-yes btn-exit
                     with centered title "Печатать?" row 5 .
                   on choose of btn-yes 
                   do: 
                       run prit_dog(s-aaa). 
                   end.
                   on choose of btn-exit pause 0 no-message. 
                   enable all with frame frame2.
                   wait-for choose of btn-exit.
                end.

               if aaa.lgr = '397' or aaa.lgr = '396' or aaa.lgr = '422' or aaa.lgr = '431' or aaa.lgr = '402' 
                       or aaa.lgr = '400' or aaa.lgr = '401' or aaa.lgr = '403' or aaa.lgr = '437' or aaa.lgr = '427'
                then   run prit_gar(aaa.aaa,1).

               if aaa.lgr begins '1' or aaa.lgr = '320' or aaa.lgr = '392' or aaa.lgr = '393' or aaa.lgr = '410' 
                       or aaa.lgr = '411' or aaa.lgr = '412' 
                then   run prit_sch(aaa.aaa,1).

                end.

