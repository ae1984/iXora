/* astdepmov.p
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
*/

/* astdepmov.p 
   Отчет о перемещении основного средства 
   по департаментам в рамках офиса банка
   11.04.2003 by Sasco 
*/


def temp-table tmp like hist
                   field rid as rowid
                   field stime as char format "x(8)"
                   field dep1 as char
                   field dep2 as char
                   field inv1 as char
                   field inv2 as char
                   index idx_tmp is primary date ctime.
 

def input parameter v-ast like ast.ast.
def query q1 for tmp.

def browse b1 query q1 displ
                             tmp.date label "Дата"
                             tmp.stime label "Время"
                             tmp.who label "Офицер"
                             tmp.chval[2] format "x(3)" label "Откуда..."
                             tmp.chval[1] format "x(3)" label "Куда..."
                       with row 1 centered 7 down overlay title "Перемещения (ENTER - детали)".
def frame f1 b1 with no-label no-box centered row 11 overlay.

for each hist where hist.pkey = "AST" and hist.skey = v-ast and hist.op = "MOVEDEP" no-lock:
    create tmp.
    buffer-copy hist to tmp.
    
    tmp.rid = ROWID (hist).
    tmp.stime = STRING (tmp.ctime, "HH:MM:SS").

    find codfr where codfr.codfr = "sproftcn" and codfr.code = hist.chval[1] no-lock no-error.  
    if available codfr then tmp.dep1 = "[" + hist.chval[1] + "] " + codfr.name[1]. else dep1 = "<В СПРАВОЧНИКЕ ОСТУТСТВУЕТ>".
    tmp.inv1 = hist.chval[4].
    if hist.chval[6] <> "" then tmp.inv1 = tmp.inv1 + " (карточка " + hist.chval[6] + ")".

    find codfr where codfr.codfr = "sproftcn" and codfr.code = hist.chval[2] no-lock no-error.  
    if available codfr then tmp.dep2 = "[" + hist.chval[2] + "] " + codfr.name[1]. else dep2 = "<В СПРАВОЧНИКЕ ОСТУТСТВУЕТ>".
    tmp.inv2 = hist.chval[3].
    if hist.chval[5] <> "" then tmp.inv2 = tmp.inv2 + " (карточка " + hist.chval[5] + ")".

end.

def frame det_Fr
         tmp.dep2 label "Откуда...." form "x(50)" SKIP
         tmp.inv2 label "С номером " form "x(40)" SKIP
         tmp.dep1 label "Куда......" form "x(50)" SKIP
         tmp.inv1 label "С номером " form "x(40)"
         with row 10 centered overlay side-labels.

on "end-error" of frame det_Fr hide frame det_Fr.
on endkey of frame det_Fr hide frame det_Fr.

on return of b1 do:
   if not avail tmp then leave.
   displ tmp.dep2 
         tmp.dep1 
         tmp.inv1 
         tmp.inv2
         with frame det_Fr.
   pause.
   hide frame det_Fr.
end.

on endkey of browse b1 do:
   hide frame f1.
   return.
end.

on endkey of frame f1 do:
   hide frame f1.
   return.
end.

open query q1 for each tmp.
enable all with frame f1.
wait-for window-close of current-window.
