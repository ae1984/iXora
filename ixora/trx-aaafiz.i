/* trx-aaafiz.i
 * MODULE
        Генератор транзакций
 * DESCRIPTION
        Проверка на счет физ. лица по дебету / кредиту чтобы контролировать в 2.7
        Проводка не сделается, если нет контроля для CIF ст. менеджером
 * RUN
 * CALLER
        trxgen0.p
 * SCRIPT
 * INHERIT
 * MENU
 * AUTHOR
        04/11/03 sasco
 * CHANGES
        24/06/2004 dpuchkov - добавил комментарии на проверку РНН для нерезидентов
        17/08/2004 sasco - для Алматинских РКО после 18-00 или с субботние дни проводки без контроля акцепта CIF
        21.09.2004 dpuchkov - добавил ограничение по счетам клиентов .
	    12/05/2006 u00121 - Астане тоже понравилось работать по выходным :)
	    02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
            05/11/2010 marinav - контроль обязателен для всех клинтов
        24.05.2012 evseev - ТЗ-1366 акцептовать в субботу и после 18:00
        17.06.2013 yerganat -tz1501, не проверять аксепт если вызывается из 1.1.2(CFENTE)
*/

define variable dc-type as char.

find sysc where sysc.sysc = "OURBNK" no-lock no-error.
define variable cifcheck as logical initial yes. /* проверять акцепт для CIF или нет */

find last ofchis where ofchis.ofc = g-ofc and ofchis.regdt <= g-today use-index ofchis no-lock no-error.
if not avail ofchis then
find first ofchis where ofchis.ofc = g-ofc and ofchis.regdt >= g-today use-index ofchis no-lock no-error.

/*if avail ofchis then do:*/
   /*if today ne g-today then cifcheck = no.  субботний день */
   /*find sysc where sysc.sysc = "RKOCIF" no-lock no-error.
   if avail sysc then if time > sysc.inval then cifcheck = no.  после 18-00 */
/*end.*/

rcode = 0.
for each tmpl no-lock where tmpl.amt > 0:
    /*  1.  проверим счета клиентов - физ.лиц */
    find aaa where aaa.aaa = tmpl.dracc no-lock no-error.
    if available aaa then
       dc-type = "D".
    else do:
       find aaa where aaa.aaa = tmpl.cracc no-lock no-error.
       if available aaa then dc-type = "C".
    end.
    if available aaa then do:
       /*Ограничение по клиентам*/
       if g-ofc <> 'bankadm' and g-ofc <> "superman" then do:
          find cif where cif.cif = aaa.cif no-lock no-error.
          if available cif then do:
              find last cifsec where cifsec.cif = cif.cif no-lock no-error.
              if avail cifsec then do:
                 find last cifsec where cifsec.cif = cif.cif and cifsec.ofc = g-ofc no-lock no-error.
                 if not avail cifsec then do:
                    message "Клиент не Вашего Департамента." view-as alert-box buttons OK .
                    create ciflog.
                    assign
                      ciflog.ofc = g-ofc
                      ciflog.jdt = today
                      ciflog.cif = cif.cif
                      ciflog.sectime = time
                      ciflog.menu = "Операция по счету".
                      rcode = 70.
                      rdes = string(cif.cif) + " Ограничение доступа " + string(g-ofc).
                    return.
                 end. else do:
                    create ciflogu.
                    assign
                        ciflogu.ofc = g-ofc
                        ciflogu.jdt = today
                        ciflogu.sectime = time
                        ciflogu.cif = cif.cif
                        ciflogu.menu = "Операция по счету".
                 end.
              end.
          end.
       end.

       /*EndОграничение по клиентам*/
       find cif where cif.cif = aaa.cif no-lock no-error.
       if available cif /*and cif.type = 'P'*/  then do:
          if g-fname = 'CFENTE' and cif.type = 'P' then cifcheck = no.
          if cifcheck /*and cif.type = 'P'*/ and (cif.crg = "" or cif.crg = ?) then do:
             rcode = 2.
             rdes = "Счет " + aaa.aaa + " заблокирован! Необходим акцепт для CIF " + aaa.cif.
             return.
          end.
       end. /* cif */
    end. /* aaa */
end.

