/* atv2arp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        atvsofp.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        27/10/03 kanat
 * CHANGES
        11/11/03 kanat - кассир зачисляет только на кассу
        20/04/04 kanat - добавил сумму комиссии в зачисление на транзитный счет.
        18/08/05 kanat - убрал формирование операционных ордеров т.к. у менеджеров в конце зачислений формируется единый прих. ордер
*/

{get-dep.i}
{comm-txb.i}
{sysc.i}

def input parameter dat as date.
def input parameter uu as char.
def output parameter v-atv-jh as integer.


def var ourbank as char.
def var ourcode as integer.
def var ourlist as char init ''.
ourbank = comm-txb().
ourcode = comm-cod().

def shared var g-today as date.
def var tsum as decimal.
def var v-tot as deci.
def var cho as logical init false. 
def new shared var s-jh like jh.jh.
def var rcode as int.
def var rdes as char.


def var i_temp_dep as integer.
def var s_account_a as char.
def var s_account_b as char.
def var s_dep_cash as char.
def var v-totcomsum as decimal.

for each almatv where dtfk = dat and state = 0 and uid = uu and almatv.deluid = ? and almatv.txb=ourcode:
    ACCUMULATE almatv.summfk (total).
    ACCUMULATE almatv.cursfk (total).  /* ? */
end.

v-tot = (accum total almatv.summfk).
v-totcomsum = (accum total almatv.cursfk).

/* -------- kanat зачисление на кассу в пути только для кассиров из sysc.sysc = "csptdp" ---------- */

/*
i_temp_dep = int (get-dep (uu, dat)).


find first depaccnt where depaccnt.depart = i_temp_dep no-lock no-error.
if avail depaccnt then do:

  s_dep_cash = GET-SYSC-CHA ("csptdp").
  if s_dep_cash = ? then s_dep_cash = "".

if lookup (string(depaccnt.depart), s_dep_cash) > 0 then do:
            s_account_a = ''. 
            s_account_b = '000061302'. 
end.
else do: 
            s_account_a = '100100'. 
            s_account_b = ''. 
end.
end.
*/

            s_account_a = '100100'. 
            s_account_b = ''. 


             /*if cho then '100100' else '',*/
             /*if cho then '' else '000061302',*/
/*--------------------------------------------------------------------------------------------------*/

/*
MESSAGE "Выберите счет кассы." skip(1) 
    "<YES>  - Касса.        (g/l 1001)" skip
    "<NO>   - Касса в пути. (g/l 1002)" skip  
    VIEW-AS ALERT-BOX QUESTION buttons yes-no
    TITLE "счет кассы" UPDATE cho.*/

find first comm.txb where txb.txb = ourcode no-lock.
                        
if v-tot <> 0 then do:
    MESSAGE "Сформировать кассовый ордер на сумму " 
    v-tot " тенге."
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Платежи Алма-ТВ" UPDATE choice3 as logical.
    case choice3:
        when true then do:
            s-jh = 0.     
            run trx.p(
            6, 
            v-tot + v-totcomsum, 
            1, 
            s_account_a, /*if cho then '100100' else '',*/ 
            s_account_b, /*if cho then '' else '000061302',*/ 
            '', 
            if ourcode = 0 then "498904301" else comm.txb.commarp, 
            'Зачисление на транзитный счет',
            '14','16','856').
            
            if return-value = '' then undo, return.
            
            s-jh = int(return-value).            
            v-atv-jh = s-jh.

            run setcsymb.p(s-jh, 10).
            run jou.p.
/*
            run vou_import.
*/

            for each almatv where dtfk = dat and state = 0 and uid = uu and  almatv.deluid = ? and almatv.txb=ourcode:
                update almatv.state = 1.
            end.

        end.    
        when false then do:
        end.
    end case.
end.
else do:
    MESSAGE "Необработанные платежи не найдены."
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
end.
