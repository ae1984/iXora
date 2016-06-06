/* r-rasn.p
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


/*
*/

{global.i}
{functions-def.i}

define var datDay as date init 12/20/01.
define buffer c_glday for glday.
define var ctKZT as dec format "->>>,>>>,>>>,>>9.99".
define var dtKZT as dec format "->>>,>>>,>>>,>>9.99".
define var cbal  like glday.bal.

def stream  m-out.
find last cls.
datDay = cls.whn.
display datDay label " за " with row 8 centered  side-labels frame opt title "Введите :".    
update datDay with frame opt.
display '   Ждите...   '  with row 5 frame ww centered .
hide frame opt.
output stream m-out to rpt.img.
put stream m-out skip
FirstLine( 1, 1 ) format 'x(107)' skip(1)
'                      '
'                     ОБОРОТЫ ПО РАСХОДАМ '  skip
'                      '
'                         ЗА ' datDay skip(1)
FirstLine( 2, 1 ) format 'x(107)' skip.

put stream m-out " " skip.
put stream m-out fill("=", 106) format "x(106)" skip.
put stream m-out "ТРАНЗАКЦИЯ              ДЕБЕТ                КРЕДИТ   ВАЛЮТА   ПРИМЕЧАНИЕ                      ИСПОЛНИТЕЛЬ" skip.
 put stream m-out fill("=", 106) format "x(106)" skip.
 
for each glday where (glday.gl >= 500000 and glday.gl < 600000) and glday.gl <> 599980 and glday.gdt = datDay no-lock break by glday.gl by glday.crc:
    find gl where gl.gl = glday.gl.
    if (gl.totlev = 1) then do:
        find last c_glday where c_glday.gl = glday.gl and c_glday.gdt < datDay  and c_glday.crc = glday.crc no-lock no-error.
        if avail c_glday then cbal = c_glday.bal.
                         else cbal = 0.
        find first jl where jl.gl = glday.gl and jl.crc = glday.crc and jl.jdt = datDay no-lock no-error.
        if avail jl then 
           do:  
              put stream m-out "  Счет ГК " glday.gl gl.des skip.
              put stream m-out "  Входящее сальдо:              " cbal skip.
              for each jl where jl.gl = glday.gl and jl.crc = glday.crc and jl.jdt = datDay no-lock break by jl.gl by jl.crc:
                  accumulate jl.dam (total by jl.gl by jl.crc).
                  accumulate jl.cam (total by jl.gl by jl.crc).
                  put stream m-out " " jl.jh " " jl.dam " " jl.cam " " jl.crc "        " jl.rem[1] format "x(30)" "  " jl.who skip.
                  if last-of(jl.crc) then do:
                     put stream m-out "  ИТОГО:  " format "x(11)" accum total by jl.crc jl.dam format "->>>,>>>,>>>,>>9.99" "   " accum total by jl.crc jl.cam format "->>>,>>>,>>>,>>9.99" skip.
                     /*put stream m-out " " skip.*/
                     /*displ accum total by jl.crc jl.dam.
                       displ accum total by jl.crc jl.cam.*/
                     put stream m-out "  Исходящее сальдо:             " glday.bal skip.
                     put stream m-out " " skip.
                     put stream m-out fill("-", 106) format "x(106)" skip.
                 end.
                 if jl.crc = 1 then do:
                    ctKZT = ctKZT + jl.cam.
                    dtKZT = dtKZT + jl.dam.
                 end.
              end.
           end.
        /*put "Исходящее сальдо: " glday.gl glday.bal glday.gdt glday.crc.               
        put stream m-out "  Исходящее сальдо:             " glday.bal skip.
        */
    end.
end.

put stream m-out fill("=", 106) format "x(106)" skip.
put stream m-out "  Итого: " format "x(11)" dtKZT "   " ctKZT "   1" skip.
output stream m-out close. 
if not g-batch then do:
   pause 0 before-hide.
   run menu-prt('rpt.img').
   pause before-hide.
end.
                           
{functions-end.i}
