/* alltiyn.p
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
 * BASES
        BANK COMM
 * CHANGES
        26/05/2004 kanat - добавил параметр 2 в вызов vou_bank.
        13.01.2012 damir - добавил keyord.i, printord.p
        06.03.2012 damir - переход на новые форматы, добавил printvou_bank.p
        30.03.2012 damir - закоментил printvou_bank.p, добавил printord.p
*/


/*--------------------------------------------------------*/
/*             ALLTIYN.P - by sasco, 28.09.2001           */
/*                                                        */
/* Создает транзакции по всем тенговым операциям кассира  */
/* за текущий день, беря разницу в тиынах из кредитовой   */
/* части операции (ARP - kacca, kacca - ARP)              */
/*--------------------------------------------------------*/

{mainhead.i}
{yes-no.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

define new shared variable s-jh like jh.jh.

define var v-dat as date label "ДАТА   ".
define var v-ofc like g-ofc.

define variable crdec   as decimal.               /* credit */
define variable crdec1  as decimal.

define variable drdec   as logical.
define variable prdec   as logical.
define variable yesno   as logical.

define variable mygl    as integer.                /*для подстановки значений*/
define variable myarp   as character.              /*из переменных 904car,dar*/

define new shared variable v_doc   as character init "".
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
define variable vparam  as character.

define variable cgl     as integer.
define variable carp    as character.
define variable darp    as character.

define variable dsum         as decimal init 0.0.
define variable csum         as decimal init 0.0.

/* Проверка - существуют ли шаблоны VNB 0041, 0042 */
find trxtmpl where trxtmpl.code eq "VNB0041" no-lock no-error.
if not avail trxtmpl
then do:
        message "Шаблон транзакции VBN0041 не найден!".
        pause.
        return.
end.
find trxtmpl where trxtmpl.code eq "VNB0042" no-lock no-error.
if not avail trxtmpl
then do:
        message "Шаблон транзакции VBN0042 не найден!".
        pause.
        return.
end.
/* Поиск констант - номеров счетов в SYSC */
find sysc where sysc.sysc eq "904car" no-lock no-error.
if not avail sysc
then do:
        message "В системном настроечном файле не найдена переменная 904car".
        pause.
        return.
end.
carp = trim (sysc.chval).
find sysc where sysc.sysc eq "904dar" no-lock no-error.
if not avail sysc
then do:
        message "В системном настроечном файле не найдена переменная 904dar".
        pause.
        return.
end.
darp = trim (sysc.chval).
find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
if avail sysc then cgl = sysc.inval.
else do:
        message "В системном настроечном файле не найдена переменная CASHGL".
        pause.
        return.
end.


/* Найдем все операции кассира за этот день */
v-dat = g-today.
v-ofc = g-ofc.

if not yes-no ("Учет разницы в тиынах", "Вы уверены?") then do: hide all. return. end.

find last jl where jl.jdt eq v-dat no-lock use-index jdt.

if avail jl then do:
repeat while jl.jdt eq v-dat:

   if jl.teller eq v-ofc and jl.crc eq 1 and jl.gl eq cgl then
   do:
       if jl.dam <> 0.0 then do: drdec = true.  crdec1 = jl.dam. end.
                         else do: drdec = false. crdec1 = jl.cam. end.
       run frac(ABSOLUTE (crdec1), output crdec).
       run evalute_sums.

   end.

   find prev jl no-lock use-index jdt.

end. /* repeat */
end. /* avail jl */

     s-jh = 0.
     crdec = dsum.
     run get_d_param.

     if vparam <> "" then do:
             run trxgen (v_doc, vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).

             if rcode ne 0 then
             do:
                message rcode rdes.
                return.
             end.

             if s-jh eq 0 then
             do:
                message "Invalid transaction number! cannnot be zero!".
                return.
             end.

             run trxsts (input s-jh, input 6, output rcode, output rdes).

             if rcode ne 0 then do:
                      message rdes.
                      undo, return.
             end.

             if v-noord = no then run vou_bank(2).
             else do:
                /*run printvou_bank("").*/
                run printord(s-jh,"").
             end.
     end.

     crdec = csum.
     s-jh = 0.
     run get_c_param.

     if vparam <> "" then do:
             run trxgen (v_doc, vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).

             if rcode ne 0 then
             do:
                message rcode rdes.
                return.
             end.

             if s-jh eq 0 then
             do:
                message "Invalid transaction number! cannnot be zero!".
                return.
             end.

             run trxsts (input s-jh, input 6, output rcode, output rdes).

             if rcode ne 0 then do:
                      message rdes.
                      undo, return.
             end.

             if v-noord = no then run vou_bank(2).
             else do:
                /*run printvou_bank("").*/
                run printord(s-jh,"").
             end.
     end.

     /* Добавим запись в CASHOFC */
     find cashofc where cashofc.whn eq v-dat and
                        cashofc.ofc eq v-ofc and
                        cashofc.crc eq 1 and
                        cashofc.sts eq 2
                        no-error.
     if avail cashofc then cashofc.amt = cashofc.amt + dsum - csum.
     else do:
                create cashofc.
                cashofc.whn = v-dat.
                cashofc.ofc = v-ofc.
                cashofc.who = g-ofc.
                cashofc.crc = 1.
                cashofc.sts = 2.
                cashofc.amt = dsum - csum.
     end.

   hide all.
   pause 0.


   if csum = 0.0 and dsum = 0.0 then message "К ПЕРЕВОДУ = 0 ТИЫН.~nПЕРЕВОД НЕ СОВЕРШЕН"
                                     view-as alert-box.
/*
   else message "ПЕРЕВОД ТИЫНОВ ЗАВЕРШЕН" view-as alert-box.
*/


/* ======================================================================= */
/* ======================================================================= */
/* ======================================================================= */

procedure evalute_sums.
   if crdec < 0.5 then  /* when < 50 tiyn */
   do:
       if drdec
          then csum = csum + crdec.  /* DEBIT JL */
          else dsum = dsum + crdec.  /* CREDIT JL */
   end.
   else /* when >= 50 tiyn */
   do:
       crdec = ABSOLUTE(1.0 - crdec).
       if drdec
          then dsum = dsum + crdec.  /* DEBIT JL */
          else csum = csum + crdec.  /* CREDIT JL */
   end.
end. /* of proc */

/* ********************************************************************** */
/* ********************************************************************** */
/* ********************************************************************** */
procedure get_c_param.

   vparam = "".
   if csum <> 0.0 then
   do:

      /* csum  : K = cred, Arp = deb */
      prdec = false.      /* R - order */
      v_doc = "VNB0041". /* Arp++ K--  */
      vparam = string (csum) + vdel + "1" + vdel + darp
               + vdel + "Урегулирование кассы".
   end.

end. /* of proc */

/* ********************************************************************** */
/* ********************************************************************** */

procedure get_d_param.

   vparam = "".
   if dsum <> 0.0 then
   do:

      /* dsum  : K = deb, Arp = cred */
      prdec = true.      /* P - order */
      v_doc = "VNB0042". /* K++ Arp-- */
      vparam = string (dsum) + vdel + "1" + vdel + carp
               + vdel + "Урегулирование кассы".
   end.
end. /* of proc */
