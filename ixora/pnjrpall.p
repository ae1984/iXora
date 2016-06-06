/* pnjrpall.p
 * MODULE
        Пенсионные платежи
 * DESCRIPTION
        Отчет по всем возвратам пенсионных платежей за период
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.9.13.2
 * AUTHOR
        11.12.2003 sasco
 * CHANGES
        18.12.2003 sasco добавил и-шку для перекомпиляции
        20.04.2004 sasco добавил поиск по счетам из v-accs
*/
{pnjcommon.i}

{comm-txb.i}
{trim.i}

define shared variable g-ofc as char.
define shared variable g-today as date.

define variable v-d1 as date.
define variable v-d2 as date.
define variable ourbnk as character.

define variable v-accs as character.

v-d1 = g-today.
v-d2 = g-today.

find sysc where sysc.sysc = "PNJACC" no-lock no-error.
if available sysc then v-accs = sysc.chval.

ourbnk = comm-txb ().

define temp-table trz
            field kol as character
            field rmz like remtrz.remtrz
            field ref like remtrz.ref
            field rdt as date
            field rko as character format 'x(25)'
            field sender as character format 'x(25)'
            field rnn as character format 'x(12)'
            field addr as character
            field name as character format 'x(50)'
            field remark as character 
            index idx_trz is primary rmz.

def temp-table pfl
    field bik as char
    field acc as char
    field rnn as char.

/* ----------------------------------------------------------------------------------- */
/*      СПИСОК      ПЕНСИОННЫХ       ФОНДОВ                                            */
/* ----------------------------------------------------------------------------------- */
create pfl. assign pfl.bik = "190401147" pfl.acc = "368609316" pfl.rnn = "600700161857".
create pfl. assign pfl.bik = "190501956" pfl.acc = "000609722" pfl.rnn = "600500052865".
create pfl. assign pfl.bik = "190501601" pfl.acc = "022467804" pfl.rnn = "600700153564".
create pfl. assign pfl.bik = "190501956" pfl.acc = "000609117" pfl.rnn = "600400080570".
create pfl. assign pfl.bik = "190501793" pfl.acc = "001609241" pfl.rnn = "600400083058".
create pfl. assign pfl.bik = "190501949" pfl.acc = "020916675" pfl.rnn = "600900138673".
create pfl. assign pfl.bik = "190501793" pfl.acc = "002609114" pfl.rnn = "301700002503".
create pfl. assign pfl.bik = "190501722" pfl.acc = "011609901" pfl.rnn = "600500057679".
create pfl. assign pfl.bik = "190501724" pfl.acc = "039467996" pfl.rnn = "600400079126".
create pfl. assign pfl.bik = "190501956" pfl.acc = "000609081" pfl.rnn = "600700233594".
create pfl. assign pfl.bik = "190501948" pfl.acc = "001467382" pfl.rnn = "600900137026".
create pfl. assign pfl.bik = "190501719" pfl.acc = "037467525" pfl.rnn = "600700177512".
create pfl. assign pfl.bik = "190501601" pfl.acc = "027467553" pfl.rnn = "061800078991".
create pfl. assign pfl.bik = "190501601" pfl.acc = "025467063" pfl.rnn = "600700164895".
create pfl. assign pfl.bik = "190501956" pfl.acc = "000609777" pfl.rnn = "600700231400".
create pfl. assign pfl.bik = "190501601" pfl.acc = "024467912" pfl.rnn = "302600000655".
create pfl. assign pfl.bik = "190501109" pfl.acc = "413609816" pfl.rnn = "600400073391".
/* ----------------------------------------------------------------------------------- */

def var v-lbin as cha .
def var v-lbina as cha.

find sysc where sysc.sysc = "lbin" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   message "Отсутствует запись LBIN в таблице SYSC!".
   return .
end.
v-lbin = sysc.chval.

find sysc where sysc.sysc = "LBINA" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   message "Отсутствует запись  LBINA в таблице SYSC!".
   return .
end.
v-lbina = sysc.chval.

update v-d1 label "Период с..." v-d2 label "по..." with row 2 centered side-labels frame getdat.
hide frame getdat.

for each remtrz where remtrz.rdt ge v-d1 and remtrz.rdt le v-d2 and rbank = ourbnk no-lock:

    find pfl where remtrz.sacc = pfl.acc and remtrz.sbank = pfl.bik no-error.
    if not avail pfl then next.
    
    find depaccnt where depaccnt.accnt = remtrz.racc no-lock no-error.
    if avail depaccnt then do:

       find ppoint where ppoint.depart = depaccnt.depart no-lock no-error.
    
       create trz.
       trz.rmz = remtrz.remtrz.
       trz.rdt = remtrz.rdt.
       trz.rko = ppoint.name.
       trz.sender = ENTRY (1, remtrz.ord, "/").

    end. /* available depaccnt */
    else do: /* поищем счета из v-accs */

       if lookup (remtrz.racc, v-accs) = 0 then 
	do: 
    		find first sub-cod where sub-cod.sub = 'arp' and
                                         sub-cod.d-cod = 'arptype' and 
                                         sub-cod.ccode = 'penbefreq' and 
                                         sub-cod.acc = remtrz.racc no-lock no-error.
		if not avail sub-cod then next. 
	end.
 
       create trz.
       trz.rmz = remtrz.remtrz.
       trz.rdt = remtrz.rdt.
       trz.sender = ENTRY (1, remtrz.ord, "/").

       find arp where arp.arp = remtrz.racc no-lock no-error.
       if available arp then trz.rko = arp.des.
                        else trz.rko = "Пенсионные плат. до выясн. (" + remtrz.racc + ")".

    end.
    
    for each letters where letters.ref = remtrz.remtrz and letters.refdt = remtrz.rdt no-lock:
        accumulate letters.ref (count).
    end.
    trz.kol = STRING (accum count (letters.ref)).
    if trz.kol = '0' then trz.kol = ''.

    run PARSE.

    find first rnn where rnn.trn = trz.rnn no-lock no-error.
    if available rnn then do:
       trz.addr = GTrim (
                  rnn.post1 + " " +
                  rnn.city1 + " " + 
                  rnn.street1 + " " +
                  rnn.housen1 + " " +
                  rnn.apartn1
                  ).
    end.          
    else do:      
       find first rnnu where rnnu.trn = trz.rnn no-lock no-error.
       if available rnnu then do:
          trz.addr = GTrim (
                     rnnu.post1 + " " +
                     rnnu.city1 + " " + 
                     rnnu.street1 + " " +
                     rnnu.housen1 + " " +
                     rnnu.apartn1
                     ).
       end.          
    end.

end.

output to rpt.csv.
put unformatted "Дата;RMZ;Кол-во писем;СПФ;Пенсионный Фонд;Наименование отправителя;РНН отправителя" skip.
for each trz:
    put unformatted trz.rdt ";" trz.rmz ";" trz.kol ";" trz.rko ";" trz.sender ";" trz.name ";`" trz.rnn skip.
end.
output close.
unix silent cptwin rpt.csv excel.
unix silent rm rpt.csv.

hide all. 
pause 0.

/* ------------------ */
/* ПАРСИНГ СВИФТОВОК  */
/* ------------------ */
procedure PARSE.

   define variable v-ref as char.
   define variable st as character.
   define variable log as logical.
   define variable i as integer.
   define variable wasassign as logical.

   if not available remtrz then return.
   if not available trz then return.

   v-ref = remtrz.ref.
   wasassign = FALSE.

   if search (v-lbin + entry (1,v-ref,"/")) = v-lbin + entry (1,v-ref,"/")
             then unix silent value ("cp " + v-lbin  + entry (1,v-ref,"/") + " pensTEMP").
   else do:
        unix silent value ("cp " + v-lbina + entry (3,v-ref,"/") + ".Z pensRKO.Z ").
        unix silent value ("uncompress -f pensRKO.Z > /dev/null"). 
        unix silent value ("tar xvf pensRKO " + entry (1,v-ref,"/") + " > /dev/null").
        unix silent value ("cp " + entry (1,v-ref,"/") + " pensTEMP > /dev/null").
        unix silent value ("rm " + entry (1,v-ref,"/")).
        unix silent value ("rm pensRKO").
   end.

   log = FALSE.
   input from pensTEMP.
   do while true on endkey undo, leave:
      import unformatted st.

      /* разбор заголовка */
      if st begins "/NAME/" then do:
         if not log then log = TRUE.
         else do:
            trz.name = SUBSTR (st, 7).
            import unformatted st.
            trz.rnn =  SUBSTR (st, 6).
         end.
      end.
      
      /* разбор списка */
      if st begins ":20:" then trz.ref = SUBSTR (st, 5).

      if st begins "/ASSIGN/" then do:
         wasassign = TRUE.
         trz.remark = SUBSTR (st, 9).
      end. else if wasassign then 
           if SUBSTR (st, 1, 1) <> ":" and SUBSTR (st, 1, 2) <> "-}" then trz.remark = trz.remark + st.

   end.
   input close.

   unix silent rm pensTEMP.

end procedure.

