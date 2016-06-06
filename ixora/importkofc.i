/* importkofc.i
 * MODULE
        Коммунальные платежи 
 * DESCRIPTION
        Загрузка OFFLINE-платежей: смена логина если кассир = epdadm
 * RUN
        
 * CALLER
        *sofp.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        06/05/2004 sasco
 * CHANGES



*/


/* если имя файла = epdadm */
if CAPS(TRIM(v-fname-ofc)) = "EPDADM" then do:

   /* сменим логин, если еще не сменили */
   if v-kofc = "" or v-kofc = "epdadm" then do:

      update v-kofc label "Введите логин кассира" 
             validate (can-find(ofc where ofc.ofc = v-kofc), "Нет такого логина!") 
             with row 5 centered overlay side-labels 
             frame ofcframe title "Смена логина epdadm".

      hide frame ofcframe. 
   end.

end.
/* если файл не EPDADM, то оставим логин кассира в покое */
else 
v-kofc = v-fname-ofc.

