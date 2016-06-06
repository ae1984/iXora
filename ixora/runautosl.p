/* runautosl.p
 * MODULE
        
 * DESCRIPTION
        Проверяет, была ли в этот день проведена автоматическая продажа 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        21.07.2006 NatalyaD
 * CHANGES
        27.07.2006 Natalya D. - добавила возможность отработки данной процедуры за нескольео дней,
        28.07.2006 Natalya D. - добавила статус 1, если отработало без ошибок.
        31.07.2007 Natalya D. - поправила дату отработки последней продажи
                                
       
*/

{global.i}

def var v-lastdt as date.
def var v-dt as date.

find sysc where sysc.sysc = "autosl" .
if not avail sysc then return.

v-lastdt = sysc.daval. 
if v-lastdt < g-today then do:
  do v-dt = v-lastdt to g-today :
     find cls where cls.whn = v-dt no-lock no-error.
     if not avail cls then next. 
     /*do transaction:*/
        run autosale(v-dt).
        if return-value = "1" then do:
           sysc.sts = 1.                                                     
        end.
    /* end.*/
   end.
   sysc.daval = g-today.
end.
else return.



