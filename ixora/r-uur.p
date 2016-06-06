/* r-uur.p
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

/* r-uur.p
  программа подсчитывает количество счетов и остатки по юрлицам в разбивке по валютам - управленческая отчетность "Анализ счетов юр.лиц"
  
  Изменения:
  22.05.2003 nadejda - добавила выбор отчетной даты 
*/

{mainhead.i}
{functions-def.i}

def stream  m-out.
def var date$ as date.
def var total$ as decimal.
def var totacc$ as decimal. 
def var v-koltot as integer.
def var v-kol as integer.
def var v-kolall as integer.
def var v-kolalltot as integer.
def var USD$ as dec.
def var val$ as char format "x(3)".

date$ = g-today - 1.


update skip(1) date$ label "  ДАТА ОТЧЕТА " format "99/99/9999" 
       validate (date$ < g-today, " Дата должна быть меньше текущей!")
       " " skip(1)
  with side-label centered row 5 title " ПАРАМЕТРЫ ОТЧЕТА " frame f-dt.

find last crchis where crchis.crc = 2 and crchis.rdt <= date$ no-lock no-error.
USD$ = crchis.rate[1].

output stream m-out to rpt.img.
put stream m-out skip
FirstLine( 1, 1 ) format "x(107)" skip(1)
"                      "
"КОЛИЧЕСТВО ТЕКУЩИХ СЧЕТОВ ЮРИДИЧЕСКИХ ЛИЦ "  skip
"                      "
"           НА " date$ format "99/99/9999" skip(1)
FirstLine( 2, 1 ) format "x(107)" skip.

put stream m-out " " skip.
put stream m-out fill(" ", 60) format "x(60)" "в тыс. долларов США" skip.
put stream m-out fill("=", 79) format "x(79)" skip.
put stream m-out "ВАЛЮТА                  СУММА      КОЛ.С ОСТАТКОМ >0   КОЛ.ВСЕГО ОТКРЫТЫХ" skip.
put stream m-out fill("=", 79) format "x(79)" skip.

totacc$ = 0.
v-koltot = 0.
v-kolalltot = 0.
for each aaa where gl = 220310 no-lock break by aaa.crc:
    if not (aaa.sta = "c" and aaa.cltdt < date$) then do:

      find last aab where aab.aaa = aaa.aaa and aab.fdt < date$ no-lock no-error.
      if avail aab then do:
        if aab.bal <> 0 then do:
          if aaa.crc = 1 then do:
              total$ = (total$ + aab.bal).
          end.
          else do:
              find last crchis where crchis.rdt <= date$ and crchis.crc = aaa.crc no-lock no-error.
              total$ = (total$ + (aab.bal * crchis.rate[1])).
          end.
          v-kol = v-kol + 1.
        end.
        v-kolall = v-kolall + 1.
      end.
    end.

    if last-of(aaa.crc) then do:
        find crc where crc.crc = aaa.crc no-lock no-error.
        val$ = crc.code.
        put stream m-out 
          crc.code
          total$ / 1000 / USD$ format "-zzz,zzz,zzz,zzz,zz9.99" at 9
          v-kol format "zzz,zzz,zz9" at 40
          v-kolall format "zzz,zzz,zz9" at 55 skip. 
        totacc$ = totacc$ + total$.
        total$ = 0.
        v-koltot = v-koltot + v-kol.
        v-kol = 0.

        v-kolalltot = v-kolalltot + v-kolall.
        v-kolall = 0.
    end.
end.

put stream m-out 
  fill("-", 80) format "x(80)" skip
  totacc$ / 1000 / USD$ format "-zzz,zzz,zzz,zzz,zz9.99" at 9
  v-koltot format "zzz,zzz,zz9" at 40
  v-kolalltot format "zzz,zzz,zz9" at 55 skip. 



put stream m-out fill("=", 79) format "x(79)" skip.
output stream m-out close.

if not g-batch then do:
   pause 0 before-hide.
   run menu-prt("rpt.img").
   pause before-hide.
end.
{functions-end.i}                           
