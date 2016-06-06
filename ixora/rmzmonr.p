/* rmzmonr.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Монитор очередей
        Печать платежей
 * RUN
        rmzmon1.p -> rmzmon.i
 * SCRIPT
        
 * INHERIT
        
 * MENU
        5-3-13
 * AUTHOR
        31/12/99   koval
 * CHANGES
        04.11.2003 nadejda  - добавила новую строчку для Департамента регионального развития, источник PRR
        05.11.2003 nadejda  - сделала обработку любых очередей-источников из справочника depsibh
        16.02.2004 nadejda  - исправила поиск департамента для ранее отправленных платежей
        04.03.2004 nadejda  - исправлен поиск платежа по очередям
        07.03.2004 sasco    - поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        28.05.2004 nadejda  - изменено расширение файла отчета на txt, а то не у всех в почте открывается 
        14.06.2005 - kanat - добавил информацию по сканированным платежам (по департаментам)
        05/10/2005 rundoll - добавил срочные платежи
*/

{get-dep.i}
{global.i}

define shared temp-table clrrep
  field cdep as char format "x(25)"
  field depnamelong as char format "x(25)" label "Подразделение"
  field depnameshort as char format "x(14)".

define input parameter p-dep as char.
def input parameter QQ as char.
DEFINE BUFFER bque FOR que.

def var dt as date.
def var v-name like cif.fname.
def var v-sub as int.
def var v-dep as integer.
def var tdate as date.
def var ss as decimal format "->>>,>>>,>>>,>>>,>>9.99".
def var i as integer.
def var v-print as logical init no.


dt = g-today.
output to rpt.txt {5}.

put unformatted string(today) " " string(time, "HH:MM:SS") " " g-ofc skip(1).
find first clrrep where clrrep.cdep = p-dep no-error.

put unformatted "Подразделение: " clrrep.depnamelong skip 
"Платежи, в очереди на " QQ skip
if "{5}" = "append" then "ГРОСС" else "КЛИРИНГ" 
skip(1).

if QQ = "STW" then do:
        def temp-table tque like que.
        for each que where pid = "STW" no-lock.
          create tque.
          buffer-copy que to tque. /* Временная таблица для получения списка платежей отправл. ранее */
        end.
end.

F1:
for each {2} no-lock where {3}:

    find first remtrz where remtrz.remtrz = {4} no-lock no-error.
    if avail remtrz then do:

      /* tque */
      if QQ = "STW" then do:
              find first bque where bque.remtrz = remtrz.remtrz no-lock no-error.
              if avail bque and /* 04.03.2004 nadejda bque.pid = "ST2"*/ bque.pid <> "STW" then next F1.

              find first tque where tque.remtrz = remtrz.remtrz no-error.
              if avail tque then delete tque.
      end.
      /* tque  */

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
        end.
       
     else if p-dep = "s" then do:
/*        if (remtrz.source = "p01" or remtrz.source = "SCN" or remtrz.source = "IBH") then do:*/
           find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz     and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
             if avail sub-cod then v-print = (p-dep = sub-cod.ccode).
     /*   end.*/
     end. 
else
        if remtrz.source = "INK" then do:
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
          v-print = (int(p-dep) = v-dep).
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
        put unformatted remtrz.remtrz {1} format "->>>,>>>,>>>,>>>,>>9.99"  skip.
        accumulate {1} (count total).
      end.
    end.
end.

put unformatted skip "Всего документов: " (accum count {1}) " на сумму:" (accum total {1}) format "->,>>>,>>>,>>>,>>>,>>9.99" skip(1).
ss = (accum total {1}). 
i  = (accum count {1}).

if QQ = "STW" then do:
  put unformatted skip(1) " Платежи отправленные ранее c очереди V2" skip.
  for each tque no-lock.
   find first {2} where {2}.rem = tque.remtrz no-lock no-error.

   if avail {2} then do: 

    {6}

    find first remtrz where remtrz.remtrz = tque.remtrz no-lock no-error.
    if avail remtrz then do:

      v-print = no.
      if p-dep begins "I" then do:

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
      else if p-dep = "s" then do:
/*        if (remtrz.source = "p01" or remtrz.source = "SCN" or remtrz.source = "IBH") then do:*/
           find first sub-cod where sub-cod.sub = "rmz" and sub-cod.acc = remtrz.remtrz     and sub-cod.d-cod = "urgency" and sub-cod.ccode = "s" use-index dcod no-lock no-error.
             if avail sub-cod then v-print = (p-dep = sub-cod.ccode).
/*        end.*/
      end.
      else if p-dep begins "S" and p-dep <> "s" then do:
        if remtrz.source = "SCN" then do:
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
      end.   /* end-of do I */
      else do:
        /* филиальные платежи - по банку-отправителю */
        if p-dep begins "TXB" then v-print = (p-dep = remtrz.sbank).
        else do:
          /* другие строки из справочника depsibh - по очереди-источнику платежа */
          find first codfr where codfr.codfr = "depsibh" and codfr.code = p-dep no-lock no-error.
          if avail codfr then v-print = (p-dep = remtrz.source).
          else
            v-print = (lookup(remtrz.source, "IBH,A,SCN") = 0) and 
                      (not can-find (first codfr where codfr.codfr = "depsibh" and codfr.code = remtrz.source no-lock)) and
                      (remtrz.sbank = "TXB00") and
                      (remtrz.rwho <> "") and 
                      (get-dep(remtrz.rwho, remtrz.rdt) = int(p-dep)).
        end.
      end.

      if v-print then do:
        put unformatted remtrz.remtrz remtrz.payment format "->>>,>>>,>>>,>>>,>>9.99"  skip.
        accumulate remtrz.payment (count total).
      end.
    end.

  end. /* avail */

 end. /* tque */

 put unformatted skip "Документов : " (accum count remtrz.payment) " на сумму:" (accum total remtrz.payment) format "->,>>>,>>>,>>>,>>>,>>9.99" skip(1).
 ss = ss + (accum total remtrz.payment).
 i  = i  + (accum count remtrz.payment).
 put unformatted skip(1) "ИТОГО документов : " i " на сумму:" ss format "->,>>>,>>>,>>>,>>>,>>9.99" skip(1).
end.

