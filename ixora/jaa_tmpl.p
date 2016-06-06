/* jaa_tmpl.p
 * MODULE
	Касса
 * DESCRIPTION
        Обменные операции
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-1-3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
    	17.02.2003 timur    - если vrat = 0 значит не был задан льготный курс обмена
    	02.09.2003 sasco    - для кассиров из sysc."CASOFC".chval предлагает выбор
                          	касса / касса в пути после времени в sysc."CASOFC".inval (17:00 = 61200)
                          	в sysc."CASOFC".chval через запятую - номера РКО
    	03.11.2003 nadejda  - выбор счетов кассы в пути 100200 теперь происходит по профит-центру текущего офицера
   	    19.12.2003 suchkov  - выбор между 100100 и 100200 после 17:00 для ПРОМЕНАДА и всех РКО кто в списке sysc = "CASSOF"
	    30.05.2006 u00121   - Проверка на наличие РКО пользователя в списке переведенных на постоянную работу через кассу в пути
        07/03/08 marinav - отмена справки-сертификата
        21.04.10 marinav - добавилось третье поле примечания
        12/06/2010 madiyar - при поиске транзитников проверяем признак закрытия счета
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
        18/01/2013 Luiza   - ТЗ 1595 Изменение счета ГК 1858
        19/02/2013 Luiza   - добавила шаблоны jou0070 и jou0071
*/

{global.i}
{get-dep.i}

/*u00121 30/05/06 Переменные для определения счета кассы в пути *********************************************************************************************************/
def var v-yn 	as log		no-undo.  /*признак запрещения работы через кассу   false - 100100, true - 100200							*/
def var v-arp 	as char		no-undo.  /*arp-счет кассы в пути если разрешено работать только через кассу в пути							*/
def var v-err 	as log		no-undo.  /*признак возникновения ошибки если true - ошибка имела место, и говорит о том, что желательно прекратить работу программы	*/
/************************************************************************************************************************************************************************/

define input  parameter j_basic as character.
define output parameter j_param as character.
define output parameter j_templ as character.

def  shared var vrat as deci decimals 2.

define buffer bcrc for crc.

define shared variable v_doc like joudoc.docnum.

def var choice as logical no-undo.
define variable vdel    as character initial "^" no-undo.
define variable rcode   as integer no-undo.
define variable rdes    as character no-undo.
define variable jparr   as character format "x(20)" no-undo.

define variable change  as logical no-undo.

define variable d_amt      like joudoc.dramt no-undo.
define variable c_amt      like joudoc.cramt no-undo.
define variable com_amt    like joudoc.comamt no-undo.
define variable m_buy      as decimal no-undo.
define variable m_sell     as decimal no-undo.
define variable buy_rate   like joudoc.brate no-undo.
define variable sell_rate  like joudoc.srate no-undo.
define variable buy_n      like joudoc.bn no-undo.
define variable sell_n     like joudoc.sn no-undo.
def var arp100200d as char init "" no-undo.
def var arp100200c as char init "" no-undo.


define variable was_casofc as logical initial false no-undo.
define variable was_cassof as logical initial false no-undo.
define variable v-dep as char no-undo.

define frame f_cus
    joudoc.info   label "Ф. И. О." skip
    joudoc.passp  label "Паспорт " skip
    joudoc.passpdt label "Дата выдачи паспорта" skip
    with row 15 col 16 overlay side-labels.


v-dep = string(get-dep(g-ofc, g-today)).

/*23.03.2006 u00121 проверим, переведено ли РКО на работу только через КАССУ В ПУТИ**************************************/
run get100200arp(g-ofc, 1, output v-yn, output v-arp, output v-err). /*получим признак разрешения работы только через кассу в пути*/
if not v-yn then /*если разрешено работать через кассу, то работатем по старому*/
	was_casofc = false.
else
	was_casofc = true.
/************************************************************************************************************************/


/* 02.09.2003 sasco - проверим на наличие РКО в списке для 100200 после 17:00 */
find sysc where sysc.sysc = "CASOFC" no-lock no-error.
if available sysc then
  if lookup (v-dep, sysc.chval) > 0 and time >= sysc.inval then was_casofc = true.

/* 19.12.2003 suchkov - а теперь проверим на наличие РКО в списке для выбора между 100100 и 100200 после 17:00 */
find sysc where sysc.sysc = "CASSOF" no-lock no-error.
if available sysc then
  if lookup (v-dep, sysc.chval) > 0 and time >= sysc.inval and time <= integer (sysc.deval) then was_cassof = true.

find joudoc where joudoc.docnum eq v_doc no-lock no-error.

find crc where crc.crc eq joudoc.drcur no-lock no-error.

if j_basic eq "D" then d_amt = joudoc.dramt.
else if j_basic eq "C" then c_amt = joudoc.cramt.

if vrat = 0 then do:
          run conv (input joudoc.drcur, input joudoc.crcur, input true, input true,
                    input-output d_amt, input-output c_amt,
                    output buy_rate, output sell_rate, output buy_n, output sell_n,
                    output m_buy, output m_sell).
end.
else do:
          run conv-obm(input        joudoc.drcur,input        joudoc.crcur,
                       input-output d_amt,       input-output c_amt,
                       output       buy_rate,    output       sell_rate,
                       output       buy_n,       output       sell_n,
                       output       m_buy,       output       m_sell).
end.

if buy_rate ne joudoc.brate then do:
    message substitute
        ("ИЗМЕНИЛСЯ  &1  КУРС ПОКУПКИ. СУММА БУДЕТ ПЕРЕСЧИТАНА.",
         crc.code).
    change = true.
end.

find bcrc where bcrc.crc eq joudoc.crcur no-lock no-error.
if sell_rate  ne joudoc.srate then do:
     message substitute
         ("ИЗМЕНИЛСЯ  &1  КУРС ПРОДАЖИ. СУММА БУДЕТ ПЕРЕСЧИТАНА.",
         bcrc.code).
     change = true.
end.

/* 19.12.2003 suchkov - Спросим кассира, как он хочет провести обменную операцию? */
if was_cassof then do:
    message skip "Сделать операцию через 100100?"
            skip(1) view-as alert-box BUTTONS YES-NO title " ВНИМАНИЕ ! " UPDATE choice1 AS LOGICAL.
    if not choice1 then was_casofc = true .
end.

find sysc where sysc.sysc = "CASVOD" no-lock no-error.
if avail sysc then do transaction:
       /* если не был свод кассы и не предлагаем выбор кассы в пути по 100200 после 17:00 */
       if (not sysc.loval) and (not was_casofc) then  do:
            if j_basic eq "D" then do:
                j_param = joudoc.docnum + vdel + string (joudoc.dramt) + vdel +
                    string (joudoc.drcur) + vdel +
                    (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                    string (joudoc.crcur).

                if joudoc.drcur <> 1 then j_templ = "JOU0029". else j_templ = "JOU0071".


                if change then do:
                    run trxsim("", j_templ, vdel, j_param, 4, output rcode,
                        output rdes, output jparr).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.

                    find current joudoc exclusive-lock.
                    joudoc.cramt = decimal (jparr).
                    joudoc.brate = buy_rate.
                    joudoc.srate = sell_rate.
                    joudoc.bn    = buy_n.
                    joudoc.sn    = sell_n.
                    find current joudoc no-lock.
                end.
            end.
            else if j_basic eq "C" then do:
                j_param = joudoc.docnum + vdel + string (joudoc.drcur) +
                    vdel + (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                    string (joudoc.cramt) + vdel + string (joudoc.crcur).

                if joudoc.drcur <> 1 then j_templ = "JOU0070". else j_templ = "JOU0030".

                if change then do:
                    run trxsim("", j_templ, vdel, j_param, 3, output rcode,
                        output rdes, output jparr).
                    if rcode ne 0 then do:
                        message rdes.
                        pause 3.
                        undo, return.
                    end.
                    find current joudoc exclusive-lock.
                    joudoc.dramt = decimal (jparr).
                    joudoc.brate = buy_rate.
                    joudoc.srate = sell_rate.
                    joudoc.bn    = buy_n.
                    joudoc.sn    = sell_n.
                    find current joudoc no-lock.
                end.
            end.
       end. /* if sysc.loval = false then*/


       /* 20.05.2003 если свод кассы завершен, то делать проводку через 100200 */
       else do:
            find ofc where ofc.ofc = g-ofc no-lock no-error.
            if avail ofc then do:
		if sysc.loval then    /*завершен ли свод кассы*/
              		message skip " Свод кассы завершен." skip(1) " Сделать операцию через 100200?"
                      		skip(1) view-as alert-box BUTTONS YES-NO title " ВНИМАНИЕ ! " UPDATE choice.
		else /*если нет, то по каким-то причинам нам запрещено работать по 100100*/
			choice = true.
              if choice then do: /*в любом случае ищем ARP счет кассы в пути*/
                /* 03.11.2003 nadejda - счета 100200 ищутся по профит-центру текущего офицера */
                arp100200d = "".
                arp100200c = "".
                for each arp where arp.gl = 100200 no-lock:
                  if (arp.crc <> joudoc.drcur) and (arp.crc <> joudoc.crcur) then next.

                  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and
                                     sub-cod.acc = arp.arp no-lock no-error.
                  if not avail sub-cod or sub-cod.ccode <> "obmen1002" then next.

                  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and
                                     sub-cod.acc = arp.arp no-lock no-error.
                  if not avail sub-cod or sub-cod.ccode <> ofc.titcd then next.

                  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
                  if avail sub-cod and sub-cod.ccode <> "msc" then next.

                  if arp.crc = joudoc.drcur then arp100200d = arp.arp.
                  if arp.crc = joudoc.crcur then arp100200c = arp.arp.

                  if arp100200d <> "" and arp100200c <> "" then leave.
                end.

                if arp100200d = "" or arp100200c = "" then do:
                  message skip " Не настроены счета 100200 в данных валютах для вашего департамента!"
                          skip(1) view-as alert-box title " ОШИБКА ! ".
                  undo, return.
                end.
                else do:
                  /* если найдены arp 100200 - делаем что нужно */
                  if j_basic eq "D" then do:
                    j_param = joudoc.docnum                         + vdel +
                              string (joudoc.dramt)                 + vdel +
                              string (joudoc.drcur)                 + vdel +
                              arp100200d                            + vdel +
                              (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                              string (joudoc.crcur)                 + vdel +
                              arp100200c.

                    j_templ = "JOU0011".

                    if change then do:
                        run trxsim("", j_templ, vdel, j_param, 4, output rcode,
                            output rdes, output jparr).
                        if rcode ne 0 then do:
                            message rdes.
                            pause 3.
                            undo, return.
                        end.

                        find current joudoc exclusive-lock.
                        joudoc.cramt = decimal (jparr).
                        joudoc.brate = buy_rate.
                        joudoc.srate = sell_rate.
                        joudoc.bn    = buy_n.
                        joudoc.sn    = sell_n.
                        find current joudoc no-lock.
                    end.
                  end.
                  else if j_basic eq "C" then do:
                    j_param = joudoc.docnum                         + vdel +
                              string (joudoc.drcur)                 + vdel +
                              arp100200d                            + vdel +
                              (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                              string (joudoc.cramt)                 + vdel +
                              string (joudoc.crcur)                 + vdel +
                              arp100200c.

                    j_templ = "JOU0012".

                    if change then do:
                        run trxsim("", j_templ, vdel, j_param, 3, output rcode,
                            output rdes, output jparr).
                        if rcode ne 0 then do:
                           message rdes.
                           pause 3.
                           undo, return.
                        end.

                        find current joudoc exclusive-lock.
                        joudoc.dramt = decimal (jparr).
                        joudoc.brate = buy_rate.
                        joudoc.srate = sell_rate.
                        joudoc.bn    = buy_n.
                        joudoc.sn    = sell_n.
                        find current joudoc no-lock.
                    end.
                  end.
                end. /* avail arp100200 */
              end. /* choice = true */
              else do:
                message skip " Свод кассы завершен. Отмена операции." skip(1) view-as alert-box title "".
                undo, return.
              end.
            end. /* available ofc */
       end. /* sysc.loval = false  */
     /*
       if trim(joudoc.info) eq "" then do:
         find current joudoc exclusive-lock.

            message "Выписывать справку - сертификат?" view-as alert-box question buttons yes-no title "" update v-ans as logical.
            if v-ans = True then do:
            def var d as integer.
                do d = 1 to 100:
                  if (trim(joudoc.info) eq '') or (trim(joudoc.passp) eq '') or joudoc.passpdt = ? then do:
                     update joudoc.info joudoc.passp joudoc.passpdt with frame f_cus.
                  end.
                  if (trim(joudoc.info) eq '') or (trim(joudoc.passp) eq '') or joudoc.passpdt = ?
                     then do: end.
                     else leave.
                end.
            end.
            else do:
                    update joudoc.info joudoc.passp joudoc.passpdt with frame f_cus.
            end.

         find current joudoc no-lock.
       end.
     */
end. /* available sysc */
else do:
  message skip " Не найдена настройка CASVOD. Отмена операции." skip(1) view-as alert-box title "".
end.

