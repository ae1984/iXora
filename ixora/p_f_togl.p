/* p_f_togl.p
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
        18/06/03 nataly 460714 -> 461110, 460716 -> 461120
        24/10/2003 sasco Исправил поиск незачисленных платежей
        13/10/2003 sasco Добавил дату реестра в назначение платежа
        20/01/2005 kanat Поменял АРП счета 
        31/03/06   marinav проставление кодов доходов и департаментов в проводке
*/

{comm-txb.i}
{yes-no.i}
{deparp_pmp.i}
{get-dep.i}

def var seltxb as int.
seltxb = comm-cod().

def shared var g-today as date.
def var dat as date no-undo.
def var uu as char no-undo.
def var tsum as decimal no-undo.
def var v-tot as deci no-undo.
def var v-depd as char no-undo.
def var v-users as char init "" no-undo. 
def new shared var s-jh like jh.jh.
def var rcode as int no-undo.
def var rdes  as cha no-undo.
def var v-gl as char no-undo.
def var v-dep  as char no-undo.
def var v-totacc as deci no-undo.

dat = g-today.

define temp-table tpf  no-undo like p_f_payment
            field accnt like depaccnt.accnt      
            field depd as char      
            field rid  as rowid.

define temp-table tacc  no-undo
            field accnt like depaccnt.accnt.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .
hide frame dataa.

find first sysc where sysc.sysc = 'GLCOMM' no-lock no-error.
if avail sysc then v-gl = entry(1, sysc.chval).
              else do:
                  message "Не найдена настройка в SYSC 'GLCOMM'"  view-as alert-box.
                  return.
              end.

for each p_f_payment where p_f_payment.txb = seltxb and p_f_payment.deluid = ? and p_f_payment.date = dat and p_f_payment.stgl = 0 no-lock:
    ACCUMULATE p_f_payment.comiss (total).

    v-dep = string(get-dep(p_f_payment.uid, p_f_payment.date)).
    run get-profit (input p_f_payment.uid, input v-dep, output v-depd).
    if v-depd = '' then v-depd = '227'.
    create tpf.
    buffer-copy p_f_payment to tpf.
    tpf.rid = rowid (p_f_payment).
    tpf.depd = v-depd.
    tpf.accnt = deparp_pmp(get-dep(p_f_payment.uid, p_f_payment.date)).
end.

v-tot = (accum total p_f_payment.comiss).

if v-tot = 0 then do:
   MESSAGE "Необработанные платежи не найдены."
   VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
   TITLE "Внимание".
   return.
end.

for each tpf where tpf.deluid = ? and tpf.date = dat and tpf.stcif = 0 break by tpf.uid :
    if first-of(tpf.uid) then v-users = "~n" + tpf.uid + v-users.
end.
if v-users <> "" then 
    if not yes-no("Внимание", "По следущим кассирам:" + 
    v-users + 
    "~nплатежи не зачислены на транзитный счет. Продолжить?") then return.


if not yes-no ('Комиссия за пенсионные и др. платежи', "Сформировать транзакцию на сумму " + string (v-tot) + " тенге?" ) then return.

find first cods where cods.gl  = integer(v-gl) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.

/*output to temp1.txt.*/
for each tpf break  by tpf.depd by tpf.accnt:
    accumulate tpf.comiss (total  by tpf.depd by tpf.accnt).
    if last-of( tpf.depd ) then do:

            v-totacc = (accum total by tpf.depd tpf.comiss).
          /*  if tpf.accnt = '002076036' then v-totacc = (accum total by tpf.depd tpf.comiss) - 2670.
            if tpf.accnt = '002076890' then v-totacc = (accum total by tpf.depd tpf.comiss) - 2970.
           */
        /*    displ tpf.accnt tpf.depd v-totacc skip.
            pause 0.
        */    
           
            run trx (
            6, 
            v-totacc, 
            1, 
            '', 
            tpf.accnt,
            v-gl, 
            '', 
            'Комиссия: пенсионные и пр.платежи за ' + string(dat),'14','14','840').
            
            if return-value = '' then undo, return.
            s-jh = int(return-value).            
                                 
            run cods-com (input integer(v-gl), input tpf.depd, input "9").
            
            create tacc.
            tacc.accnt = tpf.accnt.
           
          /*  displ s-jh skip.          */

    end.

end.  

find first cods where cods.gl  = integer(v-gl) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
release cods.

do transaction:
for each tacc:
   for each tpf where tpf.accnt = tacc.accnt:
       find p_f_payment where rowid (p_f_payment) = tpf.rid no-error.
       update p_f_payment.stgl = p_f_payment.stgl + 1.
   end.
end.
end.

