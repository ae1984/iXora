/* jsprav.p
 * MODULE
        мЮГБЮМХЕ ЛНДСКЪ
 * DESCRIPTION
        нОХЯЮМХЕ
 * RUN
        яОНЯНА БШГНБЮ ОПНЦПЮЛЛШ, НОХЯЮМХЕ ОЮПЮЛЕРПНБ, ОПХЛЕПШ БШГНБЮ
 * CALLER
        яОХЯНЙ ОПНЖЕДСП, БШГШБЮЧЫХУ ЩРНР ТЮИК
 * SCRIPT
        яОХЯНЙ ЯЙПХОРНБ, БШГШБЮЧЫХУ ЩРНР ТЮИК
 * INHERIT
        яОХЯНЙ БШГШБЮЕЛШУ ОПНЖЕДСП
 * MENU
        оСМЙР ЛЕМЧ
 * AUTHOR
        30/09/2008 galina
 * BASES
        BANK COMM
 * CHANGES
*/

def var v-list as char.
v-list = ''.
for each {&table} no-lock break by {&table}.{&field}:
  if v-list <> '' then v-list = v-list + '|'.
  v-list = v-list + {&field}.
end. 
v-sel = 0.
run sel2({&flname},v-list, output v-sel).
