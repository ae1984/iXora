/* funstmt.p
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
       30/10/2008 madiyar - перекомпиляция
*/

/* funstmt.p
   изменения от 12.03.2001
   - выбор счета
   - МФО и название банка
*/   
def  var       fdate  as   date .
def  var       tdate  as   date .
def  var       v-otv  as   logical.
def  var       v-acc  like fun.fun.
def  temp-table  tfun
     field  fun      like  fun.fun
     field  crccode  like  crc.code 
     field  dam      like  jl.dam
     field  cam      like  jl.cam
     field  pdam     like  jl.dam
     field  pcam     like  jl.cam
     field  gl       like  gl.gl
     field  jdt      like  jl.jdt
     field  jh       like  jl.jh.

def var idam as deci.
def var icam as deci.
def var bal as deci.
def  stream   m-out.

{mainhead.i}
{functions-def.i}
fdate = g-today.
tdate = g-today.

display
   fdate label " С "
   tdate label " по "
   with row 8 centered  side-labels frame opt title " Введите период: " .

update fdate
   validate(fdate <= g-today,"Должно быть: начало <= сегодня")
   with frame opt.
update tdate validate(tdate >= fdate and tdate <= g-today,
   "Должно быть: начало <= конец <= сегодня")
   with frame opt.
hide frame opt.

display
   '(В)се счета или один (С)чет'
   with row 8 centered  no-label frame opt1 title " Выберите: " .     

update v-otv format 'Все счета/счет' 
   with frame opt1.
hide frame opt1.

if not v-otv then do.
   display v-acc label 'Счет'
   with row 8 centered  side-labels frame opt2 title " Укажите: " .
   
   update v-acc  validate (can-find(fun where fun.fun  = v-acc),
   "Не найден счет!")
   with frame opt2.
   hide frame opt2.
end.
display '   Ждите...   '  with row 5 frame ww centered .
        
output stream m-out to rpt.img.


for each jl where jl.jdt ge fdate 
              and jl.sub = "fun" 
              and jl.lev = 1 no-lock .
 if not v-otv and jl.acc ne v-acc then next.
 if jl.jdt gt tdate then do :
    find first tfun where tfun.fun = jl.acc no-error.
    if not avail tfun then do :
       create tfun.
       tfun.fun = jl.acc.
    end.
    tfun.pdam = tfun.pdam + jl.dam.
    tfun.pcam = tfun.pcam + jl.cam.  
 end.
 else do :
     find first tfun where tfun.fun = jl.acc 
                       and tfun.dam = 0 
                       and tfun.cam = 0
                       no-error.
     if not avail tfun then do :
        create tfun.
        tfun.fun = jl.acc.
        find crc where crc.crc eq jl.crc no-lock no-error.
        if available crc then tfun.crccode = crc.code.
        else tfun.crccode = "   ".
     end.
        tfun.gl = jl.gl.
        tfun.jdt = jl.jdt.
        tfun.jh = jl.jh.
        tfun.dam = tfun.dam + jl.dam.
        tfun.cam = tfun.cam + jl.cam.
 end. 
end.

put stream m-out
FirstLine( 1, 1 ) format 'x(115)' skip(1)
'              '
'Выписка по межбанковским депозитам и кредитам  '  skip
'                    '
'за период с ' string(fdate)  ' по ' string(tdate) skip(1)
FirstLine( 2, 1 ) format 'x(115)' skip(1).

find first tfun no-error.
if not avail tfun then  
   put stream m-out
        'Движения за указанный период времени не было.'.        
else do.
  for each tfun break by tfun.gl by tfun.fun by tfun.jdt :
   
   if first-of(tfun.fun) then do :
     idam = 0.
     icam = 0.
     find fun where fun.fun = tfun.fun no-lock no-error.
     if avail fun then do :
        find gl where gl.gl = fun.gl no-lock no-error.
        if avail gl then do :
          if gl.type = "A" then 
             bal = fun.dam[1] - fun.cam[1] - (tfun.pdam - tfun.pcam).
          else if gl.type = "L" then
             bal = fun.cam[1] - fun.dam[1] - (tfun.pcam - tfun.pdam).
        end.  
        find bankl where bankl.bank = fun.bank no-lock no-error.
     end.   
     put stream m-out 
         skip(1) space(10)
         tfun.fun  tfun.crccode. 
     if avail gl 
        then put stream m-out
                 skip space(10) 
                 tfun.gl '    '  trim(gl.des) format 'x(55)'.
     if avail bankl 
        then put stream m-out
                 skip space(10)
                 bankl.bank  bankl.name format 'x(55)'.
     put stream m-out
       skip
       space(10)
       "-------------------------------------------------------------"
       skip.
     put stream m-out 
          "                   Дебет               Кредит    " 
          "  Дата     Пров." skip.
   end. 
   
   put stream m-out  space(5)
       tfun.dam format "-z,zzz,zzz,zzz,zz9.99"  
       tfun.cam format "-z,zzz,zzz,zzz,zz9.99" "  " 
       tfun.jdt "  "
       string(tfun.jh) skip.
   idam = idam + tfun.dam.
   icam = icam + tfun.cam.
   
   if last-of(tfun.fun) then do :
      put stream m-out
       skip
       space(10)
       "-------------------------------------------------------------"
       skip.
      find gl where gl.gl = tfun.gl no-lock no-error.
      if avail gl then do :
         put  stream m-out
           "Входящее сальдо:" skip.
         if gl.type = "A" then 
            put stream m-out space(5) 
                (bal - idam + icam) format "-z,zzz,zzz,zzz,zz9.99" skip.
         else  
            put stream m-out space(26)
                (bal + idam - icam) format "-z,zzz,zzz,zzz,zz9.99" skip.
         put stream m-out 
           "Обороты:" skip space(5)
           idam format "zz,zzz,zzz,zzz,zz9.99"   
           icam format "zz,zzz,zzz,zzz,zz9.99" skip.
         put  stream m-out
           "Исходящее сальдо:" skip.
         if gl.type = "A" then
            put stream m-out space(5)
                bal format "-z,zzz,zzz,zzz,zz9.99"
                skip(2).
         else
            put stream m-out space(26)
                bal format "-z,zzz,zzz,zzz,zz9.99"
                skip(2).
      end.
   end.   
  end.
end.
output stream m-out close.
if  not g-batch then do:
    pause 0 before-hide .
    run menu-prt( 'rpt.img' ).
    pause before-hide.
end.
{functions-end.i}
return.
