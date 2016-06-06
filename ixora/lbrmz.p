/* lbrmz.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{get-dep.i}
{global.i}

define shared temp-table lbrep
  field cdep as char format 'x(25)'
  field depnamelong as char format 'x(25)' label "Подразделение"
  field depnameshort as char format 'x(14)'.

define input parameter dep as char.
def var dt as date.
def var v-name like cif.fname.
def var v-sub as int.
def var v-dep as integer.

dt = today.
output to rpt.img {2}.

put unformatted string(today) " " string(time, "HH:MM:SS") " " g-ofc skip(1).
find first lbrep where lbrep.cdep = dep no-error.
put unformatted "Подразделение: " lbrep.depnamelong skip 
"Платежи, в очереди на " if "{1}" = "lb" then "клиринг" else "гросс" 
skip(1).

for each que where que.pid = "{1}" no-lock:
    find first remtrz where remtrz.remtrz = que.remtrz no-lock no-error.
    if avail remtrz then do:
      if substr(dep,1,1) = "I" then do:
        if remtrz.source = "IBH" then do:
          find first aaa where aaa.aaa = dracc.
          find first cif where cif.cif = aaa.cif.

          if cif.fname = '' then do:
            if cif.jame <> '' then
              v-dep = integer(cif.jame) mod 1000.
            else 
              v-dep = get-dep('superman', remtrz.rdt).
          end.
          else do:
            v-name = trim(substr(trim(cif.fname),1,8)).
            v-dep = get-dep(v-name, remtrz.rdt).
          end.

          if int(substr(dep,2)) = v-dep then do:
            put unformatted remtrz.remtrz remtrz.payment format "->>>,>>>,>>>,>>>,>>9.99"  skip.
            accumulate remtrz.payment (count total).
          end.
        end.
      end.  /* end-of do*/
      else if dep begins "TXB" then do:
        if dep = remtrz.sbank then do:
          put unformatted remtrz.remtrz remtrz.payment format "->>>,>>>,>>>,>>>,>>9.99"  skip.
          accumulate remtrz.payment (count total).
        end.
        end.
      else
      if remtrz.source <> "IBH" and remtrz.sbank = "TXB00" and
           remtrz.rwho <> "" and get-dep(remtrz.rwho, dt) = int(dep) then do:
        put unformatted remtrz.remtrz remtrz.payment format "->>>,>>>,>>>,>>>,>>9.99"  skip.
        accumulate remtrz.payment (count total).
      end.
    end.
end.
put unformatted skip "Всего документов: " (accum count remtrz.payment) " на сумму:" 
(accum total remtrz.payment) format "->,>>>,>>>,>>>,>>>,>>9.99" skip(1).

