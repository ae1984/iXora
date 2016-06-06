/* cif-new2.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        27.08.2003 nadejda - добавила печать уведомления для группы 420
        24.05.2004 dpuchkov - добавил переменную для получения информации о нажатии кнопки фрейма
        09.12.2004 dpuchkov - Добавил фомирование check листа
        28.02.2005 tsoy     - Если ИП то комиссия другая
        31.05.2005 dpuchkov - Добавил возможность проставления сроков аренды и типы сейфовых ячеек
        06.07.2005 dpuchkov - добавил формирование уведомления в налоговый комитет при закрытии счета
        28.11.2005 dpuchkov - добавил условия открытия депозитов юридических лиц.
        07/02/2006 marinav  - другой тариф для валютных счетов ИП
        27.02.2006 dpuchkov - закомментарил по сейфовым ячейкам.
        24.08.2006 ten      - добавил prit-dog1 для печати данных на депозитных бланках, разделил для депозитов вид вывода данных в word
        13.02.2008 id00004  - запретил вызов carddepo
        15.04.2009 galina - добавила глобальную переменную v-aaa9
        17.04.2009 galina - записываем дату открытия 20-тизначного депозитного счета в поле aaa.dtpay до 02/11/2009
        11/11/2009 galina - убрала ссылку на дату 02/11/2009
        04.05.2010 marinav - ввод тарифа 023 за доп счет
        24/01/2011 evseev - отменил формирование уведомления в НК в формате word (стр322-326)
        27/08/2011 evseev - убрал печать старых договоров и заполенине subcod. тз-1063
        06/02/2012 dmitriy - добавил автоматическую рассылку для акцепта (ТЗ 1076)
        07/02/2012 dmitriy - для всех филиалов кроме ЦО и АФ исключил из списка рассылки Мираеву И.
        11/03/2012 dmitriy - исключил из списка рассылки Мусабекова А.
        29/05/2012 id00810 - изменила условие печати check листа (не печатать для новых групп по ПК 138,139,140)
        13.05.2013 evseev - tz-1828
        23.05.2013 evseev - tz-1844
*/

def new shared var ch_date as date .
def new shared var ch_KS as char .
def shared var v-aaa9 as char.
def var is_IP as logical no-undo.

def var imonth as integer no-undo.
def var iday as integer no-undo.
def var iyear as integer no-undo.
def var dsum as decimal decimals 2 no-undo.
def var i1 as integer no-undo.
def var lastdate as date no-undo.
def var d_dt as date no-undo.
def var iRealMonth as integer no-undo.
def var j as integer no-undo.
 def var iiday   as integer no-undo.
 def var iimonth as integer no-undo.
 def var iiyear  as integer no-undo.

def var v-tar as char no-undo.

{get-dep.i}

define frame fr_list
   ch_KS  label  "Введите номер КС" format "x(20)" skip
   ch_date label "Введите дату    " skip
with side-labels centered row 6.

def shared var s-cif like cif.cif.
def shared var s-aaa like aaa.aaa.
def shared var s-lgr like lgr.lgr.
def shared  var v-rate as decimal.
def shared var in_command as decimal .
def shared  Variable V-sel As Integer FORMAT "9" init 1.
def shared  variable st_period as integer initial 30.
def shared var s-okcancel as logical initial False.

def var ourbank  as cha no-undo.
define buffer bb-sysc for sysc.
find last bb-sysc where bb-sysc.sysc = "JUR" no-lock no-error.


{global.i}
/*{print-dolg.i}*/
def var dok2 as char format "x(36)" extent 5 initial
             [" 1. Оплатить со счета        ",
              " 2. Дополнительный счет      ",
              " 3. Льготный тариф _________ ",
              " 4. Оплачено наличными       ",
              " 5. Бесплатно                "].

form skip(1) dok2[1] skip dok2[2] skip dok2[3] skip dok2[4] skip dok2[5] with frame m2 centered title "выберите тип оплаты комиссии " overlay no-labels row 10.

               find sysc where sysc.sysc = "branch" no-lock no-error.
               find cif where cif.cif = s-cif exclusive-lock no-error.
               find aaa where aaa.aaa eq s-aaa exclusive-lock no-error.

               find lgr where lgr.lgr eq s-lgr exclusive-lock no-error.
               find led where led.led eq lgr.led exclusive-lock no-error.
               find crc where crc.crc = lgr.crc no-lock no-error.

               is_IP = false.

               find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "secek" no-lock no-error.
               if sub-cod.ccode = "9" and cif.cgr = 403 then do:
                  is_IP = true.
               end.


               if cif.type = 'b' and s-aaa <> ""
               then do:
                    hide message no-pause.
                    {print-dolg4.i }
                    hide all.
                    aaa.penny = in_command.   /*Величина Комиссии*/
                    aaa.vip = V-sel.      /*  код выбранного пункта меню  */
               end.


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
               if lgr.lookaaa eq true
                then do:

                    if lookup(lgr.lgr, bb-sysc.chval) = 0 then do:
                                    {mesg.i 8807} update aaa.rate format "zzzz.9999".
                    end.

               end.
               if led.prgadd ne "" then
               do:
                  if lookup(lgr.lgr, bb-sysc.chval) = 0 then do:
      	              run value(led.prgadd).
      	          end.
      	          else
                      run cif-cdanew.
               end.

               if keyfunction(lastkey) ne "end-error"
               then do:
                st_period = 0.





                run stnacc(aaa.cif, aaa.aaa, st_period).
                if lookup(s-lgr,"A22,A23,A24,A01,A02,A03,A04,A05,A06,A38,A39,A40") = 0  then do:
                   run subcod(s-aaa,"CIF").
                end.

                if (lgr.led = "CDA" or lgr.led = "TDA" ) and (lookup(s-lgr,"A22,A23,A24,A01,A02,A03,A04,A05,A06,A38,A39,A40") = 0)
                then do:
/*                   run carddepo.*/
                   def button btn-yes   label  "  Да  ".
                   def button btn-exit  label  "  Нет  ".
                   def frame frame2
                     skip(1) btn-yes btn-exit
                     with centered title "Печатать?" row 5 .
                   on choose of btn-yes
                   do:
                      if (aaa.lgr = '415' or aaa.lgr = '413') then do:
                         s-okcancel = True.
                         run prit_dog1(s-aaa, 1).
                      end.
                      else
                      if (aaa.lgr = 'F37' or aaa.lgr = 'F38' or aaa.lgr = 'F39' or aaa.lgr = 'F40' or aaa.lgr = 'F41' or aaa.lgr = 'F42') then do:
                         s-okcancel = True.
                         run prit_dog1(s-aaa, 2).
                      end.
                      else
                      if aaa.lgr begins "I" and int(substring(aaa.lgr,2)) >= 50 then do:
                         s-okcancel = True.
                         run prit_dog1(s-aaa, 3).
                      end.
                      else
                      if (aaa.lgr = 'I19' or aaa.lgr = 'I20' or aaa.lgr = 'I21') then do:
                         s-okcancel = True.
                         run prit_dog1(s-aaa, 4).
                      end.

                      else do:
                         s-okcancel = True.
                         run prit_dog(s-aaa).
                      end.
                   end.
                   on choose of btn-exit do: s-okcancel = False.  pause 0 no-message. end.
                   enable all with frame frame2.
                   wait-for choose of btn-exit.
                end.

               if aaa.lgr = '397' or aaa.lgr = '396' or aaa.lgr = '422' or aaa.lgr = '431' or aaa.lgr = '402'
                       or aaa.lgr = '400' or aaa.lgr = '401' or aaa.lgr = '403' or aaa.lgr = '437' or aaa.lgr = '427'
                then   run prit_gar(aaa.aaa,1).


               find sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = s-cif and sub-cod.d-cod = "clnsts" no-lock no-error.


               if (avail sub-cod and sub-cod.ccode = "0") or  (aaa.lgr begins '1' and aaa.lgr < '138' and aaa.lgr > '140') or aaa.lgr = '320' or aaa.lgr = '392' or aaa.lgr = '393' or aaa.lgr = '410'
                       or aaa.lgr = '411' or aaa.lgr = '412' or aaa.lgr = '420'

               then
               do:
                 find sysc where sysc.sysc = "ourbnk" no-lock no-error .
                 if avail sysc then
                     ourbank = sysc.chval.
                 else ourbank = "".

                 if get-dep(g-ofc, g-today) = 1 and ourbank <> 'TXB00' then
                    run check_list.
               end.

       end.

find first cmp no-lock no-error.

if cif.crg = "" then do:
    for each ofc where ofc.exp[1] matches "*P00082*" or ofc.exp[1] matches "*P00121*" or ofc.exp[1] matches "*P00136*" or ofc.exp[1] matches "*P00174*" or ofc.exp[1] matches "*P00033*"
    no-lock:
        if ofc.ofc = "id00801" and cmp.code > 0 and cmp.code < 16 then next. /* Пропускаем Мираеву И. на всех филиалах кроме АФ и ЦО */
        if ofc.ofc = "id00544" then next. /* Пропускаем Мусабекова А. */
        else run mail(ofc.ofc + "@metrocombank.kz", "METROCOMBANK <abpk@metrocombank.kz>", "Необходим акцепт", "Необходим акцепт: код " + s-cif + " " + trim(trim(cif.prefix) + " " + trim(cif.name)), "0", "", "").
    end.
end.


Procedure DayCount. /* возвращает количество дней, месяцев, лет за период */
def input parameter a_start  as date .
def input parameter a_expire as date .
def output parameter iiyear  as integer .
def output parameter iimonth as integer .
def output parameter iiday   as integer .

def var vterm as inte no-undo.
def var e_refdate as date no-undo.
def var t_date as date no-undo.
def var years as inte initial 0 no-undo.
def var months as inte initial 0 no-undo.
def var days as inte initial 0 no-undo.
def var i as inte initial 0 no-undo.

def var e_fire as logical init False no-undo.
def var t-days as date no-undo.
def var e_date as date no-undo.
iiday = 0. iiyear = 0. iimonth = 0.

e_refdate = a_start.

if a_start = a_expire then do: return. end.

do e_date = a_start to a_expire :

   iiday = iiday + 1.

   if day(e_date) = day(e_refdate) and e_date <> a_start then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   /* февраль высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) = 0) and ( day(e_refdate) = 30 or day(e_refdate) = 31) and (day(e_date) = 29) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   /* февраль не высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) <> 0) and ( day(e_refdate) = 30 or day(e_refdate) = 30 or day(e_refdate) = 31)  and (day(e_date) = 28) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   if iimonth = 12 then do:
      iiyear = iiyear + 1.
      iimonth = 0.
      iiday = 0.
   end.
end.

    iiday = iiday - 1.
    if iiday < 0 then iiday = 0.

End procedure.






