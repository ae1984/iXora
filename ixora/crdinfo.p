/* crdinfo.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26/01/2011 id00004
 * BASES
        BANK COMM
 * CHANGES
        31/01/2011 id00004 изменил знак в формуле
		11.02.2013 - id00477 добавил возможность работы с отрицательными числами
*/
         

{global.i}

  def new shared var v-tday as date.
  def new shared var sum as decimal.
  def stream v-out.
  v-tday = g-today.




function crc-crc-date returns decimal (sum as decimal, c1 as int, c2 as int, d1 as date).
define buffer bcrc1 for crchis.
define buffer bcrc2 for crchis.
    if c1 <> c2 then 
       do:
          find last bcrc1 where bcrc1.crc = c1 and bcrc1.rdt <= d1 no-lock no-error.
          find last bcrc2 where bcrc2.crc = c2 and bcrc2.rdt <= d1 no-lock no-error.
          return sum * bcrc1.rate[1] / bcrc2.rate[1].
       end.
    else return sum.    



end.

  sum = 0.

  {r-branch.i &proc = "crdinfo1"}  
   sum = round(crc-crc-date(decimal(sum), 1, 2, g-today - 1),2).

   output stream v-out to credpoint.js.

                     
     put stream v-out unformatted   "var CRD_POINT_VAL =  """ + replace(trim(string((85000000 - sum),'z,zzz,zzz,zzz,zz9.99-')),","," " )   + """;" skip.

   output stream v-out close.

    unix silent value("cp ./credpoint.js /data/export/currency").     

  
/*  message  sum.
    pause 555.     */