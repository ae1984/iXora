/* lb102ink.i
 * MODULE
        Платежная система
 * DESCRIPTION
       Собираем во временную таблицу ИР по ОПВ и СО
 * RUN

 * CALLER
        lb100.p, lb100g.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
      26.06.2009 galina
 * CHANGES
        30/07/2010 galina - ищем aaar, если бакн отправитель ЦО

 * BASES
        BANK COMM
*/



def new shared temp-table t-pnjink
  field bstr as char
  field rnn as char
  field rem as char
  field sbank as char
  field sacc as char
  field rbank as char
  field racc as char
  index main sbank sacc rbank racc rnn rem.
v-rnn = ''.

for each {1} where {1}.rdt = g-today and {1}.pr = vnum no-lock use-index rdtpr by {1}.bank by {1}.amt:

  find first remtrz where remtrz.remtrz = {1}.rem no-lock no-error.
  if not avail remtrz then next.

  if remtrz.sbank = ourbank then do:
        find first aaar where aaar.a1 = remtrz.remtrz and aaar.a5 = remtrz.sacc /*and aaar.a4 <> "1"*/ no-lock no-error.
        if not avail aaar then next.
        find first inc100 where inc100.num = decimal(aaar.a2) and inc100.iik = aaar.a5 no-lock no-error.
        if not avail inc100 then next.

  end.
  else do:
      find first inc100 where inc100.num = integer(entry(num-entries(remtrz.sqn,'.'),remtrz.sqn,'.')) and inc100.iik = remtrz.sacc no-lock no-error.
      if not avail inc100 then next.
  end.

  if index(remtrz.rcvinfo[1],"/PSJINK/") = 0 then next.



    /* РНН получателя */
    v-rnn = trim(remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3]).
    n = index (v-rnn, "/RNN/").
    if n = 0 then v-rnn = "".
             else v-rnn = substr(trim(substr(v-rnn, n + 5)), 1, 12).

    create t-pnjink.
    assign t-pnjink.bstr = inc100.reschar[1]
           t-pnjink.rem = remtrz.remtrz
           t-pnjink.rnn = v-rnn
           t-pnjink.sbank = remtrz.sbank
           t-pnjink.sacc = remtrz.sacc
           t-pnjink.rbank = remtrz.rbank
           t-pnjink.racc = remtrz.racc.
end.


