/* pmpgcvp.p
 * MODULE
        Социальные платежи
 * DESCRIPTION
        Поиск возвратов социальных платежей (СПФ-шные)
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.9.14.1
 * AUTHOR
        30.03.2005 kanat
 * CHANGES
*/

{pnjcommon.i}

{comm-txb.i}
{yes-no.i}
{sysc.i}
{trim.i}

define shared variable g-ofc as char.
define shared variable g-today as date.

define variable v-d1 as date.
define variable v-d2 as date.
define variable ourbnk as character.

define variable v-letter as integer.
define variable v-letnum as character.
define variable v-header as character.
define variable v-footer as character.

define variable v-accs as character.

v-d1 = g-today.
v-d2 = g-today.

/* Список счетов до выяснения */
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

define temp-table tsw
            field rmz like remtrz.remtrz
            field npp as integer 
            field sum as character format 'x(15)'
            field sik as character format 'x(16)'
            field ln as character format 'x(50)'
            field fn as character format 'x(50)'
            field mn as character format 'x(50)'
            field bdate as date
            field rnn as character format 'x(12)'
            index idx_tsw is primary rmz.

define buffer b-trz for trz.
define query qt for trz.

define browse bt query qt
       displ trz.kol label "Писем" format 'x(2)'
             trz.rmz label "RMZ"
             trz.rko label "СПФ"
             trz.sender label "Отправитель"
             with row 1 centered 12 down.
define frame ft bt help "ENTER-просмотр; F1-список Excel; F2-печать письма".

def temp-table pfl
    field bik as char
    field acc as char
    field rnn as char.

create pfl. assign pfl.bik = "190201125" 
                   pfl.acc = "368609110" 
                   pfl.rnn = "600400073391".

def var v-lbin as char.
def var v-lbina as char.

/* Счетчик возвр. социальных. писем */
find sysc where sysc.sysc = "GCVPLC" no-lock no-error.
if not available sysc then do:
   message "Отсутствует запись GCVPLC в таблице SYSC!".
   return .
end.
v-letter = GET-SYSC-INT ("GCVPLC").

/* Путь для загруженных социальных платежей (уже отправленных) */
find sysc where sysc.sysc = "lbin" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   message "Отсутствует запись LBIN в таблице SYSC!".
   return .
end.
v-lbin = sysc.chval.

/* Путь для загруженных социальных платежей (уже отправленных) - которые в архиве */
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

    find first pmpaccnt where pmpaccnt.accnt = remtrz.racc no-lock no-error.
    if avail pmpaccnt then do:

       find ppoint where ppoint.depart = pmpaccnt.depart no-lock no-error.
    
       create trz.
       trz.rmz = remtrz.remtrz.
       trz.rdt = remtrz.rdt.
       trz.rko = ppoint.name.
       trz.sender = ENTRY (1, remtrz.ord, "/").

    end.
    else do: /* поищем в счетах до выяснения */

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
                        else trz.rko = "Социальные плат. до выясн. (" + remtrz.racc + ")".

    end.

    for each letters where letters.ref = remtrz.remtrz and letters.refdt = remtrz.rdt and letters.type = "pmprmz" no-lock:
        accumulate letters.ref (count).
    end.
    trz.kol = STRING (accum count (letters.ref)).
    if trz.kol = '0' then trz.kol = ''.

    run PARSE.

    find first rnn where rnn.trn = trz.rnn no-lock no-error.
    if available rnn then do:
       trz.addr = GTrim (
                   (if rnn.post1 = ? then "" else rnn.post1) + " " +
                   (if rnn.city1 = ? then "" else rnn.city1) + " " + 
                   (if rnn.street1 = ? then "" else rnn.street1) + " " +
                   (if rnn.housen1 = ? then "" else rnn.housen1) + " " +
                   (if rnn.apartn1 = ? then "" else rnn.apartn1)
                  ).
    end.          
    else do:      
       find first rnnu where rnnu.trn = trz.rnn no-lock no-error.
       if available rnnu then do:
          trz.addr = GTrim (
                      (if rnnu.post1 = ? then "" else rnnu.post1) + " " +
                      (if rnnu.city1 = ? then "" else rnnu.city1) + " " + 
                      (if rnnu.street1 = ? then "" else rnnu.street1) + " " +
                      (if rnnu.housen1 = ? then "" else rnnu.housen1) + " " +
                      (if rnnu.apartn1 = ? then "" else rnnu.apartn1)
                     ).
       end.          
    end.

end.



on "return" of bt do:
    if not available trz then leave.
    find remtrz where remtrz.remtrz = trz.rmz no-lock no-error.
    if search (v-lbin + entry (1,remtrz.ref,"/")) =
               v-lbin  + entry (1,remtrz.ref,"/")
       then run menu-prt (v-lbin  + entry (1,remtrz.ref,"/")) .
    else do :
       if search (v-lbina + entry (3,remtrz.ref,"/") + ".Z") =
                 v-lbina + entry (3,remtrz.ref,"/") + ".Z"
          then run RMZVIEW (remtrz.ref).
/*
           unix value ("uttview " + v-lbina + entry (3,remtrz.ref,"/") + ".Z" +
                     " " + entry (1,remtrz.ref,"/") ) .
*/
    end.
end.

on "go" of bt do:
   if not yes-no ('', 'Вывести список в Excel?') then leave.
   output to rpt.csv.
   put unformatted "RMZ;СПФ;Фонд;Наименование отправителя;РНН отправителя" skip.
   for each b-trz:
       put unformatted b-trz.rmz ";" b-trz.rko ";" b-trz.sender ";" b-trz.name ";`" b-trz.rnn skip.
   end.
   output close.
   unix silent cptwin rpt.csv excel.
   unix silent rm rpt.csv.
end.


on "help" of bt do:
                                                                       
   if not available trz then leave.
   if not yes-no ('', 'Вывести письмо?') then leave.

   v-header = 'Отправитель денег: <b>' + REPLACE (trz.name, "ТР СЧ ", "") + ' </b><br>' +
              'РНН : <b> ' + trz.rnn + ' </b> <br>' +
              'Адрес: <b> ' + trz.addr + ' </b> <br>'.

   find first tsw where tsw.rmz = trz.rmz no-error.
   if not available tsw then v-footer = '&nbsp;'. 
   else do:
      v-footer = "<H4><b>Список отправителей, по которым произошел возврат:</b></H4>" +
              "<table width=""600"" border=""1"" cellpadding=""0"" cellspacing=""0"" style=""font-size:10px; border-collapse: collapse""><tr>" +
              '<td style=" background: #D0D0D0; ">N п/п</td>' +
              '<td style=" background: #D0D0D0; ">Фамилия</td>' +
              '<td style=" background: #D0D0D0; ">Имя</td>' +
              '<td style=" background: #D0D0D0; ">Отчество</td>' +
              '<td style=" background: #D0D0D0; ">РНН</td>' +
              '<td style=" background: #D0D0D0; ">СИК</td>' +
              '</tr>'.

      for each tsw where tsw.rmz = trz.rmz:
      v-footer = v-footer + '<tr>' + '<td>' + STRING (tsw.npp) + '</td>' +
                            '<td>' + CAPS (tsw.ln) + '</td>' +
                            '<td>' + CAPS (tsw.fn) + '</td>' +
                            '<td>' + CAPS (tsw.mn) + '</td>' +
                            '<td>' + tsw.rnn + '</td>' +
                            '<td>' + tsw.sik + '</td>' + '</tr>'.
      end.

      v-footer = v-footer + '</table>'.
   end.

   v-letter = v-letter + 1.
   v-letnum = "РР1-" + TRIM(STRING(v-letter, "zzzzzzzz9")) + "-" + trz.ref.
   
   run savelog ("pmpletter", "Формирование письма для " + trz.rmz + " / " + trz.name).

   run pmpletter (v-letnum, v-header, trz.remark, v-footer).

   create letters.
   assign letters.rwho = g-ofc
          letters.rdt = g-today
          letters.who = userid ("bank")
          letters.whn = today
          letters.bank = ourbnk
          letters.ref = trz.rmz
          letters.refdt = trz.rdt
          letters.docnum = v-letnum
          letters.type = "pmprmz"
          letters.info[2] = trz.name
          letters.addr[10] = trz.addr.

   run SET-SYSC-INT ("GCVPLC", v-letter).

   if trz.kol = "" then trz.kol = "1".
   else trz.kol = STRING(INTEGER(trz.kol) + 1).
   browse bt:refresh().

end.

open query qt for each trz.
enable all with frame ft.
wait-for window-close of current-window focus browse bt.

hide all.
pause 0.



/* ------------------ */
/*  ПРОСМОТР  ФАЙЛОВ  */ 
/* ------------------ */
procedure RMZVIEW.
define input parameter v-ref like remtrz.ref.

   unix silent value ("cp " + v-lbina + entry (3,v-ref,"/") + ".Z pensRKO.Z ").
   unix silent value ("uncompress -f pensRKO.Z > /dev/null"). 
   unix silent value ("tar xvf pensRKO " + entry (1,v-ref,"/") + " > /dev/null").
   unix silent value ("rm pensRKO").
   run menu-prt (entry (1,v-ref,"/")).
   unix silent value ("rm " + entry (1,v-ref,"/")).

end procedure.

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

      if st begins ":21:" then do:
         create tsw.
         tsw.rmz = remtrz.remtrz.

         tsw.npp = INTEGER (SUBSTR(st, 5)).
      end.   
/*
         do i = 1 to 7:
            import unformatted st.
*/   

            if st begins ':32B:' then tsw.sum = SUBSTR(st, 9).
            if st begins ':70:/OPV/' then tsw.sik = SUBSTR(st, 10).
            if st begins '//FM/' then tsw.ln = SUBSTR(st, 6).
            if st begins '//NM/' then tsw.fn = SUBSTR(st, 6).
            if st begins '//FT/' then tsw.mn = SUBSTR(st, 6).
            if st begins '//DT/' then tsw.bdate = DATE (SUBSTR(st, 12, 2) + "/" + SUBSTR(st, 10, 2) + "/" + SUBSTR(st, 6, 4)).
            if st begins '//RNN/' then tsw.rnn = SUBSTR(st, 7).

/*
         end.

 */
      if st begins "/ASSIGN/" then do:
         wasassign = TRUE.
         trz.remark = SUBSTR (st, 9).
      end. else if wasassign then do:
                   if SUBSTR (st, 1, 1) <> ":" and SUBSTR (st, 1, 2) <> "-}" then trz.remark = trz.remark + st.
                             else wasassign = FALSE.
                end.

   end.
   input close.

   unix silent rm pensTEMP.

end procedure.








