/* pkanlgcvp.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Анализ ответа ГЦВП - текстовой строки данных
        на входе
           строка данных ГЦВП
           категория должности заемщика по справочнику pkankkat
        на выходе 
           1/0 - выносится/нет на КредКом 
           сумма чистого дохода по данным
 * RUN
        
 * CALLER
        pkafterank-6.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.13.1
 * AUTHOR
        29.12.2003 nadejda
 * CHANGES
*/


{global.i}
{pk.i}

def input parameter p-gcvptxt as char.
def input parameter p-katjob as char.
def output parameter p-kred as integer.
def output parameter p-sumdohod as decimal.


{pkanlgcvp.i}

p-kred = v-kred.
p-sumdohod = v-sumdohod.


