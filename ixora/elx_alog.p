/* elx_alog.p
 * MODULE
        Elecsnet
 * DESCRIPTION
        Реестр платежей АЛМА ТВ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5-2-1-3-7-2
 * AUTHOR
        22.05.2006 dpuchkov
 * CHANGES
        21.06.2006 tsoy     - В связи с письмом Ксении убрал комиссию
        12.02.2007 id00004 добавил alias
*/

{get-dep.i}
{comm-txb.i}


def var ourbank as char              no-undo.
def var ourcode as integer           no-undo.
def var ourlist as char init ''      no-undo.
ourbank = comm-txb().
ourcode = comm-cod().

def var date as date initial today   no-undo.
/*def var tsum as decimal.*/
def var totsumt as decimal initial 0 no-undo.
def var totsum as decimal initial 0  no-undo.
def var totcom as decimal initial 0  no-undo.

update date with frame f1.
hide frame f1.


define temp-table tmp 
                  field gdep as int
                  field f like comm.almatv.f
                  field summ like comm.almatv.summ
                  field summfk like comm.almatv.summfk
                  field cursfk like comm.almatv.cursfk
                  field ndoc like comm.almatv.ndoc
/*                index idx_tmp is primary ndoc gdep*/  .

def var v-tarif as decimal init 0     no-undo.
find first tarif2 where tarif2.num = '5' and tarif2.kod = '83' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then do:
   v-tarif = tarif2.proc.
end.
if v-tarif = 0 then  do:
   message "Внимание: не настроены тарифы".
   return.
end.


for each mobi-almatv where mobi-almatv.dt = date /*and mobi-almatv.deluid = ? and mobi-almatv.txb = ourcode*/ no-lock:


/*  find last almatv where almatv.ndoc = mobi-almatv.ndoc and almatv.dtfk = ?  no-lock no-error.
    if not avail almatv then do:
       find last almatv where almatv.ndoc =  mobi-almatv.ndoc  no-lock no-error.
    end. 
*/


    find last comm.almatv where comm.almatv.ndoc = mobi-almatv.ndoc use-index ndoc_dt_idx no-lock no-error.
    if avail almatv then do:
       create tmp.
              tmp.f      = mobi-almatv.f.
              tmp.summ   = comm.almatv.summ.
              tmp.summfk = mobi-almatv.summ.
              tmp.cursfk = mobi-almatv.commis.
              tmp.ndoc   = mobi-almatv.ndoc.
              tmp.gdep = 1 /*get-dep (tmp.uid, date) */ .
    end.

end.

OUTPUT TO mobi-almatv.log.

put "АО TEXAKABANK" skip
    space(10)
    "Реестр платежей АЛМА ТВ за " date skip(2).

put "No Контракта  Фамилия            Выстав.cумма  Сумма факт.      Комиссия РКО" 
    skip fill("-", 77) format "x(77)".

for each tmp /*use-index idx_tmp*/ :  

put skip space(2)
    string(tmp.ndoc) format 'x(11)' " "
    tmp.f    format "x(20)" " "
    tmp.summ   format "->>>>>9.99" 
    tmp.summfk  
    0 format ">>>>>>>>9.99"

    /*
    tmp.summfk - round((tmp.summfk * v-tarif / 100), 2) format ">>>>>>>>9.99"         
    round((tmp.summfk * v-tarif / 100), 2) format ">>>>>>>>9.99"
    */

    tmp.gdep format ">>>>9"
    skip.
    assign
          totsum  = totsum  + tmp.summ 
          totsumt = totsumt + tmp.summfk. 

/*        totsumt = totsumt + tmp.summfk - round((tmp.summfk * v-tarif / 100), 2)
          totcom  = totcom  + round((tmp.summfk * v-tarif / 100), 2).
*/
    delete tmp.
end.

put skip
    fill("-", 77) format "x(77)" 
    skip
    "Итого:" space(7)
    totsum format ">>>>>>>>9.99" 
    totsumt format ">>>>>>>>9.99"
    totcom format ">>>>>>>>9.99".
    
output close.

run menu-prt ("mobi-almatv.log")    
