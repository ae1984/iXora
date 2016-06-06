/* rand.i 
 * MODULE
        оПНЦПЮЛЛШ НАЫЕЦН МЮГМЮВЕМХЪ
 * DESCRIPTION
        пНГШЦПШЬ
 * BASES
        BANK COMM
 * RUN
        яОНЯНА БШГНБЮ ОПНЦПЮЛЛШ, НОХЯЮМХЕ ОЮПЮЛЕРПНБ, ОПХЛЕПШ БШГНБЮ
 * CALLER
        randmain randloto
 * SCRIPT
        
 * INHERIT
        
 * MENU
         
 * AUTHOR
        07/04/2008 Alex
 * CHANGES
*/

def {1} shared var g-winr as char format 'x(10)' no-undo.

def {1} shared temp-table dt-table no-undo
    field ID as integer
    field CODE like g-winr.