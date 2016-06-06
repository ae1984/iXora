/* rep_fl.p 
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
        11/06/2004 dpuchkov
 * CHANGES
        21/06/2004 dpuchkov добавил кор счета 
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
*/


define input parameter i as integer.
define input parameter d_date as date.
define input parameter d_date_fin as date.
define input parameter v-accstatus as char. /*4-счета доходов, 5-счета расходов*/

define shared var v-indexnumber as integer.

def shared stream m-out.
def var v-filial_name as char.
def var v-beg_ost as char.
def var v-end_ost as char.
def var v-sumdam as decimal init 0.
def var v-sumcam as decimal init 0.
def buffer b-jl for txb.jl.


    if  i= 0 then v-filial_name = "ALMATY". else
    if  i= 1 then v-filial_name = "ASTANA". else
    if  i= 2 then v-filial_name = "URALSK". else
    if  i= 3 then v-filial_name = "ATYRAU". 

    for each txb.gl where txb.gl.whn >= d_date and txb.gl.whn <= d_date_fin and txb.gl.totlev = 1  no-lock:
       if  substring(string(txb.gl.gl), 1, 1) = v-accstatus then
       do:
         if (v-accstatus = "4" and v-indexnumber = 0) then
            put stream m-out  '1. СЧЕТА ДОХОДОВ***************************************************************' skip.
         if (v-accstatus = "5" and v-indexnumber = 0) then
            put stream m-out  '2. СЧЕТА РАСХОДОВ***************************************************************' skip.
         v-indexnumber = v-indexnumber + 1.
         put stream m-out  'TEXAKABANK 'v-filial_name ' BRANCH'  skip
                           '# 'string(v-indexnumber)  
                           ' 'string(txb.gl.gl) ''  
                           ' 'txb.gl.des 
                           ' 'txb.gl.whn skip.
/*                         'Открыл: 'txb.gl.who  skip.  */

         put stream m-out unformatted 'Комиссия: '.  
         for each txb.tarif2 where txb.tarif2.kont = txb.gl.gl 
                               and txb.tarif2.stat = 'r' no-lock:
           put stream m-out unformatted txb.tarif2.str5 ', '.   
         end.
           put stream m-out ' ' skip.  

         find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.gdt <= d_date and txb.glday.crc = 1 no-lock no-error.
            if avail txb.glday then  v-beg_ost = string(txb.glday.bal).
         else v-beg_ost = "0".
         find last txb.glday where txb.glday.gl = txb.gl.gl and txb.glday.gdt <= d_date_fin and txb.glday.crc = 1  no-lock no-error.
            if avail txb.glday then v-end_ost = string(txb.glday.bal).
     
         put stream m-out  fill( '-', 80 ) format 'x(80)' skip.
         put stream m-out  'ВХОДЯЩЕЕ САЛЬДО: ' v-beg_ost '        '  skip.
         put stream m-out  fill( '-', 80 ) format 'x(80)' skip.
         put stream m-out  'Дата      Проводка Кор.Сч  Вал.    Дт-сумма      Кт-сумма  Примечание    '  skip.

         v-sumdam = 0.
         v-sumcam = 0.
   
         for each txb.jl where txb.jl.gl = txb.gl.gl and txb.jl.jdt >= d_date and txb.jl.jdt <= d_date_fin  no-lock: 

          if txb.jl.dc = "C"   then  
       	    find last b-jl where b-jl.jh = txb.jl.jh and b-jl.dam = txb.jl.cam  and b-jl.dc = "D"  no-lock no-error.
          if  txb.jl.dc = "D"  then
       	    find last b-jl where b-jl.jh = txb.jl.jh and b-jl.cam = txb.jl.dam  and b-jl.dc = "C"  no-lock no-error.
 
             put stream m-out unformatted  string(txb.jl.jdt)'  'string(txb.jl.jh)'  'string(b-jl.gl)'  'txb.jl.crc format 'zz'  txb.jl.dam format 'zzz,zzz,zz9.99'   txb.jl.cam format 'zzz,zzz,zz9.99  '     string(txb.jl.rem[1])  skip.
/*           put stream m-out  string(txb.jl.jdt)'  'string(txb.jl.jh)'  'string(txb.jl.acc)'  'string(txb.jl.crc) format 'x(2)' '    ' string(txb.jl.dam) format 'zzz,zzz,zz9.99'  '  'string(txb.jl.cam)'       'string(txb.jl.rem[1])'  'string(txb.jl.rem[2]) skip.
*/
            v-sumdam = v-sumdam + txb.jl.dam.
            v-sumcam = v-sumcam + txb.jl.cam.
         end.

         put stream m-out  fill( '-', 80 ) format 'x(80)' skip.
         put stream m-out  'ИТОГО ОБОРОТЫ:               ' v-sumdam format 'zzz,zzz,zz9.99' v-sumcam format 'zzz,zzz,zz9.99'   skip.
         put stream m-out  fill( '-', 80 ) format 'x(80)' skip.
         put stream m-out  'ИСХОДЯЩЕЕ САЛЬДО: ' v-end_ost '       '  skip(2).
       end.
    end.
