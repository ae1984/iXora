/* r-lgr2.p
 * MODULE
        DEPOSITS
 * DESCRIPTION
        Отчет по действующим депозитным группам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        nmenu.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM
 * AUTHOR
        29.01.04 nataly 
 * CHANGES
*/

def stream rpt.
output stream rpt to rpt.img.
put stream rpt today  ' ' string(time,'hh:mm:ss') skip .
put stream rpt 'Отчет по действующим депозитным группам типа TDA' skip(1) .
put stream rpt  fill('-',40) format 'x(40)'.
put stream rpt skip  'Код группы/  |    Наименование/' skip
                     '  Период     |      %% ставка  ' skip  .
put stream rpt  fill('-',40) format 'x(40)'.

for each lgr where  lgr.led = 'tda' and   not ( lgr.des   matches 'N/A*').
 put stream rpt skip  ' ' lgr.lgr '          ' lgr.des format 'x(40)' .
 for each pri no-lock where substr(pri.pri,2,3) = lgr.pri.
   if substr(pri.pri,5,4) <> '00' then put stream rpt skip ' '     substr(pri.pri,5,4) format 'x(7)' space(11)  pri.trate[1]  format 'z9.99'   .
 end.
 put stream rpt skip  fill('-',40) format 'x(40)'.
   
  put stream rpt skip(1).
end. 
put stream rpt skip '======= КОНЕЦ ДОКУМЕНТА ========'.
output stream rpt close.
run menu-prt('rpt.img').

