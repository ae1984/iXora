/* repodepo.p
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
 * BASES
        BANK COMM
 * AUTHOR
        10/02/04 suchkov
 * CHANGES
        24/03/04 - suchkov -
        14.02.05 - dpuchkov переписал программу по новым условиям теперь совпадает с балансом.
        22.08.2006 u00124 оптимизация время работы 6 минут.
*/

 {global.i }
 {crc-crc.i}
	
 define variable dt-cnt as date initial today    no-undo.
 define variable d_dopvznos as integer init 0    no-undo. 
 define variable d_dopvznossum as decimal init 0 no-undo. 
 define variable ch_pol as char                  no-undo. 
 define variable v-lgr as char                   no-undo.
 define variable lll as character                no-undo.
 def var t as integer                            no-undo.
 def var st as integer                           no-undo.

 update dt-cnt label "Введите дату расчета" with centered side-label row 9. 
 hide all.

 displ "ЖДИТЕ ИДЕТ ФОРМИРОВАНИЕ ОТЧЕТА...." with centered frame ww row 10 NO-BOX NO-LABELS overlay. pause 0.
	
output to deporep.csv.
    put unformatted "Вид депозита" ";" "Сумма (тыс USD)" ";" "Срок (месяц)" ";" "Дата открытия" ";" "Дата закрытия" ";" "Сумма Доп. взн" ";"
                    "Кол-во Доп. взн" ";" "Валюта вклада" ";" "Ф.И.О" ";" "Адрес" ";" "Возраст" ";" "Пол" ";" "Г/К" ";" "Счет" ";" "Сумма в тенге" ";"
                    skip.

for each lgr where lgr.led = "TDA" no-lock:
    for each aaa where aaa.lgr = lgr.lgr no-lock.
          find last crc where crc.crc = aaa.crc no-lock no-error.
          find last cif where cif.cif = aaa.cif no-lock no-error.
          d_dopvznos = 0. d_dopvznossum = 0.
          for each jl where jl.acc = aaa.aaa and jl.dc = "C" and jl.jdt <> aaa.regdt and jl.lev = 1 and not jl.rem[1] begins "Выплата процентов"  no-lock use-index acc:
              d_dopvznos = d_dopvznos + 1.
              d_dopvznossum = d_dopvznossum + (jl.cam - jl.dam).
          end.
          find sub-cod where sub-cod.sub = "cln" and sub-cod.acc = cif.cif and d-cod = "clnsex" no-lock no-error.
          if avail sub-cod then if ccod = "01" then ch_pol = "Мужской". else ch_pol = "Женский".  else ch_pol = "Нет данных".
          if avail crc and avail cif then do:
             v-lgr = lgr.des.
             if lgr.des begins 'N/A "DALLAS"' then v-lgr = replace (lgr.des, '"DALLAS"', "DALLAS").
             st = truncate(((aaa.expdt - aaa.regdt) / 30), 0).
             if st = 0 then st = 1.
             run lonbal2('cif', aaa.aaa, dt-cnt, "1", yes, output lll).
             if lll <> "0" then do:
                put unformatted v-lgr ";"
                             string(round(crc-crc-date(decimal(lll), aaa.crc, 2, g-today) / 1000, 2)) ";"
                             st ";"
                             aaa.regdt ";"
                             aaa.expdt ";"
                             d_dopvznossum ";"
                             d_dopvznos ";"
                             crc.code   ";"
                             cif.name   ";"
                             replace (cif.addr[2], '"', "") + " " + replace (cif.addr[1], '"', "") ";"
                             integer ((today - cif.expdt) / 365 ) ";"
                             ch_pol ";"
                             aaa.gl ";" 
                             aaa.aaa ";" 
                             crc-crc-date(decimal(lll), aaa.crc, 1, g-today) ";" skip.
             end.
          end.
    end.
end.


hide all.
output close.
unix silent cptwin deporep.csv excel.


