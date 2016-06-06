/* r-konvl.p
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
	03/01/2005 u00121 - Название банка теперь берем из таблицы CMP - п.п. Прагмы 9-1-1-1
*/

def new shared var v-dat as date.
v-dat = today.
update v-dat label ' Укажите дату' format '99/99/9999'  
                  skip with side-label row 5 centered frame dat .


unix silent value ("echo > rpt.img").

def new shared temp-table valbs
             field gl like bank.gl.gl 
             field des like bank.gl.des
             field type like bank.gl.type
             field crc like bank.glday.crc
             field sumv like bank.glday.bal
             field sumt like bank.glday.bal
             INDEX igl gl.

run comm-con.
run r-konvl1 (input v-dat).

def stream m-out.
define variable fname as character format "x(12)".
def var hostmy   as char format 'x(15)'.
def var dirc     as char format 'x(15)'.
def var ipaddr   as char format 'x(15)'. 


dirc = 'L:/capital/common/diling'.
/*dirc = 'C:/1'.*/
fname = 'dil' + substring(string(v-dat),1,2) +
      substring(string(v-dat),4,2) + '.all'.
      
output stream m-out to rpt.img.
find first bank.cmp no-lock no-error. /*03/01/2004 u00121*/
put stream m-out  bank.cmp.name /*03/01/2004 u00121*/ format 'x(20)'.     
put stream m-out skip(1).
 put stream m-out "Консолидированный валютный баланс в валюте и тенге".
put stream m-out skip(1).
put stream m-out  'за ' v-dat skip(1).

for each valbs break by valbs.crc by valbs.type by valbs.gl:


    if first-of(valbs.crc) then do:
       find first bank.crc where bank.crc.crc = valbs.crc no-lock no-error.
       put stream m-out skip fill("=",80)format "x(80)".
       put stream m-out skip(1) 'Валюта ' bank.crc.des skip.
    end.

    if first-of(valbs.type)
        then do:
          if valbs.type eq "A"
            then do:
                 put stream m-out skip(1) "*** АКТИВЫ ***" skip(1).
            end.
          else if valbs.type eq "L"
            then do:
                 put stream m-out skip(1) "*** ПАССИВЫ ***" skip(1).
            end.
          else if valbs.type eq "O"
            then do:
                 put stream m-out skip(1) "*** КАПИТАЛ ***" skip(1).
            end.
        end.

   if valbs.sumv ne 0 then 
     put stream m-out valbs.gl ' ' valbs.des valbs.crc valbs.sumv valbs.sumt skip.
  

end.

output stream m-out close. 
run menu-prt( 'rpt.img' ).

/*  input through askhost.
  repeat:
    import hostmy.
  end.
  input close.
  input through value( 'resolveip -s ' + hostmy ).
  repeat:
    import ipaddr.
  end.
  input close. */

/*  ipaddr = 'ntmain.texakabank.kz'.
  unix un-dos rpt.img value(fname).
  input through value("rcp " + fname + " " + ipaddr + ":" + dirc + ";echo $?" ).
  pause 0.
*/
