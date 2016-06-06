/* x1-cash.p
 * MODULE
     Касса
 * DESCRIPTION
     Штамповка проводок
 * RUN
 * CALLER
 * SCRIPT
 * INHERIT
 * MENU
     3.1.1
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
     30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
     10.07.2003 sasco - обработка таблицы mobtemp для отправки файлов для BWX (пл. карточки)
     01.08.2003 sasco - сообщение о том, что документ должен пройти контроль именно в 2.7, а не просто так
     04.08.2003 kanat - добавил печать чека БКС при штамповке кассовых транзакций
     02.10.2003 sasco - логирование пополнения пласт. карточек (jh.party = "BWX")
     17.10.2003 sasco - убрал запрос на печать чека БКС (все - автоматом)
     27.01.2004 sasco - убрал today для cashofc
     07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
     19.03.2004 isaev - если платеж - пополнение карт. счета, то с филиала формируется RMZ на TXB00
     13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
     18.05.2004 nadejda - добавлена возможность штамповать проводки по кассе в пути (для РКО, работающих в выходные и по вечерам)
     19.05.2004 nadejda - при проводке Касса - Касса в пути сумма считается только та, что по кассе
     29.07.2004 saltanat - проверка на прохождения Валютного контроля для Юр.лиц при взносу и снятию наличной иностранной валюты
     23.08.2004 saltanat - для контроля в 15.9 убрала проверку на сумму
     06.09.2004 sasco - поменял пусть на ntmain
     25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
     26.04.2005 marinav - if avail sysc заменен на if avail bookcod
     13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
     11.07.2005 dpuchkov- добавил формирование корешка
     13.07.2005 nataly - добавлен акцепт для  быстрых переводов
     12.08.2005 ten - проверка на прохождение арп - касса счета 2.8 через 2.7
     27.08.2005 dpuchkov - добавил вывод информации на табло
     03.09.2005 dpuchkov добавил возможность переключения очередей
     31.10.2005 dpuchkov переделал очереди на сиквенсы.
     21.11.2005 dpuchkov добавил корешки для дубликатов квитанций
     10.01.2006 marinav  файл для BWX формируется теперь процессом bwx_ps
     02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
     17/03/2009 galina - поправила сообщение для валютного контроля
     14.04.10   marinav - контроль расходных кассовых операций физ лиц более 5000 долл статус bad
     03.07.2010 marinav - отправка межфилиального платежа
     03/05/2011 madiyar - межфилиальный платеж ищем не только по номеру транзакции, но и по коду филиала
     20.07.2011 damir - изменил вызываемую программу run vou_bankcas.p на vou_bank.p.
     14/09/2011 dmitriy - перекомпиляция в связи с изменением x-cash0.f
     09/08/2011 k.gitalov - запрос изменения статуса в шлюз золотой короны
     26/09/2011 Luiza   - добавила создание межфилиального платежа на снятие комиссии со счета клиента.
                        - добавила генерацию транзакции снятия суммы комиссии со счета клиента после акцепта кассира суммы перевода,
                         данные для транзакции находятся в поле joudoc.vo.  добавила вызов voubankt
     27/09/2011 dmitriy - перекомпиляция
     04/11/2011 dmitriy - при вызове mail изменил входящий параметр filpayment.info[3] на v-mail
     10/11/2011 dmitriy - перекомпиляция (изменил x-cash0.f и x-cash2.f)
     28/11/2011 Luiza   - в bxcif.type записываю код тарифа комиссии
     29/11/2011 dmitriy - width для fr1 = 100
     30/11/2011 lyubov - переход на ИИН/БИН (изменяется надпись на формах)
     30/11/2011 Luiza  - дoбавила символ #  в поле bxcif.rem при создании записи в bxcif
     30/11/2011 Luiza  - добавила  bxcif.pref = yes.
     23.12.2011 damir - добавил keyord.i, printord.p, printbks.p
     06/01/2011 Luiza - добавила проверку прохождения контроля в 2.4.1.1. для расхода с счета клиента(пока только для Алматы)
     02/20/2012 lyubov - исправила выборку символов касплана
     09/02/2012 Luiza  - теперь транзакция снятия суммы комиссии со счета клиента после акцепта кассира суммы перевода
                           записывается в ту же проводку 5 линией

     09/02/2012 dmitriy - перекомпиляция изменил x-cash0.f
     07/03/2012 Luiza  - добавила проверку прохождения контроля в 2.4.1.1. для расхода с счета клиента(уже для всех филиалов)
     07.03.2012 damir - добавил входной параметр в printord.p.
     11.03.2012 damir - перекомпиляция.
     06/06/2012 Lyubov - при изменении статуса проводки, заполняются поля jh.stmp_tim и jh.jdt_sts
     25/09/2012 dmitriy - после штамповки транзакции удаление листа ЧК из списка неиспользованных
     27/09/2012 dmitriy - добавил if avail joudoc при удалении чеков
     25/10/2012 madiyar - кроме счета 1858 добавил проверку на счета 1859, 2858, 2859
     13/11/2012 Luiza   - Upay
     15/05/2013 Luiza - ТЗ № 1826
*/


{comm-txb.i}
{get-kod.i}   /* get-kod.i для проверки Юр/Физ Лицевости */
{chbin.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def var naloper as char init "jbb_jou,jcc_jou,jgg_jou".
def var jou_prog as character NO-UNDO.
def var db_sum as deci format "zzz,zzz,zzz,zz9.99" .
def var cr_sum as deci format "zzz,zzz,zzz,zz9.99" .
def var m_sub as char.

def var i as int.
def var v-transf as logic.
def var ttt as cha format "x(60)".
def shared var g-ofc like ofc.ofc.
def var d-amt as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var c-amt as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99".
def var v-amt like jl.dam.
def var what as cha format "x(15)".
def var icrc as int.
def var nn as int.
def var p-pjh like jh.jh.
def var okey as log.
def var c-gl like gl.gl.
def var c-gl1002 like gl.gl.
def var v-point like point.point.
def var k-point like point.point.
def var vcha1 as cha.
def var vcha2 as cha.
def var vcha3 as cha.
def var vcha4 as cha.
def var vcha5 as cha.
def var vcha15 as cha.
def var vcha16 as cha.
def var vcha6 as cha.
def var vcha7 as cha.
def var vcha8 as cha format "x(20)".
def var vcha9 as cha format "x(25)".
define variable vcha10 as character format "x(11)".
def var v-sts like jh.sts.
def var dday as date.
def var s-ourbank as char.
def new shared var s-jh like jh.jh.
def buffer bf1-jl for jl.
def buffer bf1-aaa for aaa.
def var v-tit as char init "".
/*def var v-cifname as char.
def var v-pass    as char.
def var v-rnn     as char.*/

 def var p-tr-state as char.
 def var p-err as log no-undo init yes.
 def var p-errdes as char no-undo init ''.


define variable obmGL2 as integer.
define variable ocas as integer.
def buffer bf-sysc for sysc.
def var xin1  as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99" label "ПРИХОД ".
def var xout1 as dec decimals 2 format "-z,zzz,zzz,zzz,zzz.99" label "РАСХОД  ".
def var sxin1  like xin1.
def var sxout1 like xout1.

/*Luiza  */
define variable vvv-cash   as int.
find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
vvv-cash = sysc.inval.
/*----------------------------------------------*/

find bf-sysc where bf-sysc.sysc = "904kas" no-lock no-error.
if avail bf-sysc then obmGL2 = bf-sysc.inval. else obmGL2 = 100200.
find bf-sysc where bf-sysc.sysc = "CASHGL" no-lock no-error.
if avail bf-sysc then ocas = bf-sysc.inval.

define variable rcode   as integer no-undo.
define variable rdes    as character no-undo.
define variable vdel    as character initial "^" no-undo.


/*
 define variable vcha11 as character format "x(18)".
 define variable vcha12 as character format "x(18)".
*/

define shared variable g-today as date.

def var uuu as int init 0.
def var m-ttt as int init 0.
def var v-noc as char format "x(6)".

define new shared variable pay  as decimal format "z,zzz,zzz,zzz,zz9.99".
 define variable y_ock as logical.    /*****************/
define variable o_ock like jl.acc.
define variable a_ock like jl.dam.
define variable c_ock like jl.crc.
define variable po-jh like jh.jh.
define variable ccode as integer.
define variable cdes  as character.
define variable bank  as logical.
define variable qnum as integer.
/*define new shared variable p-jh like jh.jh.*/
def var v-dep as integer.
def var i-yes as integer init 0.

def var v-olb as char.
def buffer bb-ofc for ofc.
def var v-paf as char.
        v-paf = " `askhost`:L://CAPITAL//Kasline//" .
def var v-st as char.
def var v-cas as char.
def var v-ofile as char.
def stream v-out.
  def var v-men as char.
  def var v-men1 as char.
  def temp-table t-chk like acheck
      field cif like aaa.cif
      field sum like aaa.opnamt
      field val as char .



  def buffer b-cashier for cashier.
  def var v-chnum as integer.

def buffer bjl for jl.
def buffer btchk for t-chk.
def buffer baaa for aaa.

define variable v_sub as character.

define buffer ccrc for crc. /*********************/

define new shared temp-table wcon
    field num as integer
    field amt as decimal format "z,zzz,zzz,zzz,zz9.99"
    field cur like crc.crc
    field pay as decimal format "z,zzz,zzz,zzz,zz9.99"
    field dcrc like crc.des
    index num-value num.

define variable va-cheque like ock.cheque.
define variable va-amount like ock.camt.
define variable va-crc    like crc.crc.

define frame f_ock
    va-cheque label "           Номер чека    " skip
    va-amount label "           Сумма чека    " skip
    va-crc    label "           Валюта чека   "
        validate (can-find (crc where crc.crc eq va-crc),
        "Проверьте валюту!")
    ccrc.des  no-label
    with row 6 side-labels centered.
    /**************************************************/

/* sasco - таблица для генерации файлов для BWX (пл. карточки) */
def new shared temp-table cpay
           field card as char format "x(18)" /* N карт */
           field sum like jl.dam             /* Сумма к зачисл */
           field crc as char format "x(3)"   /* валюта */
           field trxdes as char              /* описание транзакции */
           field batchdes as char            /* описание батча */
           field messtype as char.           /* тип зачисления */
def var outname as char no-undo.
def var outname1 as char no-undo.

define variable v-payment as char.
define variable v-bks-choice as logical.
def var v-1001 as logical.
def var v-1002 as logical.
def var v-mail as char.

def buffer cash for sysc.

find sysc where sysc.sysc = "CASDIR" no-lock no-error.
if avail sysc then do:
   v-paf = sysc.chval.
end.


def stream t.

function unix_s returns char (cmd as char).
    def var st as char init ''.
    input stream t through value(cmd).
    import stream t unformatted st.
    input stream t close.
    return st.
end.

{x-cash0.f}
{lgps.i new}
m_pid = "Casher" .


find sysc where sysc.sysc = "CASHGL" no-lock no-error.
if not avail sysc then do:
  message " Не настроен параметр CASHGL!".
  pause.
  return.
end.
c-gl = sysc.inval.

find sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then c-gl1002 = sysc.inval. else c-gl1002 = 100200.

find cash where cash.sysc = "CASHPL" no-lock no-error.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then do :
   v-point =  ofc.regno / 1000 - 0.5 .
end.

ccc:

REPEAT:

hide all.
v-yes = false.
v-log = true.
okey = false.

do on error undo,retry:
    clear frame qqq.

    display p-pjh with frame qqq.
    update p-pjh with frame qqq.
/*добавлено*/
find bb-ofc where bb-ofc.ofc = g-ofc no-lock no-error.
if comm-txb() = "TXB00" and bb-ofc.regno mod 1000 = 1 then do: /*Только Алматы ЦО*/
if p-pjh = 0 then do:

   i-yes = 0.

find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС" and substr(cashier.kasnum,7,1) <> "С" no-lock no-error.
if not avail cashier then do:
   message "Только кассы 1-2-3-4". pause.
   return.
end.


   run sel2 (" Параметры ", " 1. Реестр очередей | 2. Статус кассы | 3. Переключить очередь | ВЫХОД", output v-dep).
/* run sel2 (" Параметры ", " 1. Реестр очередей(Физ лиц) | 2. Реестр очередей(Юр. лиц) | 3. Статус кассы | ВЫХОД", output v-dep).*/

   if v-dep = 3 then do:
       find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС" exclusive-lock no-error.
       if avail cashier then do:
          if substr(cashier.name,1,1) = "1" then do:
             cashier.name = "2" + substr(cashier.name,2,50).
message " Вы переключены на реестр ФИЗИЧЕСКИХ ЛИЦ".
pause.
          end. else
          if substr(cashier.name,1,1) = "2" then do:
             cashier.name = "1" + substr(cashier.name,2,50).
message " Вы переключены на реестр ЮРИДИЧЕСКИХ ЛИЦ".
pause.
          end.
       end.
   end.

   /*Статус кассы*/
   if v-dep = 2 then do:
              def var i-cas as integer.
              define frame fsts
                     v-st format "x(30)" label "Статус(F2-для выбора)"  validate(v-st = "Касса свободна", "Выберите статус из списка")
              with side-labels centered row 8.
              on help of v-st in frame fsts do:
                   run sel2(" СТАТУС КАССЫ ", " Касса свободна", output i-cas).
                   if i-cas = 1 then v-cas = "Касса свободна".
                   if i-cas = 2 then return.
                   v-st = v-cas.
                   displ v-st with frame fsts.
              end.
              v-st = "Касса свободна".
              update v-st with frame fsts.
              hide frame fsts.

              if v-st <> "" then do:
                 find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС" no-lock no-error.
                 if avail cashier then do:
                    v-ofile = "ks" + string(substr(cashier.kasnum,7,1)) + ".txt".
                 end.
                 else do:
                    message "Не настроен логин кассира в п 3-12".
                    pause.
                    leave.
                 end.
                 if v-st = "Касса свободна" then /*v-st = "йЮЯЯЮ ЯБНАНДМЮ".*/  v-st = "  ***".
                            output stream v-out to value(v-ofile).
                            put stream v-out unformatted v-st.
                            output stream v-out close.
                            unix silent value ("rcp " + v-ofile + v-paf).
if substr(cashier.kasnum,7,1) = "1" then current-value(ks1) = 0. else
if substr(cashier.kasnum,7,1) = "2" then current-value(ks2) = 0. else
if substr(cashier.kasnum,7,1) = "3" then current-value(ks3) = 0. else
if substr(cashier.kasnum,7,1) = "4" then current-value(ks4) = 0.

                    def buffer bnchk1 for chk.
                    for each bnchk1 where bnchk1.name = g-ofc and bnchk1.prim <> "1" and bnchk1.prim <> "2" no-lock:
                        find last chk  where chk.jh = bnchk1.jh and chk.name = bnchk1.name and chk.prim = bnchk1.prim and chk.rem = bnchk1.rem exclusive-lock no-error.
                        if avail chk then delete chk.
                        release chk.
                    end.
              end.
   end.
   else
   /*Реестр очереди*/
   if v-dep = 1 then do:
       find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС" no-lock no-error.
       if avail cashier then do:
          if substr(cashier.name,1,1) = "2" then v-tit = "Реестр очередей ФИЗ. ЛИЦ".
          if substr(cashier.name,1,1) = "1" then v-tit = "Реестр очередей ЮР.  ЛИЦ".
       end.


   def buffer bnchk for chk.

   for each bnchk no-lock:
      find last jh where jh.jh = integer(bnchk.jh) no-lock no-error.
      if avail jh then do:
         if jh.sts <> 5 or (bnchk.name = g-ofc and bnchk.prim <> "2") then do:
            find last chk  where chk.jh = bnchk.jh and chk.name = bnchk.name and chk.prim = bnchk.prim and chk.rem = bnchk.rem exclusive-lock no-error no-wait.
            if not locked chk and avail chk   then
               delete chk.
         end.
      end.
      else
      do:
        find last chk  where chk.jh = bnchk.jh and chk.name = bnchk.name and chk.prim = bnchk.prim and chk.rem = bnchk.rem exclusive-lock no-error no-wait.
        if not locked chk and avail chk then
           delete chk.
      end.
   end.


  v-men = "".
  v-men1 = "".


  find last b-cashier where b-cashier.ofc = g-ofc and b-cashier.kasnum begins "КАСС"  no-lock no-error.
  if not avail b-cashier then do:
      message "Не настроен логин кассира в п 3-12".
      pause.
      leave.
  end.


  for each cashier where cashier.kasnum begins "МЕНЕДЖЕР" and (cashier.prim = "1" or cashier.prim = "2") /*cashier.prim = b-cashier.prim*/  no-lock:
     if cashier.prim = substr(b-cashier.name, 1, 1) then do:
         if v-men <> "" then
            v-men = v-men + "," + cashier.ofc.
         else
            v-men = cashier.ofc.
     end.
/*   else
     do:
         if v-men1 <> "" then
            v-men1 = v-men1 + "," + cashier.ofc.
         else
            v-men1 = cashier.ofc.
     end. */
  end.


  DEFINE QUERY q1 FOR t-chk.
  define buffer buf for t-chk.
  for each t-chk :
      delete t-chk.
  end.


  for each acheck where acheck.dt = g-today no-lock:
      find last jh where jh.jh = integer(acheck.jh) and jh.sts = 5 and lookup(jh.who, v-men) <> 0 no-lock no-error.

      if avail jh then do:

         find last bb-ofc where bb-ofc.ofc = jh.who no-lock no-error.
         if bb-ofc.regno mod 1000 = 1 then do:

if time - jh.tim < 120 then next.


find last bf1-jl where bf1-jl.jh = jh.jh and bf1-jl.acc ne "" no-lock no-error.
if avail bf1-jl then do:
   find last bf1-aaa where bf1-jl.acc = bf1-aaa.aaa no-lock no-error.
end.


find last joudoc where joudoc.whn = g-today and joudoc.jh = jh.jh no-lock no-error.
/* message jh.jh.
  pause 333.*/

            find last chk where chk.jh = jh.jh and chk.prim <> "1" and chk.prim <> "2"  no-lock no-error.
            if avail chk then do:
                 if chk.name = g-ofc then  do:
                  create t-chk.
                  t-chk.jh  = acheck.jh.
                  t-chk.num = acheck.num.
                  t-chk.dt  = acheck.dt.
                  t-chk.n1  = acheck.n1.
if avail joudoc and joudoc.chk <> 0 then
   t-chk.num = t-chk.num + " ЧЕК".
find last bf1-jl where bf1-jl.jh = jh.jh and bf1-jl.rem[1] = "За выдачу дубликата квитанции" no-lock no-error.
if avail bf1-jl then do:
   t-chk.num = t-chk.num + " ДУБЛ".
end.

if avail bf1-aaa then
   t-chk.cif  = bf1-aaa.cif.
               end.
            end. else
            do:
                  create t-chk.
                  t-chk.jh  = acheck.jh.
                  t-chk.num = acheck.num.
                  t-chk.dt  = acheck.dt.
                  t-chk.n1  = acheck.n1.
if avail joudoc and joudoc.chk <> 0 then
   t-chk.num = t-chk.num + " ЧЕК".

find last bf1-jl where bf1-jl.jh = jh.jh and bf1-jl.rem[1] = "За выдачу дубликата квитанции" no-lock no-error.
if avail bf1-jl then do:
   t-chk.num = t-chk.num + " ДУБЛ".
end.


if avail bf1-aaa then
   t-chk.cif  = bf1-aaa.cif.
            end.
         end.
      end.
  end.






/* Сумма для расходных ордеров */
for each t-chk exclusive-lock:
  find last jh where jh.jh = integer(t-chk.jh) no-lock no-error.
  for each jl of jh use-index jhln where jl.gl = ocas or (jl.gl = obmGL2  and ((jl.trx begins "opk")
                                                or (substring(jl.rem[1],1,5) = "Обмен")
                                                or (can-find (sub-cod where sub-cod.sub = "arp"
                                                                        and sub-cod.acc = jl.acc
                                                                        and sub-cod.d-cod = "arptype"
                                                                        and sub-cod.ccode = "obmen1002" no-lock)))) no-lock break by jl.crc by jl.dc:
    if jl.dam gt 0 then do:
        xin1 = jl.dam.
        xout1 = 0.
    end.
    else do:
         xin1 = 0.
         xout1 = jl.cam.
    end.

    sxin1 = sxin1 + xin1.
    sxout1 = sxout1 + xout1.

    if last-of(jl.dc) then do:
       if jl.dc eq "C"  then do:
          find last crc where crc.crc = jl.crc no-lock no-error.
          if avail crc then do:
             t-chk.sum = sxout1.
             t-chk.val = crc.code.
          end.
       end.
       sxin1 = 0. sxout1 = 0.
    end.
  end.
end.




  def browse b1
      query q1
      displ
      t-chk.jh  label "N проводки"
      t-chk.num format "x(19)" label "N корешка "
      t-chk.dt label " Дата	"
      t-chk.cif label "CIF" format "x(6)"
      t-chk.sum format "->>,>>>,>>>,>>9.99" label "Сумма"
      t-chk.val format "x(3)" label "Вал"
  with 6 down title v-tit overlay.
  DEFINE BUTTON bexit LABEL "Выход".



  def frame fr1 b1 skip  bexit  with centered overlay row 9 top-only width 80.


ON CHOOSE OF bexit IN FRAME fr1
do:
   hide frame fr1.
   APPLY "WINDOW-CLOSE" TO BROWSE b1.
     view frame qqq.
end.


ON return of b1 IN FRAME fr1 DO:

for each chk where chk.name = g-ofc and chk.prim = ""  no-lock :
   delete chk.
end.

def var v-och as char.
     v-ofile = "".
     find buf where rowid (buf) = rowid (t-chk) no-lock no-error.
     if avail buf then do:
        browse b1:refresh().

def var l_cst as logical.
def var v_aljh as character init "".
      for each jl where jl.jh = integer(t-chk.jh) no-lock:
          if jl.acc ne ""  then do:
             find aaa where aaa.aaa = jl.acc no-lock no-error.
             if avail aaa then do:
                for each btchk where btchk.jh <> t-chk.jh no-lock:
                    for each bjl where bjl.jh = integer(btchk.jh) no-lock:
                        if bjl.acc ne "" /*and bjl.aax = 1 then */  then do:
                            find baaa where baaa.aaa = bjl.acc no-lock no-error.
                            if avail baaa then do:
                               if baaa.cif = aaa.cif then do:
/*                                find last chk where chk.jh = integer(btchk.jh) no-lock no-error.
                                  if not avail chk then do: */
                                     if v_aljh = "" then v_aljh = btchk.jh. else
                                        v_aljh = v_aljh + "," + btchk.jh.
/*                                end. */
                               end.
                               leave.
                            end.
                        end.
                    end.
                end.
                leave.
             end.
          end.
      end.


l_cst = False.
find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС" no-lock no-error.
if substr(cashier.kasnum,7,1) = "1" then do:
  if current-value(ks2) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks3) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks4) = integer(t-chk.jh) then l_cst = True. else
  if v_aljh <> "" then do:
     if lookup(string(current-value(ks2)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks3)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks4)), v_aljh) <> 0 then l_cst = True.
  end.
end.
if substr(cashier.kasnum,7,1) = "2" then do:
  if current-value(ks1) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks3) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks4) = integer(t-chk.jh) then l_cst = True. else
  if v_aljh <> "" then do:
     if lookup(string(current-value(ks1)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks3)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks4)), v_aljh) <> 0 then l_cst = True.
  end.
end.
if substr(cashier.kasnum,7,1) = "3" then do:
  if current-value(ks1) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks2) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks4) = integer(t-chk.jh) then l_cst = True. else
  if v_aljh <> "" then do:
     if lookup(string(current-value(ks1)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks2)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks4)), v_aljh) <> 0 then l_cst = True.
  end.

end.
if substr(cashier.kasnum,7,1) = "4" then do:
  if current-value(ks1) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks2) = integer(t-chk.jh) then l_cst = True. else
  if current-value(ks3) = integer(t-chk.jh) then l_cst = True. else
  if v_aljh <> "" then do:
     if lookup(string(current-value(ks1)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks2)), v_aljh) <> 0 then l_cst = True. else
     if lookup(string(current-value(ks3)), v_aljh) <> 0 then l_cst = True.
  end.
end.

if l_cst = True then do:
    message  "Одна из операций клиента уже обслуживается" skip "Выберите следующую операцию!"
    view-as alert-box question buttons ok title "".
end. else
do:


find last chk where chk.jh = integer(t-chk.jh) and chk.name <> g-ofc and chk.prim = ""  no-lock no-error.
if avail chk then do:
     find last b-cashier where b-cashier.ofc = chk.name no-lock no-error.
     if avail b-cashier then do:
        message  "Одна из операций клиента обслуживается в кассе N" string(substr(b-cashier.kasnum,7,1)) skip
                 "Выберите следующую операцию!"
        view-as alert-box question buttons ok title "" .
     end.
     else
     do:
        message  "Одна из операций клиента уже обслуживается" skip
                 "Выберите следующую операцию!"
        view-as alert-box question buttons ok title "" .
     end.
end.
else do:

     hide frame fr1.
/*
if length(t-chk.n1) = 1 then do: v-och = "00" + t-chk.n1.  end. else
if length(t-chk.n1) = 2 then do: v-och = "0" + t-chk.n1.   end. else */
   v-och = t-chk.n1.


find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС"  no-lock no-error.
if avail cashier then do:

     find chk where chk.jh = integer(t-chk.jh) and chk.prim = "" no-lock no-error.
     if not avail chk then do:
        create chk.
               chk.jh = integer(t-chk.jh).
               chk.name = g-ofc.
        release chk.
     end.

if substr(cashier.kasnum,7,1) = "1" then current-value(ks1) = integer(t-chk.jh). else
if substr(cashier.kasnum,7,1) = "2" then current-value(ks2) = integer(t-chk.jh). else
if substr(cashier.kasnum,7,1) = "3" then current-value(ks3) = integer(t-chk.jh). else
if substr(cashier.kasnum,7,1) = "4" then current-value(ks4) = integer(t-chk.jh).

/* Игнор чека */
/*
  def buffer bt-chk for t-chk.
  for each bt-chk no-lock  by integer(bt-chk.jh):
      if bt-chk.jh = t-chk.jh then leave.
      if bt-chk.num = "ЧЕК" then do:
         find last chk where chk.jh = integer(bt-chk.jh) and chk.name = g-ofc and chk.prim = "1" no-lock no-error.
         if not avail chk then do:
             create chk.
                    chk.jh = integer(bt-chk.jh).
                    chk.name = g-ofc.
                    chk.prim = "1".
            release chk.
            v-chnum = 0.
            for each chk where chk.jh = integer(bt-chk.jh) and chk.prim = "1" and chk.rem <> "snd" no-lock break by integer(chk.jh):
                v-chnum = v-chnum + 1.
            end.

            if v-chnum = 3 then do:
               for each bnchk where bnchk.jh = integer(bt-chk.jh) and bnchk.prim = "1" and bnchk.rem <> "snd" no-lock break by integer(bnchk.jh):
                   find last chk  where chk.jh = bnchk.jh and chk.name = bnchk.name and chk.prim = bnchk.prim and chk.rem = bnchk.rem exclusive-lock no-error no-wait.
                   if avail chk and not locked chk then do:
                      v-chnum = v-chnum + 1.
                      chk.rem = "snd".
                   end.
               end.
               find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС"  no-lock no-error.
               v-ofile = "snd" + string(substr(cashier.kasnum,7,1)) + ".txt".
               find last cashier where cashier.prim = "3" no-lock no-error.
               if avail cashier then do:
                  output stream v-out to value(v-ofile).
                  put stream v-out unformatted cashier.ofc skip "йЮЯЯНБШИ ДНЙСЛЕМР ВЕЙ № РПЮМГЮЙЖХХ" skip bt-chk.jh skip "МЕ НАПЮАНРЮМ".
                  output stream v-out close.
                  unix silent value ("rcp " + v-ofile + v-paf).
               end.
            end.

         end.
      end.
  end.                  */
/* END Игнор чека */

/*если 4 раза высветила на табло*/
  find last cashier where cashier.ofc = g-ofc and cashier.kasnum begins "КАСС"  no-lock no-error.
  if t-chk.num <> "ЧЕК" then do:
     find last chk where chk.jh = integer(t-chk.jh) and chk.prim = "2" and chk.num <> "ЧЕК"  exclusive-lock no-error.
     if avail chk then do:
        if chk.rem <> "snd" then do:
           chk.num = string(integer(chk.num) + 1).
           if integer(chk.num) > 3 then do:
              chk.rem = "snd" .
              v-ofile = "snd" + string(substr(cashier.kasnum,7,1)) + ".txt".
              find last jh where jh.jh = chk.jh no-lock no-error.
              if avail jh then do:
                 output stream v-out to value(v-ofile).
                 put stream v-out unformatted  jh.who skip "йЮЯЯНБЮЪ НОЕПЮЖХЪ №" skip jh.jh skip "МЕ НАПЮАНРЮМЮ Б ЙЮЯЯЕ".
                 output stream v-out close.
                 unix silent value ("rcp " + v-ofile + v-paf).
              end.
           end.
        end.
        release chk.
     end.
     else do:
           create chk.
           chk.jh = integer(t-chk.jh).
           chk.num = "1".
           chk.name = g-ofc.
           chk.prim = "2".
           release chk.
     end.
  end.
/* End если 4 раза высветила на табло*/



/* Ищем все операции этого клиента */
    for each jl where jl.jh = integer(t-chk.jh) no-lock:
        if jl.acc ne ""  then do:
           find aaa where aaa.aaa = jl.acc no-lock no-error.
           if avail aaa then do:
              for each btchk where btchk.jh <> t-chk.jh no-lock:

                  for each bjl where bjl.jh = integer(btchk.jh) no-lock:
                      if bjl.acc ne "" /*and bjl.aax = 1 then */  then do:

                          find baaa where baaa.aaa = bjl.acc no-lock no-error.
                          if avail baaa then do:
                             if baaa.cif = aaa.cif then do:
                                find last chk where chk.jh = integer(btchk.jh) no-lock no-error.
                                if not avail chk then do:
                                   create chk.
                                          chk.jh = integer(btchk.jh).
                                          chk.name = g-ofc.
                                          release chk.
                                end.

                             end.
                             leave.
                          end.
                      end.
                  end.
              end.
              leave.
           end.
        end.
     end.
/* END Ищем все операции этого клиента */




  v-ofile = "ks" + string(substr(cashier.kasnum,7,1)) + ".txt".
/*побел между цифрами*/

  if length(v-och) <> 4 then
  if v-och <>  "    " then
  v-och = substr(v-och,1,1) + " " + substr(v-och,2,1) + " " + substr(v-och,3,1).


  output stream v-out to value(v-ofile).
  put stream v-out unformatted v-och skip g-ofc /*"u00128"*/.
  output stream v-out close.
  unix silent value ("rcp " + v-ofile + v-paf).
end.


     APPLY "WINDOW-CLOSE" TO BROWSE b1.
     view frame qqq.
     p-pjh = integer(t-chk.jh).
     message  "Транзакция N " p-pjh skip
              "Продолжить?"
     view-as alert-box question buttons yes-no title "" update v-ans as logical.
     if v-ans = True then do:

     end.
     else
     do:
        i-yes = 1.
     end.
   end.
end.

end. /* avail chk */
end.


/*проверка на чужие проводки*/
for each t-chk exclusive-lock:
   find last jh where jh.jh = integer(t-chk.jh) no-lock no-error.
   if avail jh then do:
      find last cashier where cashier.ofc = jh.who no-lock no-error.
      if not avail cashier then do:
         delete t-chk.
      end.
   end.
end.
/*проверка на чужие проводки*/

   open query q1 for each t-chk no-lock by integer(t-chk.jh) by t-chk.cif /*by integer(substr(t-chk.cif,2,5)) */ .
   b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
   ENABLE all with frame fr1 centered overlay top-only.
   apply "value-changed" to b1 in frame fr1.
   WAIT-FOR WINDOW-CLOSE of frame fr1.
   end.
end.
end.


if i-yes = 1 then return no-apply.
/*добавлено*/

    find jh where jh.jh = p-pjh no-lock no-error.
    if available jh then do:
        find ofc where ofc.ofc = jh.who no-lock no-error.
        if available ofc then do :
            /*k-point =  ofc.regno / 1000 - 0.5 .*/
            k-point = jh.point.
        end.
        /*
        if k-point <> v-point then do:
            message "CЁtas grupas TRX#".
            undo,retry.
        end.*/
    end.
/*
    else do:
        find aah where aah.aah = p-pjh no-lock no-error.
        if available aah then do:
            find ofc where ofc.ofc = aah.who no-lock no-error.
            if available ofc then do:
                k-point = aah.point.
            end.
        end.
        else next.
    end.
*/
end. /*on error undo,retry*/

/*
find first aah where p-pjh = aah.aah no-error.
if available aah then
do:
        okey = false.
        find aaa where aaa.aaa = aah.aaa.
        find cif of aaa.
        if available cif then
		if cif.type = 'B' or cif.type = 'M' or cif.type = 'N' then uuu = 1.
        for each aal of aah:
            find first aax where aax.ln = aal.aax and aax.lgr = aaa.lgr.
            if aax.dgl = c-gl or aax.cgl = c-gl then okey = true.
        end.
end.
*/

if okey then
do:
/*
	if aah.stn ne 5 then
	do:
		message vcha3.
		bell. bell.
		pause.
		next.
	end.
*/

	v-amt = 0.
	ttt = vcha1 /*+ aah.aaa*/ + vcha2 + trim(trim(cif.prefix) + " " + trim(cif.name)) .
	display ttt with frame qqq.
	pause .
/*
	for each aal of aah:
		if available cash and cash.loval then do:
			find jlsach where jlsach.jh = aal.aah and jlsach.ln = aal.ln no-lock no-error.
			if not available jlsach  and aal.crc eq 1 then do :
				message " Не введен символ кас.плана !!!! ".
				bell. bell.
				hide frame out.
				leave ccc.
			end.
			else  do:
				find cashpl where cashpl.sim = jlsach.sim no-lock.
			end.
		end.
		find first aax where aax.ln = aal.aax and aax.lgr = aaa.lgr.
		find first crc where crc.crc = aal.crc.
		d-amt = 0. c-amt = 0.
		if aax.dgl = c-gl or aax.cgl = c-gl then do:
			if aax.dgl = c-gl then do :
				d-amt = aal.amt. v-amt = v-amt - d-amt.
			end.
			if aax.cgl = c-gl then do :
				c-amt = aal.amt. v-amt = v-amt + c-amt.
			end.
			if available cash and cash.loval then
				aal.rem[1] = string(cashpl.sim,"zzz") + " " + cashpl.des.
				v-noc = string(aal.chk).
				{x-cash1.f}
				pause 0.
		end.
	end.
*/
	if  v-amt gt 0 then
	do:
		what = vcha4 .
		bank = false.
	end.
	else do:
		what = vcha15 .
		v-amt = - v-amt.
		bank = true.
	end.

	display vcha6 no-label what v-amt format "z,zzz,zzz,zzz,zzz,zz9.99-" crc.code with color display message row 19  overlay centered no-label frame hh.
	pause 0.

	if uuu = 1 and v-noc <> '0' then display vcha8 no-label v-noc no-label with color display message row 17 overlay centered no-label no-box frame hh1.
	pause 0.

	v-yes = false.

	s-jh = jh.jh.
    /*Luiza--------------------------------------------------------*/
    v-transf = no.
    for each jl where jl.jh = s-jh no-lock.
        if (jl.gl >= 185800) and (jl.gl <= 185999) then v-transf = yes.
        if (jl.gl >= 285800) and (jl.gl <= 285999) then v-transf = yes.
    end.
    if v-transf then do:
        find first joudoc where joudoc.jh = s-jh no-lock no-error.
        if v-noord = no then do:
            run vou_bankt(0,1,joudoc.info).
            run vou_bankt(0,1,joudoc.info).
        end.
        else run printord(s-jh,"").
    end.
    /*---------------------------------------------------------------*/
	else do:
        if v-noord = no then do:
            run vou_bank(0).
            run vou_bank(0).
        end.
        else run printord(s-jh,"").
    end.

/*
	message vcha7 update v-yes.
	if v-yes then
	do transaction:
		if k-point <> v-point then
		do:
			v-yes = false.
			message "Проводка создана в другом пункте. Штамповать?" update  v-yes.
			if v-yes then
			do:
				find ofc where ofc.ofc = g-ofc use-index ofc no-lock.
				for each aal where aal.aah eq aah.aah exclusive-lock:
					aal.point = ofc.regno / 1000 - 0.5.
					aal.depart = ofc.regno MODULO 1000.
				end.
				release aal.
				aah.point = ofc.regno / 1000 - 0.5.
				aah.depart = ofc.regno MODULO 1000.
			end.
			else undo, next ccc.
		end.
		for each aal where aal.aah = aah.aah  exclusive-lock:
			aal.stn = 6.
			aal.teller = g-ofc.
			if aal.fday > 0 then do:
				aaa.cbal = aaa.cbal + aal.amt.
				aaa.fbal[aal.fday] = aaa.fbal[aal.fday] - aal.amt.
				aal.fday = 0.
			end.
		end.
		aah.stn = 6.
		aah.stmp_tim = time.

		if po-jh ne 0 and po-jh ne ? then do:
			find aah where aah.aah = po-jh exclusive-lock.
			for each aal of aah exclusive-lock:
				aal.stn = 6.
				aal.teller = g-ofc.
			end.
			aah.stn = 6.
			aah.stmp_tim = time.
			release aah.
			release aal.
		end.
	end.
	else
*/
	IF v-yes eq false and (po-jh ne ? and po-jh ne 0) then
	do:
		hide frame mm.
		find jh where jh.jh = po-jh no-error.
		if avail jh then v-sts = jh.sts.
		else v-sts = 0.
		run trxsts (input po-jh, input 0, output ccode, output cdes).
		if ccode ne 0 then do:
			message cdes.
			return.
		end.
		run trxdel (input po-jh, input true, output ccode, output cdes).
		if ccode ne 0 then do:
			message cdes.
			if ccode eq 50 then run trxsts (input po-jh, input v-sts, output ccode, output cdes).
			return.
		end.
		po-jh = ?.
		display p-pjh with frame qqq row 3.
	end.

	hide frame hh.
	hide frame hh1.
	hide frame out.
	ttt = " ".
	display ttt with frame qqq.
end.
else
do:
	find first jl where jl.jh = p-pjh no-error.
	if not available jl then next.

	okey = false.
	icrc = 0.
	m-ttt = 0.

	v-1001 = false.
	v-1002 = false.

	for each jl of jh use-index jhln break by jl.crc.
		find gl where gl.gl = jl.gl no-lock no-error.
		if available gl and gl.subled = 'CIF' then m-ttt = 1.
		if jl.gl = c-gl or jl.gl = c-gl1002 then okey = true.   /* проводку действительно надо штамповать */
		if jl.gl = c-gl then v-1001 = true.
		if jl.gl = c-gl1002 then v-1002 = true.
		/*****************/
		if gl.subled eq "ock" then do:
			find sysc where sysc.sysc eq "CHEQA" no-lock no-error.
			if sysc.inval eq jl.gl then y_ock = true.
			o_ock = jl.acc.
			a_ock = jl.dam.
			c_ock = jl.crc.
		end.
		/****************/
		if last-of(jl.crc) then icrc = icrc + 1.
	end.
	if not okey then do:
		message vcha16.
		pause.
		next.
	end.

	i = 0.
	find jh where jh.jh = p-pjh no-error.
	find first jl where jl.jh = p-pjh no-error.
	if jh.sts < 5 or (jh.sts > 5 and v-1001) or (jh.sts > 5 and v-1002 and jl.teller <> "" and jl.teller <> jl.who) then do:
		message vcha3.
		bell. bell.
		pause.
		next.
	end.


	if jl.gl eq c-gl then do:
		if jh.sub ne "" and jh.ref ne "" and jh.sub ne "lon" then do:
			find cursts where cursts.sub eq jh.sub and cursts.acc eq jh.ref use-index subacc no-lock no-error.
			if cursts.sts ne "cas" then do:

				if cursts.sts = "bac" or cursts.sts = "bap" or cursts.sts = "apr" then message "Документ на контроле ст. менеджером (в 2.4.1.1)!".
				else message "Статус документа не  <cas>".
				bell. bell.
				pause.
				next.
			end.
		end.
        end.
        find cursts where cursts.sub eq jh.sub and cursts.acc eq jh.ref use-index subacc no-lock no-error.
	if avail cursts and (cursts.sts = "bad" ) then do:
                message "Документ на контроле ст. менеджером (в 2.4.1.10)!".
		bell. bell. pause. next.
	end.

	if avail cursts and (cursts.sts = "baf") then do:
                message "Документ на контроле ст. менеджером (в 2.4.1.1)!".
		bell. bell. pause. next.
	end.

	/* 12.08.2005 ten - проверка на прохождение арп - касса счета 2.8 через 2.4.1.1     */
	s-ourbank = comm-txb().
	if (s-ourbank <> "TXB00") then
	do:
		find last ofcprofit where ofcprofit.ofc = jh.who and ofcprofit.regdt <= g-today no-lock no-error.
		if avail ofcprofit and (ofcprofit.profitcn = '103' or substring(ofcprofit.profitcn,1,1) = "A") then
		do:
			find first ujo where ujo.docnum = jh.ref no-lock no-error.
			if avail ujo then
			do:
				if  jh.ref ne "" and jh.sub = "ujo" then
				do:
					find  cursts where cursts.sub = jh.sub and  cursts.acc = ujo.docnum use-index subacc no-lock no-error.
					if avail cursts then
						if cursts.sts = "bac"
					then
					do:
						message "Документ на контроле ст. менеджером (в 2.4.1.1)!".
						bell. bell.
						pause.
						next.
					end.
				end.
			end.
		end.
	end.
	else
	do:
		find last ofcprofit where ofcprofit.ofc = jh.who and ofcprofit.regdt <= g-today no-lock no-error.
		if avail ofcprofit and (ofcprofit.profitcn = '103' or substring(ofcprofit.profitcn,1,1) = "A") then
		do:
			find last ofcprofit where ofcprofit.ofc = jh.who and ofcprofit.regdt <= g-today no-lock no-error.
			if avail ofcprofit and (ofcprofit.profitcn = '103' or ofcprofit.profitcn = '508') then
			do:
				find first ujo where ujo.docnum = jh.ref no-lock no-error.
				if avail ujo then
				do:
					if  jh.ref ne "" and jh.sub = "ujo" then
					do:
						find  cursts where cursts.sub = jh.sub and  cursts.acc = ujo.docnum use-index subacc no-lock no-error.
						if avail cursts then
							if cursts.sts = "bac" then
							do:
								message "Документ на контроле ст. менеджером (в 2.4.1.1)!".
								bell. bell.
								pause.
								next.
							end.
					end.
				end.
			end.
		end.
	end.

	if jh.sub ne "" and jh.ref ne "" and jh.sub = "lon" then
	do:
		find cursts where cursts.sub eq jh.sub and cursts.acc eq string(jh.jh) use-index subacc no-lock no-error.
		if not avail cursts then
		do:
			message "Проводка на контроле в Кредитном Департаменте".
			bell. bell.
			pause.
			next.
		end.
	end.


    /* Luiza проверка прохождения контроля в 2.4.1.1. для расхода с счета клиента(пока только для Алматы) */
        s-ourbank = comm-txb().
        if /*(s-ourbank = "TXB16") and*/ v-noord = yes then do:
            find first joudoc where joudoc.docnum = jh.ref no-lock no-error.
            if avail joudoc then do:
                if joudoc.dracctype = "2" then do:
                    m_sub = caps (substr (joudoc.docnum, 1, 3)).
                    if (joudoc.cracctype = "1") and (m_sub = "jou") then do:
                        find first cursts where cursts.sub eq m_sub and cursts.acc = joudoc.docnum use-index subacc no-lock no-error.
                        if avail cursts then if cursts.sts = 'baC' then	do:
                            message "Документ на контроле ст. менеджером (в 2.4.1.1)!".
                            bell. bell.
                            pause.
                            next.
                        end.
                    end.
                end.
            end.
        end.
    /*--------------------------------------------------------------------------------------------------*/

	/* 06.08.2004 saltanat - проверка на прохождение арп - касса счета через 2.4.1.1 */


	s-ourbank = comm-txb().
	if (s-ourbank <> "TXB00") then
	do:
		find first joudoc where joudoc.docnum = jh.ref no-lock no-error.
		if avail joudoc then
		do:
			if joudoc.dracctype = "4" then
			do:
				m_sub = caps (substr (joudoc.docnum, 1, 3)).
				if (joudoc.cracctype = "1") and (m_sub = "jou") then
				do:
					find first cursts where cursts.sub eq m_sub and cursts.acc = joudoc.docnum use-index subacc no-lock no-error.
					if avail cursts then
					if cursts.sts = 'baC' then
					do:
						message "Документ на контроле ст. менеджером (в 2.4.1.1)!".
						bell. bell.
						pause.
						next.
					end.
				end.
			end.
		end.
	end.
	else
	do:
		find last ofcprofit where ofcprofit.ofc = jh.who and ofcprofit.regdt <= g-today no-lock no-error.
		if avail ofcprofit and (ofcprofit.profitcn = '103' or substring(ofcprofit.profitcn,1,1) = "A") then
		do:
			find first joudoc where joudoc.docnum = jh.ref no-lock no-error.
			if avail joudoc then
			do:
				if joudoc.dracctype = "4" then
				do:
					m_sub = caps (substr (joudoc.docnum, 1, 3)).
					if (joudoc.cracctype = "1") and (m_sub = "jou") then
					do:
						find first cursts where cursts.sub eq m_sub and cursts.acc = joudoc.docnum use-index subacc no-lock no-error.
						if avail cursts then
							if cursts.sts = 'baC' then
							do:
								message "Документ на контроле ст. менеджером (в 2.4.1.1)!".
								bell. bell.
								pause.
								next.
							end.
					end.
				end.
			end.
		end.
	end.



	/* 29.07.04 saltanat - проверка на прохождения Валютного контроля для Юр.лиц при взносу и снятию наличной иностранной валюты */

	find first joudoc where joudoc.docnum = jh.ref no-lock no-error.
	if avail joudoc then
	do:
		/* Проверка на валютный счет */
		if (joudoc.drcur <> 1 or joudoc.crcur <> 1 ) then
		do:
			/* Получение дебетовой суммы в долларах */
			find first crc where crc.crc = joudoc.drcur no-lock no-error.
			if crc.crc <> 2 then
			do:
				db_sum = joudoc.dramt * crc.rate[1].
				find first crc where crc.crc = 2 no-lock no-error.
				db_sum = db_sum / crc.rate[1].
			end.
			else db_sum = joudoc.dramt.

			/* Получение кредитовой суммы в долларах */
			find first crc where crc.crc = joudoc.crcur no-lock no-error.
			if crc.crc <> 2 then
			do:
				cr_sum = joudoc.cramt * crc.rate[1].
				find first crc where crc.crc = 2 no-lock no-error.
				cr_sum = cr_sum / crc.rate[1].
			end.
			else cr_sum = joudoc.cramt.

			/* Проверка по сумме */
			/* if (db_sum >= 50000 or cr_sum >= 50000 ) then do: */
			/*  Проверка на юр.лицо  */
			find aaa where aaa.aaa = joudoc.cracc no-lock no-error. /* проверим кредит */
			if not available aaa then
				find aaa where aaa.aaa = joudoc.dracc no-lock no-error. /* проверим дебет */
				if available aaa then if substr (get-kod(aaa.aaa, ''), 1, 1) = '2' then
				do:
					/* Основная проверка "Прохождение Валютного контроля" */
						find cursts where cursts.acc = string(joudoc.docnum) and cursts.sub = "jou" no-lock no-error.
						if avail cursts then
						do:
							if cursts.valaks <> "val" then
							do:
								message " Платеж должен пройти контроль Департаментом Валютного контроля 9.9 !" view-as alert-box button ok title " ВНИМАНИЕ ! ".
								bell. bell.
								pause.
								next.
							end.
						end.
						else
						do:
							message "Не найдена запись в таблице cursts!!!".
							bell. bell.
							pause.
							next.
						end.
					/* end of -- Основная проверка "Прохождение Валютного контроля" */

				end.
			/* end of -- Проверка на юр.лицо */
			/* end.*/
			/* end of -- Проверка по сумме */

		end.
		/* end of -- Проверка на валютный счет */
	end.
	/* end of -- 29.07.04 saltanat - проверка на прохождения Валютного контроля для Юр.лиц при взносу и снятию наличной иностранной валюты */


	if okey then
	do:
		ttt = jh.party .
		if ttt = '' and m-ttt = 1 then
		do:
			view frame tur.
			message vcha9 update v-log.
			if v-log then
			do :
				hide frame tur. next.
			end.
			else  hide frame tur.
		end.
		else display ttt with frame qqq.
		/********************/
		if y_ock then
		repeat on endkey undo, next ccc:
			find ock where ock.ock eq o_ock no-lock no-error.
			if not (ock.ctype eq "TC" or ock.ctype eq "VC") then
			do:
				va-cheque = "".
				va-amount = 0.
				va-crc = 0.
				update va-cheque va-amount va-crc with frame f_ock.
				find ccrc where ccrc.crc eq va-crc no-lock no-error.
				display ccrc.des with frame f_ock.
				if va-cheque ne ock.cheque then
				do:
					message "Номер чека не совпадает!".
					undo, next.
					end.
				else
					if va-amount ne a_ock then do:
						message "Сумма чека не совпадает!".
						undo, next.
					end.
					else
						if va-crc ne c_ock then do:
							message "Валюта чека не совпадает!".
							undo, next.
						end.
						else do:
							display va-cheque with frame qqq.
								pause 0.
							leave.
						end.
			end.
			else
				if ock.ctype eq "TC" or ock.ctype eq "VC" then do:
					va-amount = 0.
					va-crc = 0.
					a_ock = 0.
					for each jl of jh use-index jhln break by jl.crc.
						if jl.gl eq sysc.inval then a_ock = a_ock + jl.dam.
					end.
					update va-amount va-crc with frame f_ock.
					find ccrc where ccrc.crc eq va-crc no-lock no-error.
					display ccrc.des with frame f_ock.
					if va-amount ne a_ock then do:
						message "Сумма чека не совпадаеет! ".
						undo, next.
					end.
					else
						if va-crc ne c_ock then do:
							message "Валюта чека не совпадает!".
							undo, next.
						end.
						else do:
							display ock.spby with frame qqq.
							pause 0.
							leave.
						end.
				end.
		end.
		/********************/

		for each jl of jh where (jl.gl = c-gl or jl.gl = c-gl1002) use-index jhln break by jl.crc with 8 down centered  frame www:
			if jl.gl = c-gl then
			do:
				if available cash and cash.loval and jl.crc = 1 then
				do:
					find first jlsach where jlsach.jh = jl.jh and jlsach.ln = jl.ln no-lock no-error.
					if not available jlsach  then
					do:
						message " Не введен символ кас.плана !!!! ".
						bell. bell.
						leave ccc.
					end.
					else  do:
						find first cashpl where cashpl.sim = jlsach.sim and cashpl.act no-lock no-error.
                        if not avail cashpl then message " Не введен символ кас.плана !!!! ".
					end.
				end.
			end.
			/* 10.05.94 */
			if (v-1001 and jl.gl = c-gl) or (not v-1001 and v-1002 and jl.gl = c-gl1002) then
			do:
				accumulate jl.dam ( total by jl.crc ).
				accumulate jl.cam ( total by jl.crc ).
			end.
			i = i + 1.
			if available cash and cash.loval and jl.crc = 1 and avail cashpl then
			do:
				jl.rem[5] = string(cashpl.sim, "zzz") + " " + cashpl.des.
			end.
			find crc where crc.crc = jl.crc no-lock no-error.
			{x-cash2.f}
			pause 0.
			if i = 8 then
			do:
				i = 0.
				pause.
			end.
			if last-of(jl.crc) then
			do :
				v-amt = ( accum total by jl.crc jl.dam) - (accum total by jl.crc jl.cam).
				if  v-amt gt 0 then
				do:
					what = vcha15.
					bank = true.
				end.
				else do:
					what = vcha4.
					v-amt = - v-amt.
					bank = false.
				end.
				display vcha6 no-label what v-amt format "z,zzz,zzz,zzz,zzz,zz9.99-" crc.code with color display message row 19 - icrc icrc  down overlay centered no-label frame aa.
				pause 0.
			end.
		end.
		uuu = 0.
		find first jl where jl.jh = p-pjh and jl.aah <> 0 no-lock no-error.
		if available jl then
		do:
			v-noc = substr(jl.rem[1],231,6).
/*
			find aah where aah.aah = jl.aah  no-lock no-error.
			if available aah then
			do:
				find aaa where aaa.aaa = aah.aaa no-lock no-error.
				find cif of aaa no-lock.
				if available cif then if cif.type = 'B' or cif.type = 'M' or cif.type = 'N' then uuu = 1.
			end.
*/
			/*Janson 25/08/98 Check number from joudoc*/
			/*  find jh where jh.jh = p-pjh exclusive-lock no-error. */
			if available jh and jh.party begins "jou" then
			do:
				find joudoc where joudoc.docnum = substring(jh.party,1,10) no-lock no-error.
				if available joudoc and joudoc.chk > 0 then
				do:
					uuu = 1.
					v-noc = string(joudoc.chk).
				end.
			end.
			/*End Janson 25/08/98*/
			if uuu = 1 and v-noc <> '' then display vcha8 no-label v-noc no-label with color display message row 16 overlay centered no-label no-box frame aa1.
			pause 0.
		end.
		v-yes = false.   /*  15/11/93 - AGA    */
		s-jh = jh.jh.
        /*Luiza--------------------------------------------------------*/
        v-transf = no.
        for each jl where jl.jh = s-jh no-lock.
            if (jl.gl >= 185800) and (jl.gl <= 185999) then v-transf = yes.
            if (jl.gl >= 285800) and (jl.gl <= 285999) then v-transf = yes.
        end.
        if v-transf then do:
            find first joudoc where joudoc.jh = s-jh no-lock no-error.
            if v-noord = no then do:
                run vou_bankt(0,1,joudoc.info).
                run vou_bankt(0,1,joudoc.info).
            end.
            else run printord(s-jh,"").
         end.
        /*---------------------------------------------------------------*/
        else do:
            if v-noord = no then do:
                run vou_bank(0).
                run vou_bank(0).
            end.
            else run printord(s-jh,"").
        end.

		message vcha7 update v-yes.
		if v-yes then do transaction:

			if k-point <> v-point then do:
				v-yes = false.
				message "Проводка создана в другом пункте. Штамповать?" update v-yes.
				if v-yes then do:
					find ofc where ofc.ofc = g-ofc use-index ofc no-lock.
					for each jl of jh exclusive-lock:
						jl.point = ofc.regno / 1000 - 0.5.
						jl.depart = ofc.regno MODULO 1000.
					end.
					release jl.
					jh.point = ofc.regno / 1000 - 0.5.
					jh.depart = ofc.regno MODULO 1000.
				end.
				else undo, next ccc.
			end.
			for each jl of jh:
				if jl.acc ne "" and  jl.aax = 1  then
				do:
					find aaa where aaa.aaa = jl.acc exclusive-lock no-error.
					if avail aaa then
					do:
						aaa.cbal = aaa.cbal + jl.dam + jl.cam .
						aaa.fbal[1] = aaa.fbal[1] - (jl.dam + jl.cam).
						jl.aax = 0.
					end.
				end.
				/* -------CASHOFC RECORD -------------------- 18.10.2001, sasco ----------*/
				if jl.gl eq c-gl then
				do:
					find cashofc where cashofc.whn eq g-today and cashofc.sts eq 2 and cashofc.ofc eq g-ofc and cashofc.crc eq jl.crc exclusive-lock no-error.
					if avail cashofc then
					do:
						cashofc.amt = cashofc.amt + jl.dam - jl.cam.
					end.
					else
					do:
						create cashofc.
							cashofc.whn = g-today.
							cashofc.ofc = g-ofc.
							cashofc.crc = jl.crc.
							cashofc.sts = 2.
							cashofc.amt = jl.dam - jl.cam.
					end.
					release cashofc.
				end.
				/* ------------------------------------------ 18.10.2001, sasco ----------*/
				jl.sts = 6.
				jl.teller = g-ofc.
			end.
			jh.sts = 6.

            run del-check. /* удаление из списка использованного листа ЧК */

			if jh.sub ne "" and jh.ref ne "" and jh.sub ne "lon" then
			do:
				run chgsts(jh.sub, jh.ref, "rdy").
			end.
			if jh.sub ne "" and jh.ref ne "" and jh.sub = "lon" then
			do:
				run chgsts(jh.sub, string(jh.jh), "rdy").
			end.

/***** Интеграция с Золотой короной *************************************************************/
   find first joudoc where joudoc.docnum = jh.party and joudoc.rescha[5] <> '' no-lock no-error.
   if avail joudoc then do:

       case entry(1, joudoc.rescha[5], " "):
         when 'ZK' then do:
           if entry(2, joudoc.rescha[5], " ") = "2" then p-tr-state = "0". /* отправка */
           if entry(2, joudoc.rescha[5], " ") = "5" then p-tr-state = "1". /* выдача */
           if entry(2, joudoc.rescha[5], " ") = "6" then p-tr-state = "2". /* возврат */

           run qpay_state(entry(3, joudoc.rescha[5], " "),string(jh.jh),p-tr-state,output p-errdes,output p-err).
           if not p-err then do:
             /*Ошибка при изменении статуса*/
             message "Ошибка при изменении статуса документа " entry(3, joudoc.rescha[5], " ") "~n" p-errdes view-as alert-box.
             /* И отправить сообщение контроллеру для ручного изменения статуса в АРМ*/
           end.

         end.
        when 'UN' then do:
            if entry(2, joudoc.rescha[5], " ") = "10" then p-tr-state = "1". /* отправка */
            if entry(2, joudoc.rescha[5], " ") = "42" then p-tr-state = "2". /* выдача */
            if entry(2, joudoc.rescha[5], " ") = "42" then p-tr-state = "2". /* возврат */

            run upay_state(entry(3, joudoc.rescha[5], " "),string(jh.jh),p-tr-state,output p-errdes,output p-err).
            if not p-err then do:
            /*Ошибка при изменении статуса*/
            message "Ошибка при изменении статуса документа " entry(3, joudoc.rescha[5], " ") "~n" p-errdes view-as alert-box.
            /* И отправить сообщение контроллеру для ручного изменения статуса в АРМ*/
            end.

        end.
         when 'WU' then do:
          /*когда будем интегрировать например с WU*/
         end.
         otherwise do:
         end.
       end case.
   end.
/*************************************************************************************************/

/* Luiza 07.07.2011 ТЗ 901 часть 1 ----------------------------------------------------------------------------------------*/
/* создаем проводку для комиссии при пополнении счета клиента или арп счета, если суммы на счете для снятия комиссии было не достаточно в момент пополнения.*/

def var ss-jh1 as int.
def var ss-jh2 as int.
find first joudoc where joudoc.docnum = jh.party no-lock no-error.
if available joudoc and joudoc.dracctype = "1" and (joudoc.cracctype = "2" or joudoc.cracctype = "4") then do:
    if trim(joudoc.vo,"&") <> "" then do:
        if NUM-ENTRIES(joudoc.vo,"&") <= 4 then do: /* значит линии комиссии не созданы */
            if entry(3,joudoc.vo,"&")  = "arp" then do: /* было ли пополнение арп счета */
                find first arp where arp.arp = joudoc.comacc no-lock no-error.
                if not available arp then do:
                    message "Ошибка, не найден счет арп в таблице arp"  view-as alert-box error.
                    return.
                end.
                ss-jh1 = 0.
                if joudoc.docnum = trim(entry(4,joudoc.vo,"&")) then do:
                    for each jl where jl.jh = s-jh exclusive-lock.
                        jl.sts = 0.
                    end.
                    for each jh where jh.jh = s-jh exclusive-lock.
                        jh.sts = 0.
                    end.
                    run trxgen (entry(1,joudoc.vo,"&"), vdel, entry(2,joudoc.vo,"&"), entry(3,joudoc.vo,"&") , entry(4,joudoc.vo,"&"), output rcode, output rdes, input-output s-jh).
                    if rcode ne 0 then do:
                        message rdes.
                        pause.
                        undo, return.
                    end.
                    MESSAGE "Проводка для комиссии сформирована: " + string(s-jh) view-as alert-box.
                    for each jl where jl.jh = s-jh exclusive-lock.
                        jl.sts = 6.
                        jl.teller = g-ofc.
                    end.
                    for each jh where jh.jh = s-jh exclusive-lock.
                        jh.sts = 6.
                        assign jh.stmp_tim = time
                               jh.jdt_sts = today.
                    end.
                    find first jh where jh.jh = s-jh no-lock.
                    find first jl where jl.jh = s-jh no-lock.

                    find first joudoc where joudoc.docnum = jh.party exclusive-lock no-error.
                    joudoc.vo = joudoc.vo + "&stamp".
                    find first joudoc where joudoc.docnum = jh.party no-lock no-error.
                    run del-check. /* удаление из списка использованного листа ЧК */
                end.
            end.
            if entry(3,joudoc.vo,"&")  = "cif" or entry(3,joudoc.vo,"&") = "jou" then do: /* было ли пополнение счета клиента*/
                find first aaa where aaa.aaa = joudoc.comacc no-lock no-error.
                if not available aaa then do:
                    message "Ошибка, не найден счет клиента в таблице ааа"  view-as alert-box error.
                    return.
                end.
                else do:
                    def var v-comcode as char init "".
                    find first tarif2 where tarif2.str5  = joudoc.comcode no-lock no-error.
                    if available tarif2 then v-comcode = tarif2.pakalp.
                    if aaa.cbal - aaa.hbal < joudoc.comamt then do: /* тогда запишем в долг   */
                        create bxcif.
                        bxcif.cif = aaa.cif.
                        bxcif.amount = joudoc.comamt.
                        bxcif.whn = g-today.
                        bxcif.who = g-ofc.
                        bxcif.tim = time.
                        bxcif.aaa = joudoc.comacc.
                        bxcif.type = joudoc.comcode.
                        bxcif.crc = aaa.crc.
                        bxcif.pref = yes.
                        bxcif.jh = s-jh.
                        if v-comcode <> "" then bxcif.rem = "#Комиссия за " + v-comcode  + ". За " + string(g-today) + " пополнение счета транз: " + string(s-jh).
                        else bxcif.rem = "#Комиссия за (код комиссии) " + joudoc.comcode + ". За " + string(g-today) + " пополнение счета транз: " + string(s-jh) .

                        find first joudoc where joudoc.docnum = jh.party exclusive-lock no-error.
                        joudoc.vo = joudoc.vo + "&debt".
                        find first joudoc where joudoc.docnum = jh.party no-lock no-error.
                    end.
                    else do:
                        ss-jh1 = 0.
                        if joudoc.docnum = trim(entry(4,joudoc.vo,"&")) then do:
                            for each jl where jl.jh = s-jh exclusive-lock.
                                jl.sts = 0.
                            end.
                            for each jh where jh.jh = s-jh exclusive-lock.
                                jh.sts = 0.
                            end.
                            run trxgen (entry(1,joudoc.vo,"&"), vdel, entry(2,joudoc.vo,"&"), entry(3,joudoc.vo,"&") , entry(4,joudoc.vo,"&"), output rcode, output rdes, input-output s-jh).
                            if rcode ne 0 then do:
                                message rdes.
                                pause.
                                undo, return.
                            end.
                            MESSAGE "Проводка для комиссии сформирована: " + string(s-jh) view-as alert-box.
                            for each jl where jl.jh = s-jh exclusive-lock.
                                jl.sts = 6.
                                jl.teller = g-ofc.
                            end.
                            for each jh where jh.jh = s-jh exclusive-lock.
                                jh.sts = 6.
                            end.
                            find first jh where jh.jh = s-jh no-lock.
                            find first jl where jl.jh = s-jh no-lock.

                            find first joudoc where joudoc.docnum = jh.party exclusive-lock no-error.
                            joudoc.vo = joudoc.vo + "&stamp".
                            find first joudoc where joudoc.docnum = jh.party no-lock no-error.
                        end.
                    end.  /* end else*/
                end.
            end.  /* entry(3,joudoc.vo)  = "cif"  */
        end. /* if NUM-ENTRIES(joudoc.vo,"&") <= 4  */
    end.
end. /* if available joudoc .....*/
/***------------------------------------------------------------------------------------------------------------------------------------*/
/**********marinav 03.07.2010************************/
                        find first filpayment where filpayment.bankfrom = s-ourbank and filpayment.jh = s-jh no-lock no-error.
                        if avail filpayment and filpayment.type = 'add' and filpayment.rem[1] = ''  then do:
                                 v-mail = replace(filpayment.info[3],"oper.dep@metrocombank.kz;","").
                                 def var v-rmz  like remtrz.remtrz no-undo.
                                 run rmzcre (
                                 filpayment.jh    ,
                                 filpayment.amount ,
                                 filpayment.arp ,
                                 filpayment.rnnfrom     ,
                                 filpayment.namefrom     ,
                                 filpayment.bankto   ,
                                 filpayment.iik    ,
                                 filpayment.name   ,
                                 filpayment.rnnto   ,
                                 ''      ,
                                 no ,
                                 filpayment.knp     ,
                                 filpayment.kod     ,
                                 filpayment.kbe     ,
                                 filpayment.info[1]   ,
                                 '1P'     ,
                                 1     ,
                                 5     ,
                                 g-today    ).

                             v-rmz = return-value.

                             find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
                             if avail remtrz then do:
                                 remtrz.source = 'P'.
                                 remtrz.ordins[1] = "ЦО ".
                                 remtrz.ordins[2] = " ".
                                 remtrz.valdt1 = g-today.
                                 remtrz.valdt2 = g-today.
                                 find current filpayment exclusive-lock.
                                 filpayment.rem[1] = v-rmz.
                                 filpayment.rem[4] = remtrz.ref. /* номер платежа для поиска его в филиале */
                                 find current filpayment no-lock.
                                 message "Платеж " v-rmz " на пополнение счета " filpayment.iik " отправлен.~n Счет будет пополнен после прохождения проверок финансового мониторинга!" view-as alert-box.
                                 find crc where crc.crc = filpayment.crc no-lock no-error.
                                 run mail   (v-mail /*filpayment.info[3]*/,
                                          "METROCOMBANK <mkb@metrocombank.kz>",
                                          "Межфилиальный Перевод ",
                                          "Добрый день!\n\n ФИО: " + filpayment.name + "\n ИИК: " + filpayment.iik + "\n Пополнение счета \n " +
                                           string(filpayment.amount) + "  " + crc.code + "\n " + string(filpayment.whn) + "\n " + filpayment.who + "\n\n Внимание! Счет будет пополнен после прохождения проверок финансового мониторинга!",
                                           "1", "","" ).

                            end.
                            else do:
                                message "Ошибка при отправке платежа на пополнение счета " filpayment.iik " !" view-as alert-box title "".
                                return.
                            end.

                            /* Luiza 05.07.2011 формируем межфилиальный платеж на снятие комиссии со счета клиента, если filpayment.rem[2] = '2'  */
                            find first filpayment where filpayment.bankfrom = s-ourbank and filpayment.jh = s-jh no-lock no-error.
                            if avail filpayment and filpayment.stscom = "new1"  and filpayment.type = 'add' and trim(filpayment.rem[2]) = '2'  then do:
                                   find first txb where txb.bank = filpayment.bankto no-lock no-error.
                                   if not avail txb then return.

                                   if connected ("txb") then disconnect "txb".
                                   connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

                                    if filpayment.amountcom > 0 then do:
                                       run rmzcretxb (
                                        1    ,
                                        filpayment.amountcom,
                                        entry(1,filpayment.info[8]) ,
                                        filpayment.rnnto    ,
                                        filpayment.name     ,
                                        filpayment.bankfrom   ,
                                        filpayment.info[10] /*filpayment.arp */   ,
                                        filpayment.namefrom   ,
                                        filpayment.rnnfrom   ,
                                        ''      ,
                                        no ,
                                        "840",    /*filpayment.knp  ,    */
                                        filpayment.kbe  ,
                                        "14",      /* filpayment.kod  ,*/
                                        'Комиссия за ' + filpayment.info[7] ,
                                        '2W'     ,
                                        1     ,
                                        5     ,
                                        g-today,
                                        'arp'    ).
                                        v-rmz = return-value.
                                        if connected ("txb") then disconnect "txb".
                                        if v-rmz ne "" then  do:
                                                message "Платеж " v-rmz " на списание комиссии со счета " entry(1,filpayment.info[8]) "сделан. Транзитный счет будет пополнен через 5 минут!" view-as alert-box.
                                                find crc where crc.crc = filpayment.crc no-lock no-error.
                                                run mail   (v-mail /*filpayment.info[3]*/,
                                                          "METROCOMBANK <mkb@metrocombank.kz>",
                                                          "Межфилиальный Перевод ",
                                                          "Добрый день!\n\n ФИО: " + filpayment.name + "\n ИИК: " + entry(1,filpayment.info[8]) + "\n списание комиссии со счета \n " +
                                                           string(filpayment.amountcom) + "  " + crc.code + "\n " + string(g-today) + "\n " + g-ofc,
                                                           "1", "","" ).
                                                 find current filpayment exclusive-lock.
                                                 filpayment.rem[3] = v-rmz.  /* номер rmz для комиссии  */
                                                 find current filpayment no-lock.
                                        end.
                                        else do:
                                            message "Ошибка при формировании платежа на списание комиссии со счета " entry(1,filpayment.info[8]) " !" view-as alert-box title "".
                                            undo, return.
                                        end.
                                    end. /*filpayment.amountcom > 0*/
                            end.  /* trim(filpayment.rem[2]) = "2"   */
                        end. /* if avail filpayment*/
/**********************************/

			/* sasco - создание файла для BWX */
			if jh.party = 'BWX' then do:
				find mobtemp where mobtemp.phone = string(jh.jh) and mobtemp.state >= 300 no-error.
				if avail mobtemp then do:
/*					create cpay.
					assign cpay.card = entry(1, mobtemp.ref, '/')
						cpay.sum = mobtemp.sum
						cpay.crc = (if mobtemp.rid = 1 then "KZT" else (if mobtemp.rid = 2 then "USD" else "XXX")).

					if mobtemp.state = 300 then /* обычная сумма */
					do:
						assign cpay.trxdes = "CASH DEPOSIT"
							cpay.batchdes = "CASH DEPOSIT"
							cpay.messtype = "PAYCCD".
						/* формирование файла для BWX */
						run crdpaygen (output outname).
					end.
					if mobtemp.state = 301 then /* страховой депозит */
					do:
						assign cpay.trxdes = "CASH SECURE DEPOSIT"
							cpay.batchdes = "CASH SECURE DEPOSIT"
							cpay.messtype = "PAYCARDSEC".
						/* формирование файла для BWX */
						run crdpaygen2 (output outname).
					end.
					/* очистим временную таблицу */
					find first cpay.
					delete cpay.
					/* скопируем файл для BWX */
					run savelog ("crdquick", SUBSTITUTE ("Отправка файла &1 пополнения карточки # &2 проводка &3 на сумму &4", outname, entry(1, mobtemp.ref, '/'), mobtemp.phone, mobtemp.sum)).
					if comm-txb() = "TXB00" then
					do:
						/* isaev если Алматинский платеж карточек то кидаем BWX на NTMAIN */
						def var bwxdir as char no-undo.
						/* bwxdir = "NTMAIN:L:\\Users\\Private\\Departments\\Bwx\\Salary\\". */
						bwxdir = "\\\\ntmain\\capital\$\\Users\\Departments\\Bwx\\Salary\\".
						find first bookcod where bookcod = 'cardaccs' and bookcod.code = 'bwxdir' no-lock no-error.
						if avail bookcod then bwxdir = TRIM(bookcod.name).
						else message "Не найден код BWXDIR в справочнике CARDACCS пункт 4.6.1" view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
						def var rcd as char.
						rcd = unix_s("rcp " + outname + " " + bwxdir).
						if rcd <> "" then
							message "Ошибка копирования BWX файла \n" + outname + "\n" + rcd.
					end.
					else
					do:
					/* иначе копируем BWX файл во временный каталог и содаем внешний платеж и справочник со сссылкой на BWX файл во временном каталоге */
						define variable kztacc as character no-undo.
						define variable usdacc as character no-undo.
						find sysc where sysc.sysc = "CRDQCK" no-lock no-error.
						if not available sysc then {error.i "Нет переменной CRDQCK в таблице SYSC!"}
						if num-entries (sysc.chval) < 2 then {error.i "Нет списка всех счетов в CRDQCK в таблице SYSC!"}
						kztacc = entry (1, sysc.chval).
						usdacc = entry (2, sysc.chval).
						find arp where arp.arp = kztacc no-lock no-error.
						if not available arp then {error.i "Нет счета АРП для KZT! проверьте CRDQCK в SYSC!"}
						find arp where arp.arp = usdacc no-lock no-error.
						if not available arp then {error.i "Нет счета АРП для USD! проверьте CRDQCK в SYSC!"}
						def var bwxtdir as char no-undo.
						bwxtdir = '/home/isaev/bwx/'.
						find first bookcod where bookcod = 'cardaccs' and bookcod.code = 'bwxtdir' no-lock no-error.
						if avail bookcod then bwxtdir = trim(bookcod.name).
						else message "Не найден код BWXTDIR в справочнике CARDACCS пункт 4.6.1" view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
						unix silent value("cp " + outname + " " + bwxtdir).
						/* счет получателя в Ц.О. */
						find first bookcod where bookcod = 'cardaccs' and bookcod.code = string(mobtemp.rid) no-lock no-error.
						if not avail bookcod then
						do:
							message "Не найдены счета для получателя на пополнение карт счетов" view-as alert-box.
							return.
						end.
						def var thisacc as char.
						if mobtemp.rid = 1 then thisacc = kztacc.
						else thisacc = usdacc.
						/* транзитный счет с которого делается перевод. sysc = 'CRDQCK' */
						find first arp where arp.arp = thisacc no-lock.  /* arp*/
						def var rz like remtrz.remtrz.
						run commpl(
							time,                                                        /*  1 Номер документа */
							mobtemp.sum,                                                 /*  2 Сумма платежа */
							arp.arp,                                                     /*  3 Счет отправителя т.е. АРП счет */
							"TXB00",                                                     /*  4 Банк получателя */
							bookcod.name,                                                /*  5 Счет получателя */
							0,                                                           /*  6 КБК */
							no,                                                          /*  7 Тип бюджета - проверяется если есть КБК */
							arp.des,                                                     /*  8 Бенефициар */
							"600900050984",                                              /*  9 РНН Бенефициара */
							"311",                                                       /* 10 KNP */
							"19",                                                        /* 11 Kod */
							"14",                                                        /* 12 Kbe */
							"Пополнение карт. счета " + entry(1, mobtemp.ref, '/') +     /* 13 Назначение платежа */
							"~nДержатель: " + entry(3, mobtemp.ref, '/') +
							"~nРНН: " + entry(2, mobtemp.ref, '/'),
							"1P",                                                        /* 14 Код очереди */
							1,                                                           /* 15 Кол-во экз. */
							5,                                                           /* 16 remtrz.cover (для проверки даты валютирования т.е. 1-CLEAR00 или 2-SGROSS00) */
							entry(2, mobtemp.ref, '/'),                                  /* 17 РНН отправителя */
							entry(3, mobtemp.ref, '/')                                   /* 18 ФИО отпр. если не найдено в базе RNN */
						).
						rz = return-value.
						find remtrz where remtrz.remtrz = rz exclusive-lock no-error.
						remtrz.rsub = 'arp'.
						find current remtrz no-lock no-error.
						if avail remtrz then
						do:
							find first sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'RMZ' and sub-cod.d-cod = 'zattach' no-lock no-error.
							if not avail sub-cod then create sub-cod.
							assign sub-cod.acc = rz
							sub-cod.sub = 'RMZ'
							sub-cod.d-cod = 'zattach'
							sub-cod.ccode = 'card'
							sub-cod.rcode = bwxtdir + '/' + outname.
						end.
					end.
					unix silent value ("rm  " + outname).
					delete mobtemp.
*/
			end.
			else message "Ошибка!~nПроводка БЫЛА отштампована (Это в порядке)~nНо Вы должны сообщить в Департамент~n" +
					"Пластиковых Карточек и программистам,~nчто есть сумма, не прошедшая ~nпополнение пластиковой карточки!!!" view-as alert-box title "".
		end.

		if jh.party begins "RMZ" then
		do:
			find first remtrz where remtrz.remtrz = substr(jh.party,1,10) no-lock no-error.
			if avail remtrz then
			do:
				if jh.jh = remtrz.jh1 then v-text = "1 Пров отштамповал  " + g-ofc + " for " + remtrz.remtrz .
				else if jh.jh = remtrz.jh2 then v-text = "2 Пров отштамповал   " + g-ofc + " for " + remtrz.remtrz .
				run lgps.
			end.
		end.
		/******************/
		if po-jh ne 0 and po-jh ne ? then
		do:
			find jh where jh.jh = po-jh exclusive-lock.
			for each jl of jh exclusive-lock:
				/* -------CASHOFC RECORD -------------------- 18.10.2001, sasco ----------*/
				if jl.gl eq sysc.inval then
				do:
					find cashofc where cashofc.whn eq g-today and cashofc.sts eq 2 and cashofc.ofc eq g-ofc and cashofc.crc eq jl.crc exclusive-lock no-error.
					if avail cashofc then
					do:
						cashofc.amt = cashofc.amt + jl.dam - jl.cam.
					end.
					else
					do:
						create cashofc.
							cashofc.whn = g-today.
							cashofc.ofc = g-ofc.
							cashofc.crc = jl.crc.
							cashofc.sts = 2.
							cashofc.amt = jl.dam - jl.cam.
					end.
					release cashofc.
				end.
				/* ------------------------------------------ 18.10.2001, sasco ----------*/
				jl.sts = 6.
				jl.teller = g-ofc.
			end.
			jh.sts = 6.
			release jh.
			release jl.
		end.
		/****************/

	end.
	ELSE
		IF v-yes eq false and (po-jh ne ? and po-jh ne 0) then
		do:
			hide frame ll.
			find jh where jh.jh = po-jh no-error.
			if avail jh then v-sts = jh.sts.
			else v-sts = 0.
			run trxsts (input po-jh, input 0, output ccode, output cdes).
			if ccode ne 0 then
			do:
				message cdes.
				return.
			end.
			run trxdel (input po-jh, input true, output ccode, output cdes).
			if ccode ne 0 then
			do:
				message cdes.
				if ccode eq 50 then run trxsts (input po-jh, input v-sts, output ccode, output cdes).
				return.
			end.
			po-jh = ?.
			display p-pjh with frame qqq row 3.
		end.
		clear frame hh.
end. /* okey */

/* 13/07/05 nataly*/
{cash.i}
/* 13/07/05 nataly*/

/* kanat печать чека БКС - по желанию кассира - отделил от основного блока при v-yes = true на всякий пожарный */
if v-yes then
do:
		v-payment = ''.
		find first jh where jh.jh = p-pjh no-lock no-error.
		if avail jh and jh.sts = 6 then
		do:
			for each jl where jl.jh = jh.jh no-lock.
				if jl.gl = c-gl or jl.gl = c-gl1002 then
				do:
					find first crc where crc.crc = jl.crc no-lock no-error.
					v-payment = v-payment + string(p-pjh) + "#" + jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5] + "#" + string(jl.dam + jl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
				end.
			end.
			v-payment = right-trim(v-payment,"|").
			if v-payment <> '' then do:
                if v-noord = no then run bks (v-payment,"TRX").
                else run printbks (v-payment,"TRX").
		    end.
        end.
end.
	hide frame aa.
	hide frame aa1.
end.

hide frame www.
ttt = " ".
y_ock = false.  /******************************/
display ttt with frame qqq.
find bb-ofc where bb-ofc.ofc = g-ofc no-lock no-error.
if comm-txb() = "TXB00" and bb-ofc.regno mod 1000 = 1 then
do: /*Только Алматы ЦО*/
	find last cashier where cashier.ofc = g-ofc no-lock no-error.
	if avail cashier then
	do:
		v-ofile = "ks" + string(substr(cashier.kasnum,7,1)) + ".txt".
		output stream v-out to value(v-ofile).
		put stream v-out unformatted "     ".
		output stream v-out close.
		unix silent value ("rcp " + v-ofile + v-paf).
if substr(cashier.kasnum,7,1) = "1" then current-value(ks1) = 0. else
if substr(cashier.kasnum,7,1) = "2" then current-value(ks2) = 0. else
if substr(cashier.kasnum,7,1) = "3" then current-value(ks3) = 0. else
if substr(cashier.kasnum,7,1) = "4" then current-value(ks4) = 0.

		p-pjh = 0.
		display p-pjh with frame qqq.
	end.
end.
end.

procedure del-check:
    def var s1 as char.
    def var s2 as char.
    def var str-pages as char.
    def var v-bank as char.

    if avail joudoc and joudoc.chk > 0 and joudoc.kfmcif = "" then do:

        /*find first nmbr where nmbr.code = "Cif" no-lock no-error.
        if avail nmbr and nmbr.prefix = substr(joudoc.kfmcif,1,1) then do:*/
            find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk and checks.pages <> "" no-lock no-error.
            if avail checks then do:
                if index(checks.pages, string(joudoc.chk)) > 0 then do:
                    s1 = substr(checks.pages, 1, index(checks.pages, string(joudoc.chk)) - 1).
                    s2 = substr(checks.pages, index(checks.pages, string(joudoc.chk)) + length(string(joudoc.chk)) + 1).
                    str-pages = s1 + s2.
                end.
            end.
            do transaction:
                find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk and checks.pages <> "" exclusive-lock no-error.
                if avail checks then do:
                    checks.pages = str-pages.
                    find last checks where checks.nono <= joudoc.chk and checks.lidzno >= joudoc.chk no-lock no-error.
                end.
            end.
        /*end.*/
    end.
    else
    if avail joudoc and joudoc.chk > 0 and joudoc.kfmcif <> "" then do:
        if substr(joudoc.kfmcif,1,1) = "a" then v-bank = "TXB00".
        if substr(joudoc.kfmcif,1,1) = "b" then v-bank = "TXB01".
        if substr(joudoc.kfmcif,1,1) = "c" then v-bank = "TXB02".
        if substr(joudoc.kfmcif,1,1) = "d" then v-bank = "TXB03".
        if substr(joudoc.kfmcif,1,1) = "e" then v-bank = "TXB04".
        if substr(joudoc.kfmcif,1,1) = "f" then v-bank = "TXB05".
        if substr(joudoc.kfmcif,1,1) = "h" then v-bank = "TXB06".
        if substr(joudoc.kfmcif,1,1) = "k" then v-bank = "TXB07".
        if substr(joudoc.kfmcif,1,1) = "l" then v-bank = "TXB08".
        if substr(joudoc.kfmcif,1,1) = "m" then v-bank = "TXB09".
        if substr(joudoc.kfmcif,1,1) = "n" then v-bank = "TXB10".
        if substr(joudoc.kfmcif,1,1) = "o" then v-bank = "TXB11".
        if substr(joudoc.kfmcif,1,1) = "p" then v-bank = "TXB12".
        if substr(joudoc.kfmcif,1,1) = "q" then v-bank = "TXB13".
        if substr(joudoc.kfmcif,1,1) = "r" then v-bank = "TXB14".
        if substr(joudoc.kfmcif,1,1) = "s" then v-bank = "TXB15".
        if substr(joudoc.kfmcif,1,1) = "t" then v-bank = "TXB16".

        find txb where txb.consolid and txb.bank = v-bank no-lock no-error.
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
            run x1-delchk (joudoc.chk, joudoc.kfmcif).
        disconnect "txb".
    end.
end procedure.