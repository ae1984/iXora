/* csreturn.i
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Погашение аванса кассирам СПФ - общая для csretur*.p
 * RUN
        
 * CALLER

 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        29/01/04 sasco
 * CHANGES
        03/02/04 sasco Добавил проставление типа jh.party = "cas" для кассовых ордеров
        03/02/04 sasco Добавил вывод остатков на АРП, логинов кассиров
        04/02/04 sasco Проверка на ofc.tit
        04/02/04 sasco Вывод номера АРП счета
        05/02/04 sasco Добавил формирование JOU документа
        05/02/04 sasco Добавил код валюты через &CRC
        11/02/04 kanat Добавил в вызов vou_bank_ex параметр (подотчет - "1", погашение - "2")
        20.05.04 nadejda - добавлен параметр в vou_bank_ex - печатать ли опер.ордера
        10.09.04 sasco ПРоверка на уволенных сотрудников
        01/02/25 u00121  добавил "or ofc.titcd begins "B"", так как Астана тоже стала работать с этим пунктом
        11/09/05 sasco проверка на закрытый счет
        22/09/06 u00121 буква, с которой начинается ID-СПФ теперь берется из sysc = 'PCRKO', т.к. филиалы почти все имеют СПФ и хотят работать с этой программой
*/

{get-dep.i}
{yes-no.i}
{comm-arp.i}

def var russ as char extent 12 NO-UNDO 
                init ["января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря"].

&SCOPED-DEFINE AVAIL if not avail tmp then leave.
&SCOPED-DEFINE REFRESH browse bt:refresh().
&SCOPED-DEFINE OPEN open query qt for each tmp.

define variable totcnt as integer.
define variable curcnt as integer.

define variable v-dep like depaccnt.depart.
define variable v-sum as decimal format "{&FORMAT}" initial 8600.

define variable v-arp like arp.arp.

define new shared variable s-jh like jh.jh.

define temp-table tmp 
            field arp like arp.arp label "Счет"
            field rko as char format "x(17)" label "СПФ"
            field ofc as char format "x(8)" label "Логин"
            field fio as char format "x(15)" label "Кассир"
            field go  as logical initial yes format "X/ " label "??"
            field sum  as decimal format "{&FORMAT}" label "{&LABEL}"
            field ost as decimal format "-zzzzzzz9.99" label "Остаток АРП"
            index idx_tmp is primary rko fio.

/*
define temp-table tmp 
            field arp like arp.arp label "Счет"
            field rko as char format "x(25)" label "СПФ"
            field ofc as char label "Логин"
            field fio as char format "x(20)" label "Кассир"
            field go  as logical initial yes format "X/ " label "??"
            field sum  as decimal format "{&FORMAT}" label "{&LABEL}"
            field ost as decimal format "-zzzzzzz9.99" label "Остаток АРП"
            index idx_tmp is primary rko fio.
*/

/* список СПФ которые НЕ ПОЛУЧАЮТ монеты 8600 тенге */
find sysc where sysc.sysc = "{&SYSC}" no-lock no-error.
if not avail sysc then do:
   message "Не настроена переменная {&SYSC} в SYSC!" view-as alert-box title "Ошибка".
   return.
end.

def buffer b-sysc for sysc.
find last b-sysc where b-sysc.sysc = 'PCRKO' no-lock no-error. /*u00121 22.09.2006 - префикс номера СПФ (буква с которой начинается ID-спф)*/
if not avail b-sysc then
do:
   message "Не настроена переменная PCRKO в SYSC!" view-as alert-box title "Ошибка".
   return.
end.

for each ofc where ( ofc.titcd begins b-sysc.chval  or ofc.titcd = "514") and ofc.tit <> "" no-lock: 

    /* проверка на уволенных сотрудников */
    find last ofcblok where ofcblok.ofc = ofc.ofc and ofcblok.sts = "u" no-lock no-error.
    if avail ofcblok then next.
    
    v-dep = get-dep (ofc.ofc, today).
    {&LOOKUP_SYSC}
    find depaccnt where depaccnt.point = 1 and depaccnt.depart = v-dep no-lock no-error.
    find ppoint where ppoint.point = 1 and ppoint.depart = v-dep no-lock no-error.
    v-arp = "".
    for each arp where arp.crc = {&CRC} no-lock:
        find first sub-cod where sub-cod.sub = "arp" and
                                 sub-cod.d-cod = "clsa" and
                                 sub-cod.acc = arp.arp 
                                 no-lock no-error.
        if avail sub-cod then if sub-cod.ccode <> 'msc' then next.
        find first sub-cod where sub-cod.sub = "arp" and
                                 sub-cod.d-cod = "arptype" and
                                 sub-cod.acc = arp.arp 
                                 no-lock no-error.
        if not avail sub-cod then next.
        if sub-cod.ccode <> "{&SUB-COD}" then next. 

        find first sub-cod where sub-cod.sub = "arp" and
                                 sub-cod.d-cod = "sproftcn" and
                                 sub-cod.acc = arp.arp 
                                 no-lock no-error.
        if not avail sub-cod then next.
        if sub-cod.ccode <> ofc.titcd then next.
        v-arp = arp.arp.
        leave.
    end.
    if v-arp = "" then do:
    /*   message "Не найден АРП счет для " ppoint.name "~n({&ARP_DESCR})" view-as alert-box title "". */
       next.
    end.
    
    find arp where arp.arp = v-arp no-lock no-error.
    if avail arp then do:
       find gl where gl.gl = arp.gl no-lock no-error.
       create tmp.
       assign tmp.arp = v-arp
              tmp.rko = ppoint.name
              tmp.ofc = ofc.ofc
              tmp.fio = ofc.name
              tmp.go  = yes
              tmp.sum  = {&SUM}
              .
       if gl.type = "A" or gl.type = "E" then tmp.ost = arp.dam[1] - arp.cam[1].
                                         else tmp.ost = arp.cam[1] - arp.dam[1].
    end.
end.

 
define query qt for tmp.
define browse bt query qt
              display tmp.go 
                      tmp.rko 
                      tmp.fio
                      tmp.ofc
                      tmp.sum
                      tmp.ost 
                      with row 1 centered 14 down title "Выберите кассира".
define frame ft bt help "ENTER-выбор, TAB-править суммы, F1-конец, F2-выделить все" skip
             "Счет АРП: " tmp.arp view-as text
             with row 1 centered overlay no-label no-box.

define frame v-editfr
             v-sum label "{&LABEL}"
             with row 5 centered overlay title "Правка суммы".

define frame editfr
             tmp.sum label "{&LABEL}"
             with row 5 centered overlay title "Правка суммы".

/* ------------------------------------- */


on "return" of browse bt do:
   {&AVAIL}
   tmp.go = not tmp.go.
   {&REFRESH}
end.


on "TAB" of browse bt do:
   {&AVAIL}
   if not tmp.go then message "Нельзя править суммы кассиру без отметки!" view-as alert-box title "".
   if not tmp.go then leave.
   update tmp.sum with frame editfr.
   hide frame editfr.
   {&REFRESH}
end.

on "help" of browse bt do:
   for each tmp:
       tmp.go = not tmp.go.
   end.
   {&REFRESH}
end.


on "go" of browse bt do:
   if not yes-no ("", "Закончить редактирование, сделать проводки?") then leave.
   hide frame ft. 

   totcnt = 0.
   curcnt = 0.
   for each tmp where go and tmp.sum > 0:
       totcnt = totcnt + 1.
   end.
   
   message " Печатать ОПЕРАЦИОННЫЕ ордера? " update v-prtorder as logical.

   for each tmp where go and tmp.sum > 0:

       curcnt = curcnt + 1.

      /* выдача */
      {&TRANSACTION}

      if return-value = "" or return-value = ? then do:
         message "Ошибка проводки!~n" + tmp.fio view-as alert-box title "".
         undo, return.
      end.

      s-jh = integer (return-value).
      find first jl where jl.jh = s-jh no-lock no-error.
      if not avail jl then do:
         message "Ошибка проводки!~n" + tmp.fio view-as alert-box title "".
         undo, return.
      end.

      /* проставим тип проводки */
      find jh where jh.jh = s-jh no-error.
      jh.party = "cas".

      /* кас. план */
      if {&CRC} = 1 then run setcsymb (s-jh, "{&CAS_SYMB}").

      /* ордер */
      run vou_bank_ex ({&NUM_ORDERS},"2", v-prtorder).

      /* формирование JOU документа */
      run jou.

   end.

   find first tmp where tmp.go and tmp.sum > 0 no-error.
   if not avail tmp then message "Нет записей для проводок!~n(Не выбраны АРП счета или сумма = 0)" view-as alert-box title "".

   apply "enter-menubar" to frame ft.

end.

on "value-changed" of browse bt do:
   if not avail tmp then displ "" @ tmp.arp with frame ft.
                    else displ tmp.arp with frame ft.
end.

/* ------------------------------------- */

if "{&ASKSUM}" = "yes" then do:

   update v-sum with frame v-editfr.
   hide frame v-editfr.

   for each tmp:
       tmp.sum = v-sum.
   end.

end.

{&OPEN}
enable all with frame ft.
apply "value-changed" to bt in frame ft.
wait-for "window-close" of current-window or "enter-menubar" of frame ft or "window-close" of frame ft focus browse bt.
hide frame ft.

