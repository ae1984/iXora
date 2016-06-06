/* pkgcvpkol.p
 * MODULE
        Потребительское кредитование / Пластиковые карточки
 * DESCRIPTION
        Анализ ответа ГЦВП - текстовой строки данных
        на входе
           строка данных ГЦВП
           категория должности заемщика по справочнику pkankkat
        на выходе 
           количество работадателей  
           общая сумма чистого дохода по данным
 * RUN
        
 * CALLER
        pkzakcc.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.10.1, 4.10.2, 4.10.3, 4.10.6 
 * AUTHOR
        17.19.2004 saltanat 
 * CHANGES
*/

{global.i}
{pk.i}

def input  parameter p-gcvptxt as char.
def input  parameter p-katjob as char.
def output parameter p-kolrab as integer.
def output parameter p-chdox as decimal.


{pkanlgcvp.i}

p-kolrab = v-kolrab. /* количество работадателей */
p-chdox  = v-chdox.  /* общая сумма чистого дохода */
