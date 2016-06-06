/* prit_dog.p
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
        14.04.2004 nadejda - увеличен формат вывода суммы на 2 разряда
        24.08.2006 ten     - изменил вид вывода данных в word
        22.09.2006 ten     - добавил проверку на cif.prefix.

*/

/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

  def input parameter vaaa like aaa.aaa.
/*    def var vaaa like aaa.aaa.
vaaa = '061759860'.
 */
  def var        decAmount like jl.dam no-undo.
  def var        strAmount as char format "x(200)" no-undo.
  def var        temp as char no-undo.
  def var        vmonth as int no-undo. 
  def var        strTemp as char no-undo. 
  def var        str1 as char format "x(50)" no-undo.
  def var        str2 as char format "x(50)" no-undo.
  def var        v-opn as dec no-undo.
output to rpt.img.  
find first aaa where aaa.aaa = vaaa no-lock no-error.
find first cif where cif.cif = aaa.cif no-lock no-error.

decAmount = aaa.opnamt. 
   put unformatted ' ' entry(1,trim(trim(cif.prefix) + " " + trim(cif.name)),' ') skip.
   if num-entries(trim(trim(cif.prefix) + " " + trim(cif.name)),' ') > 1 then
   put unformatted ' ' entry(2,trim(trim(cif.prefix) + " " + trim(cif.name)),' ') skip.
   if num-entries(trim(trim(cif.prefix) + " " + trim(cif.name)),' ') > 2 then
      put unformatted ' ' entry(3,trim(trim(cif.prefix) + " " + trim(cif.name)),' ') format "x(20)" cif.expdt skip.
   else 
      put unformatted ' ' space(20) cif.expdt skip.
   put ' ' cif.pss skip.   
   put cif.jss  vaaa skip.
   put ' ' cif.addr[1] skip.
   put ' ' cif.addr[2].
   put skip(2).
   put ' ' cif.tel format 'xxxxxxxxxx' ' ' trim(cif.tlx) ' ' cif.fax.
   put skip.
   vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).
  if aaa.lgr = 'D31' and vmonth >= 15 and aaa.opnamt >= 500 then do:
   put  'ВАШ ШАНС *' truncate(aaa.opnamt / 500,0) format '>>>9'
        '  ВАШ ШАНС *' truncate(aaa.opnamt / 500,0) format '>>>9'
        '  ВАШ ШАНС *' truncate(aaa.opnamt / 500,0) format '>>>9'
        '  ВАШ ШАНС *' truncate(aaa.opnamt / 500,0) format '>>>9' skip(1).
  end.
  else put skip(2).
   put  aaa.regdt format '99999999' '      ' aaa.expdt format '99999999'  skip.
   vmonth = round((aaa.expdt - aaa.regdt) * 12 / 365 , 0).
   run Sm-vrd(input vmonth, output strAmount).
   strAmount = trim(strAmount).
   if vmonth = 1 then put unformatted ' ' strAmount '  месяц' skip.
   if vmonth > 1 and vmonth < 5 then put unformatted ' ' strAmount '  месяца' skip.
   if vmonth > 4 then put unformatted ' ' strAmount '  месяцев' skip.
   
    temp = string (decAmount).
     if num-entries(temp,".") = 2 then do:
        temp = substring(temp, length(temp) - 1, 2).
        if num-entries(temp,".") = 2 then
            temp = substring(temp,2,1) + "0".
     end.
     else temp = "00".
    strTemp = string(truncate(decAmount,0)).
                
  run Sm-vrd(input decAmount, output strAmount).
  run sm-wrdcrc(input strTemp,input temp,input aaa.crc,output str1,output str2).
  
  strAmount = strAmount + " " + str1 + " " + temp + " " + str2.
 
 if length(strAmount) > 47 then do:  
       str1 = substring(strAmount,1,47). 
       str2 = substring(strAmount,48,length(strAmount,"CHARACTER") - 47).
       put unformatted ' ' str1 skip str2 skip(1).
 end.
 else  put ' ' strAmount skip(2).
 
 v-opn = round(aaa.opnamt,2).
 put trim(string(v-opn)) format 'x(12)' '  ' round(aaa.rate,2) skip.

 if aaa.lgr = 'D31' and vmonth >= 15 and aaa.opnamt >= 500 then do:
    put  '                     ВАШ ШАНС * ' truncate(aaa.opnamt / 500,0) format '>>>9' skip(6).
 end.
 else put skip(7).
 
 output close.   
 
/* unix value( 'cptwo ' + 'rpt.img').*/
 unix silent cptwin rpt.img winword.exe.


