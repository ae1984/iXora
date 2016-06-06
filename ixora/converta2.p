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
        10.05.2004 nadejda  - исправлена ошибка - теперь новому счету присваивается aaa.nextint (дата для пересмотра ставки), а то раньше ставка менялась при изменении в таблице ставок
        20.05.2004 nadejda  - добавлена информация, является ли счет исключением по % ставке
                              добавлен параметр номера счета в вызов tdagetrate
        28.06.2004 nadejda  - установка искл. % ставки перенсена в cif-tda%.p, здесь запрещена.
        26.11.2004 dpuchkov - при конвертации дата открытия нового счета равна дате открытия конвертируемого счета.
        15.12.2004 dpuchkov - добавил shared переменные.
        27.04.2006 dpuchkov - запретил конвертацию старых депозитов в новые.
        05.06.2006 dpuchkov - добавил обработку ошибки если не найден период.
*/
        

def new shared var ch_date as date .
def new shared var ch_KS as char .




def shared var s-opnamt like aaa.opnamt.   

def shared var s-cif like cif.cif.   
def shared var s-aaa like aaa.aaa.
def shared var s-lgr like lgr.lgr.
def shared  var v-rate as decimal.
def shared var in_command as decimal .
def shared  Variable V-sel As Integer FORMAT "9" init 1.
def shared  variable st_period as integer initial 30.
def shared var v-usd like aaa.aaa.

def buffer b-aaa for aaa.
def buffer b-acvolt for acvolt.
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
         find b-acvolt   where b-acvolt.aaa = v-usd no-lock no-error.

         aaa.cla = b-aaa.cla. 

         aaa.nextint = b-aaa.nextint. /* 10.05.2004 nadejda */

         aaa.lstmdt = g-today.
         aaa.expdt = b-aaa.expdt. 
         aaa.pri = lgr.pri.
         
         aaa.payfre = b-aaa.payfre.
         if aaa.payfre = 1 then v-excl = yes.

         termdays = aaa.expdt - aaa.lstmdt + 1.

aaa.opnamt = s-opnamt.

   aaa.lstmdt = b-aaa.lstmdt.
   aaa.regdt = b-aaa.regdt.
   d-effect =  0.



                                                                
    d-effect = 0.


         display aaa.aaa aaa.cla aaa.lstmdt aaa.expdt aaa.pri 
                aaa.rate aaa.opnamt mbal v-excl d-effect with frame aaa.

/*
    if aaa.regdt <> g-today then do:
       message "Внимание: Дата открытия счета не равна текущему дню.".
       pause.
    end. */

/*   update aaa.lstmdt with frame aaa.
     update aaa.regdt  with frame aaa. */

 

/*       update aaa.opnamt with frame aaa. */

         run tdagetrate(aaa.aaa, aaa.pri, aaa.cla, g-today, aaa.opnamt, output aaa.rate).

def var v1 as decimal.
def var v2 as decimal.


if lgr.feensf = 9 then do:
    find last acvolt where acvolt.aaa = b-aaa.aaa  no-lock no-error.
    if avail acvolt then do:
       if acvolt.x7 = 1 then 
          run tdagetrate2(aaa.aaa, aaa.pri, aaa.cla, g-today, 7000000, output v1, output v2).
       else
          run tdagetrate2(aaa.aaa, aaa.pri, aaa.cla, g-today, aaa.opnamt, output v1, output v2).

       find last spred where spred.pri = aaa.pri and  spred.min_month <= b-aaa.cla and spred.max_month >= b-aaa.cla no-lock no-error.
       if avail spred then do:
          aaa.rate = round(v1 + ((v2 - v1) / 5) * (integer(acvolt.prim2) + ((b-aaa.cla - spred.min_month) * (1 / (spred.max_month - spred.min_month)))),1).
       end.
    end.
end.

if lgr.feensf = 1 or lgr.feensf = 2 or lgr.feensf = 3 or lgr.feensf = 4 or lgr.feensf = 5 or lgr.feensf = 7 then do:
     find last acvolt where acvolt.aaa = aaa.aaa exclusive-lock no-error.
     if not avail acvolt then do:
        create acvolt.
               acvolt.aaa = aaa.aaa.
     end.
          acvolt.x1 = b-acvolt.x1.
          acvolt.x2 = b-acvolt.x2.
          acvolt.x3 = b-acvolt.x3.
          if lgr.feensf = 5 then do:
             if aaa.crc = 1 then acvolt.x4 = "10". else
             if aaa.crc = 2 then acvolt.x4 = "5".  else
             if aaa.crc = 3 then acvolt.x4 = "4".     

          end.
          if lgr.feensf = 7 then do:
              run tdagetrate(aaa.aaa, aaa.pri, "18", g-today, aaa.opnamt, output aaa.rate).  
          end.


end.


/*Эффективная ставка*/
def var v-sum as deci no-undo.
def var v-srok as integer no-undo.
def var v-rt as deci no-undo.
def var v-rdt as date no-undo.
def var v-pdt as date no-undo.
def var v-komf as deci no-undo. /* комиссия в фонд покрытия кредитных рисков */
def var v-komv as deci no-undo. /* комиссия за ведение счета */
def var v-komr as deci no-undo. /* комиссия за рассмотрение заявки */
def var v-er as deci no-undo.
def var v-lgr as char.

    v-lgr = lgr.lgr. 
    v-sum = aaa.opnamt.
    v-srok = aaa.cla.
    v-rt = aaa.rate.
    v-rdt  = aaa.regdt.

    run er_depf(v-lgr, v-sum,v-srok,v-rt,v-rdt,v-rdt, 0, 0, 0,output v-er).

    d-effect = v-er.
    acvolt.x2 = string(d-effect).



         mbal = aaa.opnamt * (1 + aaa.rate * termdays / aaa.base / 100).
         disp aaa.rate mbal d-effect with frame aaa.
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

