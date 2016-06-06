/* gllev.p
 * MODULE
        Отчеты о вознаграждении по депозитам
 * DESCRIPTION
        Выводит список счетов ГК  , уровень и тип по заданному счету
 * RUN
        главное меню
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-13-6
 * AUTHOR
        22.01.2004 nataly 
 * CHANGES
*/

def var vgl like gl.gl.

     update vgl label 'ВВЕДИТЕ СЧЕТ ГК' 
     validate( can-find(gl where gl.gl eq vgl),
             "Счет ГК не найден... ")
              help "Введите счет ГК."
              with row 8 centered  side-label frame opt.
hide frame opt.

def stream rpt.
output stream rpt to 'trxlev.txt'.

put stream rpt skip  'Счет ГК (1 ур)  Уровень Тип счета  
Номер ГК(соотв уровня)' . 
put stream rpt skip fill ('-',58) format 'x(58)'.
for each trxlevgl no-lock where  trxlevgl.glr = vgl. 
 put stream rpt skip '    '  trxlevgl.gl  '         '  trxlevgl.lev 
 '      '  trxlevgl.sub '        '  trxlevgl.glr .
end. 
put stream rpt skip(2) '============ КОНЕЦ ДОКУМЕНТА ==============='.
output stream rpt close.
  run menu-prt('trxlev.txt').