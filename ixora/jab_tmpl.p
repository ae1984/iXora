/* jab_tmpl.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        25.09.2003 suchkov  - модуль скопирован в jab_tmpl.p и внесены коррекции для конвертаций 100100 - 100300
        03.11.2003 nadejda  - номера счетов ARP для 100300 ищутся по признаку sub-cod.ccode = 'po100300' и профит-центру офицера
        07/03/08 marinav - отмена справки-сертификата
        21.04.10 marinav - добавилось третье поле примечания
        12/06/2010 madiyar - при поиске транзитников проверяем признак закрытия счета
        10.01.2011 Luiza   - добавила передачу пустого параметра ("") при вызове trxsim.p
*/

{global.i}
{get-dep.i}

define input  parameter j_basic as character.
define output parameter j_param as character.
define output parameter j_templ as character.

def  shared var vrat as deci decimals 2.

define buffer bcrc for crc.

define shared variable v_doc like joudoc.docnum.

define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
define variable jparr   as character format "x(20)".

define variable change  as logical.

define variable d_amt      like joudoc.dramt.
define variable c_amt      like joudoc.cramt.
define variable com_amt    like joudoc.comamt.
define variable m_buy      as decimal.
define variable m_sell     as decimal.
define variable buy_rate   like joudoc.brate.
define variable sell_rate  like joudoc.srate.
define variable buy_n      like joudoc.bn.
define variable sell_n     like joudoc.sn.
define variable i          as   integer .
define variable v-darp     as   character .
define variable v-carp     as   character .
/*
define variable arp100300 as char extent 6 initial
     ["001904413,001636804,A05",
      "000904294,001636406,A06",
      "001904714,001636105,A09",
      "000904896,001636707,A08",
      "001904604,001636008,A07",
      "001904905,001636309,A10"].
define temp-table t-ar
    field teng  as character
    field doll  as character
    field pro   as character .
*/


define frame f_cus
    joudoc.info   label "Ф. И. О." skip
    joudoc.passp  label "Паспорт " skip
    joudoc.passpdt label "Дата выдачи паспорта" skip
    with row 15 col 16 overlay side-labels.

/*
do i = 1 to 6.
    create t-ar.
    t-ar.teng = entry(1,arp100300[i]).
    t-ar.doll = entry(2,arp100300[i]).
    t-ar.pro  = entry(3,arp100300[i]).
end.
*/

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

find ofc where ofc.ofc = g-ofc no-lock no-error.
if not avail ofc then do:
  message skip "У вас нет настроек офицера!" skip(1) view-as alert-box title " ОШИБКА ! ".
  return.
end.

/* 03.11.2003 nadejda - найти подотчетные счета ARP на 100300 */
v-darp = "".
v-carp = "".
for each arp where arp.gl = 100300 no-lock:
  if (arp.crc <> joudoc.drcur) and (arp.crc <> joudoc.crcur) then next.

  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and
                     sub-cod.acc = arp.arp no-lock no-error.
  if not avail sub-cod or sub-cod.ccode <> "obmen1003" then next.

  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and
                     sub-cod.acc = arp.arp no-lock no-error.
  if not avail sub-cod or sub-cod.ccode <> ofc.titcd then next.

  find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "clsa" and sub-cod.acc = arp.arp no-lock no-error.
  if avail sub-cod and sub-cod.ccode <> "msc" then next.

  if arp.crc = joudoc.drcur then v-darp = arp.arp.
  if arp.crc = joudoc.crcur then v-carp = arp.arp.

  if v-darp <> "" and v-carp <> "" then leave.
end.


if v-darp = "" or v-carp = "" then do:
  message skip " Не настроены счета ARP для вашего департамента в указанной валюте!"
    skip(1) view-as alert-box title " ОШИБКА ! ".
  return.
end.

/*
         if (joudoc.crcur = 1 and j_basic = "D") or (joudoc.crcur = 2 and j_basic = "C")
                             then do: v-arp = t-ar.teng . v-carp = t-ar.doll . end.
                             else do: v-arp = t-ar.doll . v-carp = t-ar.teng . end.
*/

if j_basic eq "D" then do:
      j_param = joudoc.docnum                         + vdel +
                string (joudoc.dramt)                 + vdel +
                string (joudoc.drcur)                 + vdel +
                v-darp                                + vdel +
                (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                string (joudoc.crcur)                 + vdel +
                v-carp.

      j_templ = "JOU0013".
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
else do:
      j_param = joudoc.docnum                         + vdel +
                string (joudoc.drcur)                 + vdel +
                v-darp                                + vdel +
                (joudoc.remark[1] + joudoc.remark[2] + joudoc.rescha[3]) + vdel +
                string (joudoc.cramt)                 + vdel +
                string (joudoc.crcur)                 + vdel +
                v-carp .

      j_templ = "JOU0014".

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

def var s as integer.
/*
if trim(joudoc.info) eq "" then do:
  find current joudoc exclusive-lock.
 message "Выписывать справку - сертификат?" view-as alert-box question buttons yes-no title "" update v-ans as logical.
 if v-ans = True then do:

     do s = 1 to 100:
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

