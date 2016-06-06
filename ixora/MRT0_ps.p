/* MRT0_ps.p
 * MODULE 
        Монитор для казначейства.
 * DESCRIPTION 
        Консолидированный отчет по минимальным резервным требованиям для монитора.
 * RUN
 
 * CALLER
 
 * SCRIPT
 
 * INHERIT

 * MENU 
        
 * AUTHOR  
        05/09/2006 tsoy 
 * CHANGES

*/

def new shared var v-sum as dec.

run MRT_ps.

do transaction.
     find bank.sysc where bank.sysc.sysc = 'MRTMON' no-error.
     bank.sysc.deval =  v-sum.
     release sysc.
end.
/*
find bank.sysc where bank.sysc.sysc = 'MRTMON' exclusive-lock no-error.
bank.sysc.deval =  v-sum.
*/
displ  v-sum.
