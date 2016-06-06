/* r-cashmg.p
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
        30/12/2005 Natalya D.
 * CHANGES
        14/01/2005 Natalya D. - изменила формирование отчёта: данные по счетам 000460823,000904922,001076228,002904580
                                в конце отчёта
*/

/* r-cashmg.p
   Свод кассовых операций по менеджерам за операционный день*/

{mainhead.i}
{functions-def.i}
def var d_date as   date.
def var v-ofc  like ofc.ofc.
def var v-dept like ofc.titcd.
def var v-crc  like crc.crc.
def var v-acc as   char init '000460823,000904922,001076228,002904580'.
def buffer bjl for  jl.

define temp-table t_svod
       field mngr    like ofc.ofc
       field tranzak like jl.jh
       field dsum    as   decimal format "zzz,zzz,zz9.99" init 0.0
       field csum    as   decimal format "zzz,zzz,zz9.99" init 0.0
       field descr   as   char    format "x(50)"
       field ln      as   integer
       field acc     as   char    format "x(10)"
       field dc      as   char    format "x(1)" 
       field crc     like jl.crc
       index indx1 crc.

define temp-table t_svod2
       field mngr    like ofc.ofc
       field tranzak like jl.jh
       field dsum    as   decimal format "zzz,zzz,zz9.99" init 0.0
       field csum    as   decimal format "zzz,zzz,zz9.99" init 0.0
       field descr   as   char    format "x(50)"
       field ln      as   integer
       field acc     as   char    format "x(10)"
       field dc      as   char    format "x(1)" 
       field crc     like jl.crc
       index indx2 crc.


d_date = g-today.

display d_date label "Свод кассовых операций за "
        with row 8 centered  side-labels frame opt title "Введите :".

update d_date
       validate(d_date <= g-today,"За завтра невозможно получить отчет !")
       with frame opt.

hide frame opt.
display '   Ждите...   '  with row 5 frame ww centered .


find ofc where ofc.ofc = g-ofc no-lock no-error.
v-dept = ofc.titcd.

for each jl where jdt = d_date and gl = 100100 use-index jdt no-lock by jl.jh.
  find ofc where ofc.ofc = jl.who and ofc.titcd = v-dept no-lock no-error.
  if avail ofc then do:
    create t_svod.
           t_svod.mngr    = jl.who.
           t_svod.tranzak = jl.jh.
           t_svod.dsum    = jl.dam.
           t_svod.csum    = jl.cam.
           t_svod.descr   = trim(jl.rem[1]) + trim(jl.rem[2]) + trim(jl.rem[3]) + trim(jl.rem[4]) + trim( jl.rem[5]).
           t_svod.ln      = jl.ln.
           t_svod.acc     = jl.acc.
           t_svod.dc      = jl.dc.
           t_svod.crc     = jl.crc.
/*display jl.who jl.jh jl.dam jl.cam jl.acc jl.crc skip.*/
  end.
end.

for each t_svod no-lock.
    find last jl where jl.jh = t_svod.tranzak and (lookup(jl.acc,v-acc) > 0 or jl.gl = 460823) and jl.cam = t_svod.dsum no-lock no-error.
    if avail jl then do:
       create t_svod2.
           t_svod2.mngr    = jl.who.
           t_svod2.tranzak = jl.jh.
           t_svod2.dsum    = jl.dam.
           t_svod2.csum    = jl.cam.
           t_svod2.descr   = trim(jl.rem[1]) + trim(jl.rem[2]) + trim(jl.rem[3]) + trim(jl.rem[4]) + trim( jl.rem[5]).
           t_svod2.ln      = jl.ln.
           t_svod2.acc     = jl.acc.
           t_svod2.dc      = jl.dc.
           t_svod2.crc     = jl.crc.
/*display jl.who jl.jh jl.dam jl.cam jl.acc jl.crc skip.*/
    end.
END.

def stream m-out.
output stream m-out to r-cashmg.img. 
put stream m-out
FirstLine( 1, 1 ) format 'x(80)' skip
'                      '
'Свод кассовых операций по менеджерам за ' string(d_date) skip
'                      '
FirstLine( 2, 1 ) format 'x(80)' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)' skip.
put stream m-out
'Логин менеджера |'
'Транзакция |'
'Сумма дебет    |'
'Сумма кредит   |' 
'Назначение платежа' skip.
put stream m-out  fill( '-', 80 ) format 'x(80)' skip(1).

for each crc no-lock break by crc.crc.
  if last-of (crc.crc) then do:
     v-crc = crc.crc.

     put stream m-out crc.code skip.
     find first t_svod no-lock no-error.
     if avail t_svod then do:
       for each t_svod where t_svod.crc = v-crc no-lock break by t_svod.mngr by t_svod.tranzak.
         find t_svod2 where t_svod2.tranzak = t_svod.tranzak and t_svod2.csum = t_svod.dsum no-lock no-error.
         if avail t_svod2 then next.
         accumulate t_svod.dsum(total).
         accumulate t_svod.csum(total).
         put stream m-out t_svod.mngr    format "x(16)"      '|'                          
                          t_svod.tranzak format "zzzzzzz9"'   |'
                          t_svod.dsum    format "zzz,zzz,zz9.99" '|'
                          t_svod.csum    format "zzz,zzz,zz9.99" '|'
                          t_svod.descr   format "x(50)"
                     skip.
       end.
       put stream m-out  fill( '-', 80 ) format 'x(80)' skip(1).
       put stream m-out 
                       'ИТОГО:          |'
                       '           |'
                       accum total t_svod.dsum format "zzz,zzz,zzz,zz9.99" '|   '
                       accum total t_svod.csum format "zzz,zzz,zzz,zz9.99"
                  skip.
       put stream m-out  fill( '-', 80 ) format 'x(80)' skip(1).
     end.  
  end.
end.
put stream m-out  fill( '-', 80 ) format 'x(80)' skip. 
for each crc where crc.crc =1 or crc.crc = 2 no-lock break by crc.crc.
  find first t_svod2 where t_svod2.crc = crc.crc no-lock no-error.
  if not avail t_svod2 then next.
  
  if last-of (crc.crc) then do:
     v-crc = crc.crc.          
     
     put stream m-out crc.code skip.         
       for each t_svod2 where t_svod2.crc = v-crc  no-lock break by t_svod2.mngr by t_svod2.acc by t_svod2.tranzak.
         accumulate t_svod2.dsum(total).
         accumulate t_svod2.csum(total).
         if first-of (t_svod2.acc) then
         put stream m-out 'Счет: ' t_svod2.acc skip.
         put stream m-out t_svod2.mngr    format "x(16)"      '|'
                          t_svod2.tranzak format "zzzzzzz9"'   |'                          
                          t_svod2.csum    format "zzz,zzz,zz9.99" '|'
                          t_svod2.dsum    format "zzz,zzz,zz9.99" '|'
                          t_svod2.descr   format "x(50)"
                     skip.
       end.
       put stream m-out  fill( '-', 80 ) format 'x(80)' skip(1).
       put stream m-out 
                       'ИТОГО:          |'
                       '           |'                       
                       accum total t_svod2.csum format "zzz,zzz,zzz,zz9.99"
                       accum total t_svod2.dsum format "zzz,zzz,zzz,zz9.99" '|   '
                  skip.
       put stream m-out  fill( '-', 80 ) format 'x(80)' skip(1). 
  end.
end.
output stream m-out close.
if  not g-batch then do:
    pause 0.                            
    run menu-prt( 'r-cashmg.img' ).
end.

{functions-end.i}

return.                         

