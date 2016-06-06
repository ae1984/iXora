/* fillst.p
 * MODULE
        Общий
 * DESCRIPTION
        Заполнение хранилища данных для управленческих отчетов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        04/05/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
        06/08/2008 madiyar - мелкие исправления
        02.12.2008 galina - выбор: перезаписывать или нет уже посчитаные данные
        10.12.2008 galina - возможность расчитывать выбранные параметры
        23.06.2009 galina - выбираем курс из crchis по rdt
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

{global.i}

def new shared temp-table wrk like vals.

/*
def new shared temp-table wrk no-undo
  field bank as char
  field sp as char
  field code as char
  field dt as date
  field deval as deci
  field chval as char
  index idx is primary bank sp code.
*/
def var v-overwrite as logical init yes.
def var v-dt as date no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def new shared var rate as deci extent 3.
def var v-code as char.
def var v-list as char.
def var v-sel as integer.
form
    v-overwrite label "Перезаписать полностью?" format "да/нет" skip
    v-dt label "Дата" format "99/99/9999" skip
    v-code label "Код признака" format "x(20)"
with side-label centered width 40 title 'Параметры' frame par.

v-dt = g-today.

update v-overwrite v-dt with frame par.

on help of v-code in frame par do:
  if v-list = "" then do:
    for each valspr where valspr.sub = 'lon' and valspr.active no-lock:
      if v-list <> "" then v-list = v-list + "|".
      v-list = v-list + string(valspr.code) + " " +  valspr.des.
    end.
  end.
  run sel2("код признака",v-list, output v-sel).
end.

if v-overwrite = no then update v-code with frame par.

hide frame par.

do i = 1 to 3:
    find last crchis where crchis.crc = i and crchis.rdt < v-dt no-lock no-error.
    if not avail crchis then do:
        message "Не найден курс, crc=" + string(i) + ", regdt=" + string(v-dt,"99/99/9999") view-as alert-box error.
        return.
    end.
    else rate[i] = crchis.rate[1].
end.

/* группы кредитов юридических лиц */
/*
def new shared var lst_ur as char.
lst_ur = ''.
for each longrp no-lock:
  if substr(string(longrp.stn),1,1) = '2' then do:
    if lst_ur <> '' then lst_ur = lst_ur + ','.
    lst_ur = lst_ur + string(longrp.longrp).
  end.
end.
*/

def var v-sum as deci no-undo.

def var sttime as integer no-undo.
def var endtime as integer no-undo.

output to fillst.txt.
sttime = time.
put unformatted "beginning calculation for " string(v-dt,"99/99/9999") skip
                string(sttime,"hh:mm:ss") skip.
output close.

{r-branch.i &proc = " fillst2(v-dt,v-code)"}

for each valspr where valspr.active no-lock:

    v-sum = 0.
    for each wrk where wrk.bank <> "bank" and wrk.sp = 0 and wrk.code = valspr.code and wrk.dt = v-dt no-lock:
        v-sum = v-sum + wrk.deval.
    end.
    find first wrk where wrk.bank = "bank" and wrk.sp = 0 and wrk.code = valspr.code and wrk.dt = v-dt exclusive-lock no-error.
    if not avail wrk then do:
        create wrk.
        assign wrk.bank = "bank"
               wrk.code = valspr.code
               wrk.dt = v-dt.
    end.
    wrk.deval = v-sum.

end.

if v-overwrite = yes then do:
  find first vals where vals.dt = v-dt no-lock no-error.
  if avail vals then do:
     for each vals where vals.dt = v-dt: delete vals. end.
  end.
end.
else do j = 1 to num-entries(v-code):
  for each vals where vals.dt = v-dt and vals.code = int(entry(j,v-code)):
    delete vals.
  end.
end.

for each wrk no-lock:
  find first vals where vals.bank = wrk.bank and vals.code = wrk.code and vals.sp = wrk.sp and vals.dt = wrk.dt no-lock no-error.
  if not avail vals then do:
    create vals.
    buffer-copy wrk to vals.
  end.
end.

endtime = time.
output to fillst.txt append.
put unformatted skip(2) "finished calculation for " string(v-dt,"99/99/9999") skip
                string(endtime,"hh:mm:ss") skip
                "total time elapsed " string(endtime - sttime,"hh:mm:ss") skip.
output close.

