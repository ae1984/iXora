/* mrpfind.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Поиск МРП в зарплатном модуле для расчетов в отчетах
 * RUN
        vcrep14.p
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        15-5-2, 15-4-x-2
 * AUTHOR
        20.01.2004 nadejda
 * CHANGES
*/

def input parameter v-mc as integer.
def input parameter v-god as integer.
def output parameter v-summrp as decimal.

find first alga.rmin where alga.rmin.god = v-god and alga.rmin.mc = v-mc no-lock no-error.
if not avail alga.rmin or alga.rmin.rpm = ? then do:
     message " Нет месячного расчет.показателя за месяц " v-mc ", год " v-god. 
     pause 10. 
     return.
end.                    
v-summrp = alga.rmin.rpm. 

