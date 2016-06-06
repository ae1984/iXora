/* kastiyn.p
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
        02/06/04 dpuchkov добавил урегулирование остатков для филиалов по arp.
        12/06/2010 madiyar - при поиске транзитников проверяем признак закрытия счета
        21.06.2010 marinav - передавать в проводку счет по тиынам
*/


/*--------------------------------------------------------*/
/*             KASTIYN.P - by sasco, 28.09.2001           */
/*                                                        */
/* Создает транзакции по всем тенговым операциям кассира  */
/* за текущий день, беря разницу в тиынах из кредитовой   */
/* части операции (ARP - kacca в пути, kacca в пути - ARP)*/
/*--------------------------------------------------------*/

{mainhead.i}
{yes-no.i}

{get-dep.i}
{comm-txb.i}
{sysc.i}
define new shared variable s-jh like jh.jh.

define variable crdec   as decimal.
define variable crdec1  as decimal.
define variable drdec   as logical.

define new shared variable v_doc   as character init "".
define new shared variable vdel    as character init "^".

define variable rcode   as integer.
define variable rdes    as character.
define variable vparam  as character.

define variable cgl     as integer.
define variable dsum    as decimal init 0.0.
define variable csum    as decimal init 0.0.

define variable carp    as character.
define variable darp    as character.

define variable i_temp_dep as integer.
def var s_dep_cash as char.
def var s_account_a as char.
def var s_account_b as char.

define variable was_casofc as logical initial false.
define variable was_cassof as logical initial false.
define variable v-dep as char.

find trxtmpl where trxtmpl.code eq "VNB0038" no-lock no-error.
if not avail trxtmpl
then do:
        message "Шаблон транзакции VBN0038 не найден!".
        pause.
        return.
end.
find trxtmpl where trxtmpl.code eq "VNB0039" no-lock no-error.
if not avail trxtmpl
then do:
        message "Шаблон транзакции VBN0039 не найден!".
        pause.
        return.
end.
find sysc where sysc.sysc eq "904kas" no-lock no-error.
if avail sysc then cgl = sysc.inval.
else do:
        message "В системном настроечном файле не найдена переменная 904kas".
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

if not yes-no ("Учет разницы в тиынах", "Вы уверены?") then do: hide all. return. end.

find last jl where jl.jdt eq g-today no-lock use-index jdt.

if avail jl then do:
repeat while jl.jdt eq g-today:

   if jl.teller eq g-ofc and jl.crc eq 1 and jl.gl eq cgl then
   do:
       if jl.dam <> 0.0 then do:  /* был приход */
                                  drdec = true.
                                  crdec1 = jl.dam. end.
                         else do: /* был расход */
                                  drdec = false.
                                  crdec1 = jl.cam. end.
       run frac(ABSOLUTE (crdec1), output crdec).
       run evalute_sums.
   end.

   find prev jl no-lock use-index jdt.

end. /* repeat */
end. /* avail jl */

     i_temp_dep = int (get-dep(g-ofc, g-today)).

     find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
     if avail depaccnt then do:
       s_dep_cash = GET-SYSC-CHA ("csptdp").
       if s_dep_cash = ? then s_dep_cash = "".
       /* Для малых РКО все остается по-старому */
       if lookup (string(depaccnt.depart), s_dep_cash) > 0 then do:
                 s_account_b = '000061302'.
       end.
       else do:
         /* для крупных РКО и Центрального офиса */
          s_account_b = "arp".
          {comm-arp2.i}
       end. /* поиск в списке малых РКО */
     end. /* avail depaccnt */


     if csum > 0 then do:
          v_doc = "VNB0038".
             vparam = string(csum) + vdel + darp + vdel + s_account_b.
 /*          vparam = string(csum). */
             s-jh = 0.
             run trxgen (v_doc, vdel, vparam, "", "", output rcode, output rdes,
                       input-output s-jh).
             if rcode ne 0 then
             do:
                message rcode rdes.
                pause.
                return.
             end.
             if s-jh eq 0 then
             do:
                message "Транзакция не удалась!".
                pause.
                return.
             end.

             run trxsts (input s-jh, input 6, output rcode, output rdes).
             if rcode ne 0 then do:
                      message rdes.
                      pause.
                      undo, return.
             end.

             run vou_bank(2).

     end. /* csum */

     if dsum > 0 then do:
/*           vparam = string(dsum).  */
             vparam = string(dsum) + vdel + s_account_b + vdel + carp.
             v_doc = "VNB0039".
             s-jh = 0.
             run trxgen (v_doc, vdel, vparam, "", "", output rcode, output rdes,
                       input-output s-jh).
             if rcode ne 0 then
             do:
                message rcode rdes view-as alert-box.
                return.
             end.
             if s-jh eq 0 then
             do:
                message "Транзакция не удалась!"
                        view-as alert-box.
                return.
             end.

             run trxsts (input s-jh, input 6, output rcode, output rdes).
             if rcode ne 0 then do:
                      message "Ошибка при попытке смены статуса!" rcode rdes view-as alert-box.
                      return.
             end.

             run vou_bank(2).

   end. /* dsum */

      hide all.
      pause 0.

/*
   if csum = 0.0 and dsum = 0.0 then
      message "К ПЕРЕВОДУ = 0 ТИЫН. ПЕРЕВОД НЕ СОВЕРШЕН" view-as alert-box.
   else message "ПЕРЕВОД ТИЫНОВ ЗАВЕРШЕН" view-as alert-box.
*/



/* ********************************************************************** */
/* ********************************************************************** */
/* ********************************************************************** */

procedure evalute_sums.
   if crdec < 0.5 then  /* when < 50 tiyn */
   do:
       if drdec
          then csum = csum + crdec.  /* малый приход - списать  */
          else dsum = dsum + crdec.  /* малый расход - добавить */
   end.
   else /* when >= 50 tiyn */
   do:
       crdec = ABSOLUTE(1.0 - crdec).
       if drdec
          then dsum = dsum + crdec.  /* большой приход - добавить недостающее */
          else csum = csum + crdec.  /* большой расход - списать недостающее */
   end.
end procedure.

/* ********************************************************************** */
/* ********************************************************************** */
/* ********************************************************************** */


