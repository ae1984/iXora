/* csaccept.p
 * MODULE
        Касса
 * DESCRIPTION
        Штамп в ЦО проводок крупных СПФ по выдача авансов кассирам и погашениям
 * RUN
        
 * CALLER

 * SCRIPT
        
 * INHERIT

 * MENU
        
 * AUTHOR
        26/03/04 sasco
 * CHANGES
        26/03/04 sasco кол-во кассовых ордеров = 2 и не запускать trxsts (sts=6 вручную)
        04/05/04 sasco вывел подробное описание проводки ниже фрейма
        20.05.04 nadejda - добавлен параметр в vou_bank_ex - печатать ли опер.ордера
        20.09.04 sasco проверка на уволенных сотрудников
	02/02/25 u00121  добавил "or ofc.titcd begins "B"", так как Астана тоже стала работать с этим пунктом
        18.08.2006 dpuchkov оптимизация.
*/

{get-dep.i}
{yes-no.i}
{msg-box.i}

define shared variable g-today as date.
define shared variable g-ofc as character.
define variable v-dep   like depaccnt.depart.
define new shared variable s-jh like jh.jh.
define variable rcode as integer.
define variable rdes as character.
define var v-cash as logical.
define var cashgl like jl.gl.

define variable np1 as character.
define variable np2 as character.

define temp-table wrk 
            field jh   like jh.jh
            field ofc  like ofc.ofc
            field rko  as character format 'x(20)' label 'СПФ'
            field npl  as character format 'x(30)' label 'Вид платежа'
            field crc  like crc.crc
            field ccrc like crc.code label 'Вал'
            field sum  as decimal format '>>>>>>>>9.99' label 'Сумма'
            index idx_wrk is primary rko crc.

define query qt for wrk.
define browse bt query qt
            displ wrk.rko
                  wrk.sum
                  wrk.ccrc 
                  wrk.npl 
            with row 1 centered 10 down.

define frame ft bt help 'ENTER-выбрать проводку для штампа; F4-конец' 
             skip
             np1 format "x(70)" view-as text skip
             np2 format "x(70)" view-as text 
             with title 'Список проводок для штамповки' no-label.

define temp-table t-acc
            field acc like arp.arp
            field ofc like ofc.ofc
            field rko  as character format 'x(30)'
            field crc  like crc.crc
            field ccrc  like crc.code label 'Вал'.

/* ТРИГГЕРЫ ------------------------------------- */

on "value-changed" of browse bt do:
   if not avail wrk then assign np1 = "" np2 = "".
   else assign np1 = substr(trim(wrk.npl), 1, 70)
               np2 = substr(trim(wrk.npl), 71).
   displ np1 np2 with frame ft.
end.

on "return" of browse bt do:
 if not avail wrk then leave.
 if not yes-no ('', 'Штамповать?') then leave.

 do transaction:
    s-jh = wrk.jh.
    find jh where jh.jh = s-jh exclusive-lock.
    jh.sts = 6.     
    for each jl where jl.jh = s-jh exclusive-lock:
        jl.sts = 6.
        jl.teller = g-ofc.
    end.
    find sysc where sysc.sysc = 'CASHGL' no-lock no-error.
    if avail sysc then
    do:
       cashgl = sysc.inval.
       for each jl where jl.jh = s-jh no-lock:
          if jl.sts = 6 and jl.gl = cashgl then
          do:
              find first cashofc where cashofc.whn eq today and cashofc.sts eq 2 and cashofc.ofc eq g-ofc and cashofc.crc eq jl.crc exclusive-lock no-error.
              if avail cashofc then 
              do:
                  cashofc.amt = cashofc.amt + jl.dam - jl.cam.
              end.
              else do:
                   create cashofc.
                   cashofc.whn = today.
                   cashofc.ofc = g-ofc.
                   cashofc.crc = jl.crc.
                   cashofc.sts = 2.
                   cashofc.amt = jl.dam - jl.cam.
                   cashofc.who = g-ofc.
              end.
              release cashofc.
          end. 
      end.  /* each jl */
    end. /* avail sysc */

    message " Печатать ОПЕРАЦИОННЫЙ ордер? " update v-prtorder as logical.
    run vou_bank_ex (2, "3", v-prtorder).
    delete wrk.
    
    if can-find (first wrk) then do:
         close query qt.
         open query qt for each wrk.
         browse bt:refresh().
    end.
 end. /* transaction */
end.                                


/* ОСНОВНАЯ ЧАСТЬ ------------------------------- */
find sysc where sysc.sysc = "CASDP3" no-lock no-error.
if not avail sysc then do:
   message "Не настроена переменная CASDP3 в SYSC!" view-as alert-box title "Ошибка".
   return.
end.

/* ВРЕМЕННАЯ ТАБЛИЦА ---------------------------- */
run SHOW-MSG-BOX ("Формирование списка счетов СПФ...").


for each ofc where (ofc.titcd begins "A" or ofc.titcd begins "B") and ofc.tit <> "" no-lock: /*	02/02/25 u00121  добавил "or ofc.titcd begins "B"", так как Астана тоже стала работать с этим пунктом*/
    /* проверка на уволенных сотрудников */
    find last ofcblok where ofcblok.ofc = ofc.ofc and ofcblok.sts = "u" no-lock no-error.
    if avail ofcblok then next.
    v-dep = get-dep (ofc.ofc, g-today).
    if lookup (trim(string(v-dep, "zzz9")), sysc.chval) = 0 then next.
    find ppoint where ppoint.point = 1 and ppoint.depart = v-dep no-lock no-error.
    for each arp no-lock:
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp no-lock no-error.
        if not avail sub-cod then next.
        if sub-cod.ccode <> "obmen1002" then next. 
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp no-lock no-error.
        if not avail sub-cod then next.
        if sub-cod.ccode <> ofc.titcd then next.
        find crc where crc.crc = arp.crc no-lock no-error.
        create t-acc.
        assign t-acc.ofc = ofc.ofc
               t-acc.acc = arp.arp
               t-acc.crc = arp.crc
               t-acc.ccrc = CAPS (crc.code)
               t-acc.rko = ppoint.name.
    end.
end.

run SHOW-MSG-BOX ("Поиск неотштампованных проводок...").

for each t-acc:
    for each jl where jl.acc = t-acc.acc and jl.jdt = g-today and jl.crc = t-acc.crc and jl.sts = 5 no-lock:
        find wrk where wrk.jh = jl.jh no-error.
        if avail wrk then next.
        create wrk.
        assign wrk.jh = jl.jh
               wrk.ofc = t-acc.ofc
               wrk.crc = t-acc.crc
               wrk.ccrc = t-acc.ccrc
               wrk.rko = t-acc.rko
               wrk.sum = jl.dam + jl.cam
               wrk.npl = trim(jl.rem[1] + jl.rem[2] + jl.rem[3]).
    end.
end.

run HIDE-MSG-BOX.
                          
/* ОТОБРАЗИМ BROWSE ----------------------------- */

open query qt for each wrk.
enable all with frame ft.
apply "value-changed" to browse bt.
wait-for window-close of current-window focus browse bt.
hide all.
pause 0.

