/* r-depaaa5.p
 * MODULE
        Отчет по начисленному вознаграждению 
 * DESCRIPTION
        Отчет по начисленному вознаграждению
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        depo5.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-13-2 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

def new shared temp-table  temp2
   field acc as char format 'x(9)'
   field jh  as integer
   field crc as integer
   field bank as char format 'x(3)'
   field bal  as decimal
   field jdt as date
   field col1  as integer
   field priz as char.

def new shared var dt1 as date  .
def new shared var dt2 as date  .
def new shared var v-branch as char.
def new shared var v-name as char.
def new shared  stream nur.

def var i as date .

def new shared var sum1v as integer.
def new shared var sum2v as decimal.


/* dt2 не должен превышать последний закрытый ОД!!!! */ 
 find first cmp no-lock no-error.
{global.i}
if not g-batch then do:
            update  dt1 label 'Введите начальную дату' validate (dt1 < g-today, 
                " Вводимая дата должна быть меньше даты тек ОД  "  )
              dt2 label 'конечную дату' /* validate (dt2 >= dt1, 
                " Неверно введена конечная дата "  ) */
              with row 8 centered  side-label  frame opt.
end. 
   hide frame  opt.
      

 display '   ЖДИТЕ...   '  with row 5 frame ww centered .

output stream nur to rpt.img.
  put stream nur skip
  string( today, '99/99/9999' ) + ', ' +
  string( time, 'HH:MM:SS' ) + ', ' +
  trim( cmp.name ) format 'x(79)' at 02 skip(1).

for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("txb") then disconnect "txb".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    v-branch =  txb.service .
    v-name = txb.name.
    run obor2.
end.
    
if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".


/*----------- печать результатов ------------ */
put stream nur skip " ОТЧЕТ ПО РАСПРЕДЕЛЕНИЮ ПЛАТЕЖНОГО ОБОРОТА  "   + v-name at 15  skip  
"С " at 25 dt1  " ПО "  dt2 skip.


for each temp2  break by temp2.bank by temp2.priz.
  ACCUMULATE temp2.col1 (count by temp2.bank by temp2.priz ).
  ACCUMULATE temp2.bal (total by temp2.bank by  temp2.priz).
 

put stream nur temp2.jh format 'zzzzzzzz9' temp2.crc '     ' temp2.bal format '->>,>>>,>>>,>>9.99' ' ' temp2.col1 ' '  temp2.priz  '   ' temp2.bank format 'x(10)' temp2.acc format 'x(12)' skip.

 if last-of(temp2.priz) then  do:

  sum1v = ACCUMulate count  by (temp2.priz) temp2.col1.   
  sum2v = ACCUMulate total  by (temp2.priz) temp2.bal.   


    put stream nur   'TOTAL'    
                sum1v format '->>>,>>>,>>9'  at 8 
                sum2v format '->>,>>>,>>>,>>9.99'  at 25  ' '  temp2.priz skip.
 
  end. /*last-of temp2.lgr*/


end. /*temp2*/

/*----------- печать результатов ------------ */


  /* put stream nur  ' ' fill ('=',112) format 'x(112)' at 1.
    put stream nur skip 'ПО ' at 1 vgl  accum count temp2.aaa format 'zzzz9' at 13  
                        ACCUMulate total  temp2.v-acrrlv  format '->,>>>,>>9.99'  at 67 - 20 
                        ACCUMulate total  temp2.v-acrrv   format '->>,>>>,>>9.99'  at 85 - 20
                        ACCUMulate total  temp2.prib-aaav format '->>>,>>>,>>9.99' at 100 - 20 
                        ACCUMulate total  temp2.v-aaaminv format '->>>,>>>,>>9.99' at 117 - 20 .  

*/
 put stream nur  skip(1) 
      " =====      КОНЕЦ ДОКУМЕНТА     ====="
    SKIP(1).
output stream nur close.
 hide  frame ww no-pause.

run menu-prt( 'rpt.img' ). 
pause 0.
