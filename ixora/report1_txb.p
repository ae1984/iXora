/* report1_txb.p
 * MODULE
        Интернет-банкинг
 * DESCRIPTION
        Отчет по депозитам.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8.1.8.14
 * BASES
        TXB COMM
 * AUTHOR
        06/03/09 id00004
 * CHANGES
        01.06.2009 galina - исключила до 02/11/2009 20-тизначные счета из отчета
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/
{nbankBik-txb.i}
def  shared temp-table t-report1 no-undo
  field num as char
  field benname as char
  field benrekv as char
  field dtplat as date
  field summa as char
  field details as char.


def input parameter pAccount as char no-undo.
def input parameter fromDate as date no-undo.
def input parameter toDate as date no-undo.
def input parameter Knp as char no-undo.

def output parameter totalCount as integer no-undo.
def output parameter bankName as char no-undo.
def output parameter bankRNN as char no-undo.
bankName = v-nbankru.
bankRNN = "600400585309" .

def var v-cod as char.
totalCount = 0.
for each txb.jl where txb.jl.jdt >= fromDate and txb.jl.jdt <= toDate and txb.jl.acc = pAccount and txb.jl.lev = 1 no-lock:
    find first txb.jh where txb.jh.jh = jl.jh no-lock no-error.
    if not avail jh then next.

    v-cod = "".
    find first txb.trxcods where txb.trxcods.trxh = txb.jl.jh and txb.trxcods.codfr = 'spnpl' no-lock no-error.
/*в обычном зачислении на счёт*/
    if avail txb.trxcods then v-cod = txb.trxcods.code.
   else do:
/*в платежах*/

       find txb.sub-cod where txb.sub-cod.acc = txb.jh.ref and txb.sub-cod.d-cod = 'eknp' no-lock no-error.
       if avail txb.sub-cod then v-cod = entry(3,sub-cod.rcode).
    .
  end.

  if v-cod = Knp then do: /*Есть совпадение по кнп*/

     totalCount = totalCount + 1.

     create t-report1.
            t-report1.summa = string(abs(jl.dam - jl.cam)).

            find first txb.remtrz where txb.remtrz.remtrz = txb.jh.ref no-lock no-error.

            if avail txb.remtrz then do:
               t-report1.benname =  txb.remtrz.bn[1] + txb.remtrz.bn[2] + txb.remtrz.bn[3].
               t-report1.num = trim( substring( txb.remtrz.sqn,19,8 )).
               t-report1.benrekv = txb.remtrz.bb[1] + txb.remtrz.bb[2] + txb.remtrz.bb[3].
               t-report1.details = string(txb.remtrz.det[1] + txb.remtrz.det[2] + txb.remtrz.det[3]  + txb.remtrz.det[4]).
            end.
            else do:
              t-report1.benname = "АО Метрокомбанк".
              t-report1.details = txb.jl.rem[1].
              t-report1.num = string(txb.jl.jh).
            end.

            t-report1.summa = string(abs(txb.jl.dam - txb.jl.cam)).
            t-report1.dtplat = txb.jl.jdt.
  end.
end.



