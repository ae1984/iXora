/* depch.p
 * MODULE
       оКЮРЕФМЮЪ ЯХЯРЕЛЮ 
 * DESCRIPTION
        БШБНД МЮХЛЕМНБЮМХЪ НРДЕКЕМХИ ТХКХЮКЮ ОПХ ББНДЕ хд
 * RUN
        яОНЯНА БШГНБЮ ОПНЦПЮЛЛШ, НОХЯЮМХЕ ОЮПЮЛЕРПНБ, ОПХЛЕПШ БШГНБЮ
 * CALLER
        repMT998.p
 * SCRIPT
        яОХЯНЙ ЯЙПХОРНБ, БШГШБЮЧЫХУ ЩРНР ТЮИК
 * INHERIT
        яОХЯНЙ БШГШБЮЕЛШУ ОПНЖЕДСП
 * MENU
       
 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK TXB
 * CHANGES
*/
def input parameter p-depart as integer.
def output parameter p-departch as char.

find txb.ppoint where txb.ppoint.depart = p-depart no-lock.
p-departch = txb.ppoint.name.





