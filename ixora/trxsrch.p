/* trxsrch.p
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Поиск шаблона по заданным параметрам
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
        01/09/04 sasco
 * CHANGES
        01/09/04 sasco улучшил алгорита поиска + добавил запрос на количество линий в шаблоне
*/

def shared var g-lang as char.
def var vsystem as char.
def var vcode as inte.
def buffer btrxhead for trxhead.
def var tmpsys as char initial "*" no-undo.
def var tmpdes as char initial "*" no-undo.
def var tmpcode as inte initial 1 no-undo.
def var vlines as inte initial 0 no-undo.

define temp-table tmphd 
       field system like trxtmpl.system
       field code   like trxtmpl.system
       field ln     like trxtmpl.ln

       field was     as logical initial no

       field scrc    as character initial "all" format "x(3)" 
       field sdrgl   as character initial "all" format "x(6)" 
       field sdrsub  as character initial "all" format "x(3)"
       field sdev    as character initial "all" format "x(3)"
       field sdracc  as character initial "all" format "x(9)"
       field scrgl   as character initial "all" format "x(6)"
       field scrsub  as character initial "all" format "x(3)"
       field scev    as character initial "all" format "x(3)"
       field scracc  as character initial "all" format "x(9)"
       
       field crc    like trxtmpl.crc initial ?
       field drgl   like trxtmpl.drgl initial ?
       field drsub  like trxtmpl.drsub initial ?
       field dev    like trxtmpl.dev initial ?
       field dracc  like trxtmpl.dracc initial ?
       field crgl   like trxtmpl.crgl initial ?
       field crsub  like trxtmpl.crsub initial ?
       field cev    like trxtmpl.cev initial ?
       field cracc  like trxtmpl.cracc initial ?
       
       index tmphd is primary system code ln.

define temp-table tmp like trxhead
                  field rec_id as recid.

define temp-table tmpcnt 
                  field system like trxtmpl.system
                  field code like trxtmpl.code
                  field cnt as integer.

define variable vans as logical.
define variable vcnt as integer initial 1.

{trxtmpl1.f "new"}


displ "Задайте параметры поиска шаблонов:" skip
      /* "  - для каждой линии необходим свой набор параметров" skip */
      " - поиск будет по всем шаблонам, которые хотя бы в одной линии " skip
      "   соответствуют указанным параметрам" skip(1)
      "Стрелка вниз - добавить, CTRL+D - удалить, F4 - закончить ввод" 
      with row 1 overlay centered no-label frame titfr.
      pause 0.

{jabr.i
&start = " "
&head = "tmphd"
&headkey = "crc"
&where = " TRUE "
&index = "tmphd"
&formname = "trxsrch"
&framename = "tmphd"
&addcon = "true"
&deletecon = "true"
&predisplay = "  "
&display = " 
             tmphd.scrc 
             tmphd.sdrgl 
             tmphd.sdrsub 
             tmphd.sdev 
             tmphd.sdracc 
             tmphd.scrgl 
             tmphd.scrsub 
             tmphd.scev 
             tmphd.scracc 
           "
&highlight = " tmphd.scrc " 
&postcreate = " do: vlines = vlines + 1. tmphd.ln = vlines. end. "
&postdisplay = " "
&postadd = " "
&postkey = "else if keyfunction(lastkey) = 'RETURN' then do:
               update 
                      tmphd.scrc
                      tmphd.sdrgl 
                      tmphd.sdrsub 
                      tmphd.sdev 
                      tmphd.sdracc 
                      tmphd.scrgl 
                      tmphd.scrsub 
                      tmphd.scev 
                      tmphd.scracc 
                      with frame tmphd.
               next upper. 
             end. "
&end = " message 'Задать количество линий в шаблоне? ' update vans. 
         if vans then message 'Сколько линий? ' update vcnt.
       "
}


displ "Ждите..." with centered overlay row 5.


/** УДАЛИМ СТРОКИ БЕЗ УСЛОВИЙ **/
for each tmphd:
    if tmphd.scrc = "all" and
       tmphd.sdrgl = "all" and
       tmphd.sdrsub = "all" and
       tmphd.sdev = "all" and
       tmphd.sdracc = "all" and
       tmphd.scrgl = "all" and
       tmphd.scrsub = "all" and
       tmphd.scev = "all" and
       tmphd.scracc = "all" then delete tmphd.
    else do:

       if tmphd.scrc <> "all"   then tmphd.crc = int(tmphd.scrc) no-error.
          if error-status:error then do: message "Ошибка ввода валюты!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.sdrgl <> "all"  then tmphd.drgl = int(tmphd.sdrgl) no-error.
          if error-status:error then do: message "Ошибка ввода Г/К по дебету!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.sdrsub <> "all" then tmphd.drsub = tmphd.sdrsub no-error.
          if error-status:error then do: message "Ошибка ввода субсчета по дебету!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.sdev <> "all"   then tmphd.dev = int(tmphd.dev) no-error.
          if error-status:error then do: message "Ошибка ввода уровня по дебету!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.sdracc <> "all" then tmphd.dracc = tmphd.sdracc no-error.
          if error-status:error then do: message "Ошибка ввода счета по дебету!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.scrgl <> "all"  then tmphd.crgl = int(tmphd.scrgl) no-error.
          if error-status:error then do: message "Ошибка ввода Г/К по кредиту!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.scrsub <> "all" then tmphd.crsub = tmphd.scrsub no-error.
          if error-status:error then do: message "Ошибка ввода субсчета по кредиту!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.scev <> "all"   then tmphd.cev = int(tmphd.scev) no-error.
          if error-status:error then do: message "Ошибка ввода уровня по кредиту!" 
          view-as alert-box title "". hide all. return. end.
       
       if tmphd.scracc <> "all" then tmphd.cracc = tmphd.cracc no-error.
          if error-status:error then do: message "Ошибка ввода счета по кредиту!" 
          view-as alert-box title "". hide all. return. end.
          
    end.
end.

find first tmphd no-error.
if not avail tmphd then do:
   message "Нет условий с параметрами для поиска~nили условия соответствуют всем шаблонам" view-as alert-box title "".
   return.
end.


define variable is_all as integer.
define variable is_cnt as integer.

is_all = 0.

for each tmphd:
    is_all = is_all + 1.
end.

/**  СПИСОК ШАБЛОНОВ ПО ЗАДАННЫМ УСЛОВИЯМ  **/
for each trxtmpl no-lock break by trxtmpl.system by trxtmpl.code:
    
    if first-of (trxtmpl.code) then do:
       is_cnt = 0.
       for each tmphd:
           tmphd.was = no.
       end.
    end.

    is_cnt = is_cnt + 1.

    for each tmphd:

       if (tmphd.crc = trxtmpl.crc or tmphd.scrc = "all") and
          (tmphd.drgl = trxtmpl.drgl or tmphd.sdrgl = "all") and
          (tmphd.drsub = trxtmpl.drsub or tmphd.sdrsub = "all") and
          (tmphd.dev = trxtmpl.dev or tmphd.sdev = "all") and
          (tmphd.dracc = trxtmpl.dracc or tmphd.sdracc = "all") and
          (tmphd.crgl = trxtmpl.crgl or tmphd.scrgl = "all") and
          (tmphd.crsub = trxtmpl.crsub or tmphd.scrsub = "all") and
          (tmphd.cev = trxtmpl.cev or tmphd.scev = "all") and
          (tmphd.cracc = trxtmpl.cracc or tmphd.scracc = "all") and
          tmphd.was = no
          then do:
            tmphd.was = yes.

            /* если условие совпало с линией шаблона - увеличим счетчик "попаданий" в tmpcnt */
            find tmpcnt where tmpcnt.system = trxtmpl.system and 
                              tmpcnt.code = trxtmpl.code 
                              no-error.

            if not avail tmpcnt then create tmpcnt.
            tmpcnt.system = trxtmpl.system.
            tmpcnt.code = trxtmpl.code.
            tmpcnt.cnt = tmpcnt.cnt + 1.

          end. 

    end. /* tmphd */

    /* если количество линий должно совпадать то удалим не соответствующие */
    if vans and /* считаем линии */
       last-of (trxtmpl.code) and /* последняя линия в шаблоне */
       vcnt <> is_cnt /* указали не то количество */
       then do:
       for each tmpcnt where tmpcnt.system = trxtmpl.system and tmpcnt.code = trxtmpl.code:
           delete tmpcnt.
       end.
    end.
  
end. /* trxtmpl */


for each tmpcnt where tmpcnt.cnt >= is_all:

    find tmp where tmp.system = tmpcnt.system and tmp.code = integer (substr(tmpcnt.code, 4)) no-error.
    if not avail tmp then do:
    
       find trxhead where trxhead.system = tmpcnt.system and 
                          trxhead.code = integer (substr(tmpcnt.code, 4))
                          no-lock no-error.
       if not avail trxhead then next.

       create tmp.
       buffer-copy trxhead to tmp.
       tmp.rec_id = recid(trxhead).

    end. /* create tmp */

end. /* tmpcnt */            

hide all no-pause.

find first tmp no-error.
if not avail tmp then do:
   message "Нет шаблонов, соответствующих условию поиска" view-as alert-box title "".
   return.
end.


define query qt for tmp.
define browse bt query qt
              displ tmp.system label "Тип"
                    tmp.code   label "Номер"
                    tmp.des    label "Название шаблона"
              with row 3 5 down centered.
define frame ft bt help "ENTER - редактировать; F4 - выход" 
             with row 1 centered title "Результаты поиска".


on "value-changed" of browse bt do:
    if not avail tmp then leave.
    run trxlndisp(tmp.system + string(tmp.code,'9999')).
end.

on "return" of browse bt do:
    if not avail tmp then leave.
    run trxtmpl (tmp.rec_id).
end.

open query qt for each tmp.
enable all with frame ft.
apply "value-changed" to browse bt.
wait-for window-close of current-window focus browse bt.

hide all no-pause.
