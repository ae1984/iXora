/* r-perfl.p
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

/* r-perfl.p
   Невыплаченные переводы физ.лицам - t10930
   27.07.2000 */

{mainhead.i}
{functions-def.i}

define variable fdate as date.
define variable tdate as date.
def var    v-poz     as   integer init 0.
def var    v-remtrz  like remtrz.remtrz.
def var    itog      like remtrz.amt init 0.
fdate = g-today.
tdate = g-today.

display
        fdate label " с "
        tdate label " по "
        with row 8 centered  side-labels frame opt title "Введите период    :" .

update fdate
       validate(fdate <= g-today,"Должно быть: Начало <= Сегодня")
       with frame opt.
              
update tdate validate(tdate >= fdate and tdate <= g-today,
       "Должно быть: Начало <= Конец <= Сегодня")
        with frame opt.
                            
hide frame opt.

display '   Ждите...   '  with row 5 frame ww centered .

def stream m-out.
output stream m-out to rpt.img.

put stream m-out
FirstLine( 1, 1 ) format 'x(80)' skip(1)
'                 '
'НЕВЫПЛАЧЕННЫЕ ПЕРЕВОДЫ (ФИЗИЧЕСКИЕ ЛИЦА) '  skip
'                    '
'за период с ' string(fdate)  ' по '  string(tdate) skip(1)
FirstLine( 2, 1 ) format 'x(80)' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)'  skip.
put stream m-out
' Референс '
'       Сумма'
'    Валюта'
'           Получатель    '
 skip.
 put stream m-out  fill( '-', 80 ) format 'x(80)'  skip(1).
 
for each aaa where aaa.cif = 't10930' no-lock.
    find first jl where jl.acc  = aaa.aaa and jl.dc ='C' 
                    and jl.sts = 6 and jl.jdt ge fdate 
                    and jl.jdt le tdate 
                    no-lock no-error.
    if available jl then do.
       itog = 0.
       for each jl where jl.acc  = aaa.aaa and jl.dc ='C' 
                     and jl.sts = 6 
                     and jl.jdt ge fdate and jl.jdt le tdate no-lock.
           v-poz = index(rem[1],'RMZ').
           if v-poz  <> 0 then do.      
              v-remtrz = substr(rem[1],v-poz,10).
              find remtrz where remtrz.remtrz = v-remtrz no-lock no-error.
              if avail remtrz then do.
                 find crc where crc.crc = remtrz.tcrc no-lock no-error.
                 put stream m-out ' ' v-remtrz 
                                  remtrz.amt format 'zzz,zzz,zz9.99' '   '
                                  crc.code  '   '
                                  remtrz.bn[2] skip.
                 itog = itog + remtrz.amt. 
              end.             
           end.
           else do.
                find crc where crc.crc = jl.crc no-lock no-error.
                find jh where jh.jh = jl.jh no-lock no-error.
                put stream m-out ' ' jh.ref
                                 jl.cam format 'zzz,zzz,zz9.99' '   '
                                 crc.code  '   '
                                 jl.rem[2] skip.
                itog = itog + jl.cam.
           end.
        end.      
put stream m-out ' Итого:    ' itog format 'zzz,zzz,zz9.99' '   ' crc.code skip.
    end.
end.

output stream m-out close.

{functions-end.i}

if  not g-batch then do:
    pause 0 before-hide.
    run menu-prt( 'rpt.img' ).
    pause before-hide.
end.
return.