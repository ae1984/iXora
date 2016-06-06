/* pmptogl.p
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
        18/01/05 kanat
 * CHANGES
        19/01/05 kanat - АРП счета берутся по номерам структурных подразделений	(pmpaccnt)
        28/01/05 kanat - проставление comdoc
        03/04/06   marinav проставление кодов доходов и департаментов в проводке
*/

{comm-txb.i}
{yes-no.i}
{deparp_pmp.i}
{get-dep.i}

def var seltxb as int no-undo.
seltxb = comm-cod().

def shared var g-today as date.
def var dat as date no-undo.
def var uu as char no-undo.
def var tsum as decimal no-undo.
def var v-tot as deci no-undo.
def var v-depd as char no-undo .
def var v-users as char init "" no-undo. 
def new shared var s-jh like jh.jh.
def var rcode as int no-undo.
def var rdes  as cha no-undo.
def var v-gl as char no-undo.
def var v-dep  as char no-undo.

dat = g-today.

define temp-table tcommonpl  no-undo like commonpl
            field account like pmpaccnt.accnt
            field depd as char      
            field rid as rowid.

update dat label ' Укажите дату ' format '99/99/9999' skip
with side-label row 5 centered frame dataa .
hide frame dataa.

find first sysc where sysc.sysc = 'GLCOMM' no-lock no-error.
if avail sysc then v-gl = entry(1, sysc.chval).
              else do:
                  message "Не найдена настройка в SYSC 'GLCOMM'"  view-as alert-box.
                  return.
              end.

for each commonpl where commonpl.txb = seltxb and 
                        commonpl.date = dat and 
                        commonpl.grp = 15 and 
                        commonpl.joudoc <> ? and 
                        commonpl.comdoc = ? and 
                        commonpl.deluid = ? no-lock. 
    accumulate commonpl.comsum (total).
    v-dep = string(get-dep(commonpl.uid, dat)).
    run get-profit (input commonpl.uid, input v-dep, output v-depd).
    if v-depd = '' then v-depd = '227'.
    create tcommonpl.
    buffer-copy commonpl to tcommonpl.
    assign tcommonpl.rid = rowid(commonpl)
           tcommonpl.depd = v-depd.
           tcommonpl.account = deparp_pmp(get-dep(commonpl.uid, commonpl.date)).
end.

v-tot = (accum total commonpl.comsum).

if v-tot = 0 then do:
   MESSAGE "Необработанные платежи не найдены."
   VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
   TITLE "Внимание".
   return.
end.

for each tcommonpl where tcommonpl.txb = seltxb and 
                         tcommonpl.deluid = ? and 
                         tcommonpl.date = dat and 
                         tcommonpl.joudoc = ? and 
                         tcommonpl.grp = 15 no-lock break by tcommonpl.uid.
    if first-of(tcommonpl.uid) then v-users = "~n" + tcommonpl.uid + v-users.
end.

if v-users <> "" then 
    if not yes-no("Внимание", "По следующим кассирам:" + 
    v-users + 
    "~nплатежи не зачислены на транзитный счет. Продолжить?") then return.


if not yes-no ('Комиссия за пенсионные и др. платежи', "Сформировать транзакцию на сумму " + string (v-tot) + " тенге?" ) then return.

find first cods where cods.gl  = integer(v-gl) and cods.arc = no exclusive-lock no-error.
if avail cods then do trans: cods.lookaaa = yes. end.

/*output to temp_15_1.txt.*/
for each tcommonpl break by tcommonpl.depd by tcommonpl.account:
    accumulate tcommonpl.comsum (total by tcommonpl.depd by tcommonpl.account).
    if last-of(tcommonpl.depd) and (accum total by tcommonpl.depd tcommonpl.comsum) > 0 then do:

          /*  displ tcommonpl.account tcommonpl.depd (accum total by tcommonpl.depd tcommonpl.comSUM) skip.
            pause 0.
          */  
            run trx (
            6, 
            (accum sub-total by tcommonpl.depd tcommonpl.comsum), 
            1, 
            '', 
            tcommonpl.account,
            v-gl, 
            '', 
            'Комиссия: Социальные платежи за ' + string(dat),'14','14','840').
            
            if return-value = '' then undo, return.
            s-jh = int(return-value).            
            run cods-com (input integer(v-gl), input tcommonpl.depd, input "8").

           /* displ s-jh skip.          */
            
    end.
end.  

find first cods where cods.gl  = integer(v-gl) and cods.arc = no exclusive-lock no-error.
if avail cods and cods.lookaaa = yes then do trans: cods.lookaaa = no. end.
release cods.

do trans:
    for each tcommonpl, commonpl where rowid(commonpl) = tcommonpl.rid:
      assign commonpl.comdoc = return-value.
    end.
end.

 


