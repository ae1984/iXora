/* rmz31e.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Монитор очередей
        Печать платежей
 * RUN

 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-13
 * AUTHOR
        05/01/05   tsoy
 * CHANGES
        14.06.2005 - kanat - добавил информацию по сканированным платежам (по департаментам)
        05.10.2005 - ten - срочные платежи
*/

{get-dep.i}
{global.i}

define shared temp-table clrrep
  field cdep as char format "x(25)"
  field depnamelong as char format "x(25)" label "Подразделение"
  field depnameshort as char format "x(14)".

define input parameter p-dep as char.
def input parameter QQ as char.

output to rpt.txt.
def var v-print as logi.

def var v-dep as integer.
def var v-name like cif.fname.

put unformatted string(today) " " string(time, "HH:MM:SS") " " g-ofc skip(1).
find first clrrep where clrrep.cdep = p-dep no-error.

put unformatted "Подразделение: " clrrep.depnamelong skip 
"Платежи, в очереди на " QQ skip.

for each que no-lock where que.pid = QQ.

    find first remtrz where remtrz.remtrz = que.remtrz and remtrz.tcrc = 1 no-lock no-error.
    if avail remtrz then do:

      v-print = no.
      if p-dep begins "I" then do:
        /* Интернет-платежи ищем по источнику и обслуживающему департаменту */
        if remtrz.source = "IBH" then do:
          find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
          find first cif where cif.cif = aaa.cif no-lock no-error.

          if cif.fname = "" then do:
            if cif.jame <> "" then v-dep = integer(cif.jame) mod 1000.
                              else v-dep = get-dep("superman", remtrz.rdt).
          end.
          else do:
            v-name = trim(substr(trim(cif.fname),1,8)).
            v-dep = get-dep(v-name, remtrz.rdt).
          end.

          v-print = (int(substr(p-dep, 2)) = v-dep).
        end.
      end.  /* end-of do I */
     else if p-dep begins "S" and p-dep <> "s" then do:

/*        14.06.2005 - kanat - добавил информацию по сканированным платежам (по департаментам) */
      /* Сканированные - платежи ищем по источнику и обслуживающему департаменту */
        if remtrz.source = "SCN" then do:
          find first aaa where aaa.aaa = remtrz.dracc no-lock no-error.
          find first cif where cif.cif = aaa.cif no-lock no-error.
          if avail aaa and avail cif then do:

          if cif.fname = "" then do:
            if cif.jame <> "" then v-dep = integer(cif.jame) mod 1000.
                              else v-dep = get-dep("superman", remtrz.rdt).
          end.
          else do:
            v-name = trim(substr(trim(cif.fname),1,8)).
            v-dep = get-dep(v-name, remtrz.rdt).
          end.
          end.
          v-print = (int(substr(p-dep, 2)) = v-dep).
        end.
      end.  /* end-of do I */
   else if p-dep = "s" then do:
        if (remtrz.source = "p01" or remtrz.source = "SCN" or remtrz.source = "IBH") then do:
             find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
             if avail sub-cod then v-print = (p-dep = sub-cod.ccode).
        end.
   end.

/*        14.06.2005 - kanat - добавил информацию по сканированным платежам (по департаментам) */
      else 
        /* филиальные платежи - по банку-отправителю */
        if p-dep begins "TXB" then v-print = (p-dep = remtrz.sbank).
        else do:
          /* другие строки из справочника depsibh - по очереди-источнику платежа */
          find first codfr where codfr.codfr = "depsibh" and codfr.code = p-dep no-lock no-error.
          if avail codfr then 
            v-print = (p-dep = remtrz.source).
          else
            /* все остальные платежи разбираем по департаменту офицера */
            v-print = (lookup(remtrz.source, "IBH,A,SCN") = 0) and 
                      (not can-find (first codfr where codfr.codfr = "depsibh" and codfr.code = remtrz.source no-lock)) and
                      (remtrz.sbank = "TXB00") and
                      (remtrz.rwho <> "") and 
                      (get-dep(remtrz.rwho, remtrz.rdt) = int(p-dep)).
        end.

      if v-print then do:

        put unformatted remtrz.remtrz remtrz.payment format "->>>,>>>,>>>,>>>,>>9.99"  skip.
        accumulate remtrz.payment (count total).

      end.

  end.
end.

put unformatted skip "Всего документов: " (accum count remtrz.payment) " на сумму:" (accum total remtrz.payment) format "->,>>>,>>>,>>>,>>>,>>9.99" skip(1).

        