/* make-recall.p
 * MODULE
        Internet Office
 * DESCRIPTION
        Отсылка распоряжения на отзыв платежа.
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * BASES
        BANK COMM IB
 * AUTHOR
        13.04.2004 tsoy
 * CHANGES
*/

def input parameter doc_id  as int. 
def input parameter doc_type   as int.  /* 1 Платежное поручение 2 Заявка на конвертация */

def var KOD as char. /* КОд */
def var KBE as char. /* КОд */

def var v-adr as char. 
def var v-crc as char. 

def var v-summawrd as char. 
def var v-summ as deci. 

def var v-chief  as char init "НЕ ПРЕДУСМОТРЕНО".
def var v-mainbk as char init "НЕ ПРЕДУСМОТРЕНО".

find sysc where sysc.sysc = "IBREC" no-lock no-error.
if avail sysc then do:
    v-adr = sysc.chval.
end. else do:
    v-adr = "support@metrocombank.kz".
end.

unix silent value ("rm " + string(doc_id) + ".htm* 2> /dev/null").

output to value (string(doc_id) + ".html" ).

find ib.doc where ib.doc.id = doc_id no-lock no-error.
if not avail ib.doc  then do:
   output close.
   return.
end.

find cif where cif.cif = doc.cif no-lock no-error.

if not avail cif then do:
   output close.
   return.
end.

def var v-ras as char.

select substr(cif.geo,3,1) + sub-cod.ccode into KOD from cif,sub-cod
        where cif.cif     = doc.cif
        and sub-cod.sub   = "cln"
        and cif.cif       = sub-cod.acc
        and sub-cod.d-cod = "secek".

/* Расчет КБе */
KBE = substr (doc.codepar[2],9,1).
KBE = if KBE = 'R' then '1' else if KBE = 'N' then '2' else ''.
KBE = KBE + substr(doc.bbinfo[1],1,1).

if doc_type = 2 then do:

   if doc.bamt > 0 then  do:

        run Sm-vrd(doc.bamt, output v-summawrd).
        v-summ = doc.bamt.
        find aaa where aaa.aaa =  doc.benacc no-lock no-error.

        if avail aaa then do:
            find crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then 
                v-crc = crc.code.

        end.
   end.

   if doc.amt > 0 then  do:
        run Sm-vrd(doc.amt, output v-summawrd).
        v-summ = doc.amt.
        find aaa where aaa.aaa = doc.ordacc no-lock no-error.

        if avail aaa then do:

            find crc where crc.crc = aaa.crc no-lock no-error.
            if avail crc then 
                v-crc = crc.code.

        end.
   end.

end.
else do:
   run Sm-vrd(doc.amt, output v-summawrd).
       v-summ = doc.amt.    
    find aaa where aaa.aaa = doc.ordacc no-lock no-error.

    if avail aaa then do:

       find crc where crc.crc = aaa.crc no-lock no-error.
       if avail crc then 
           v-crc = crc.code.

    end.


end.

/* v-ras = string (next-value(recall)). */
v-ras = string (doc_id).

find first sub-cod where sub-cod.sub       = "cln"
                         and sub-cod.acc   = cif.cif
                         and sub-cod.d-cod = "clnchf" no-lock no-error.

if avail sub-cod and sub-cod.ccode ne "msc" then v-chief = trim(sub-cod.rcode).

find first sub-cod where sub-cod.sub = "cln"
                          and sub-cod.acc = cif.cif
                          and sub-cod.d-cod = "clnbk" no-lock no-error.
if avail sub-cod and sub-cod.ccode ne "msc" then v-mainbk = trim(sub-cod.rcode).

find aaa where aaa.aaa = doc.ordacc no-lock no-error.

if avail aaa then do:

   find crc where crc.crc = aaa.crc no-lock no-error.
   if avail crc then 
       v-crc = crc.code.

end.


put unformatted "<html><head><title>METROCOMBANK</title>" chr(10) chr (13)
     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" chr(10) chr (13)
     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" chr(10) chr(13).

put  unformatted 
   "<BR><BR><BR><BR><BR><BR><BR><BR>" skip
   "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
   "<TR><TD><BR>" skip
     "<TABLE width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
       "<TR valign=""top"">" skip
         "<TD width=""60%"" align=""left""></TD>" skip
         "<TD width=""40%"" align=""center""><FONT size=""3"">" skip
                  " <br> " cif.name skip
         "</FONT><BR><BR><BR><BR>"
         "</TD>" skip
       "</TR>"
     "</TABLE></TR>" skip.


put  unformatted 
  "<TABLE width=""90%"" border=""0"" cellspacing=""0"" cellpadding=""3"" align=""center"" >" skip
    "<TR><TD colspan=""6"">" skip 
    "<P align =""justify""><FONT size=""3"">"       skip.

       put  unformatted
       "<TR><TD colspan=""6"" align = ""center"">" skip
       "<B>Распоряжение N "  v-ras  " <BR> от " string(today, "99.99.9999") "<BR> об отзыве платежного документа </B> </TD></TR>" skip 
       "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
       "<TR><TD colspan=""6"">&nbsp;&nbsp;&nbsp; Предъявлено в банк OAO ""METROCOMBANK"" в соответствии со статьей " skip
       "                      35 Закона Республики Казахстан ""О Платежах и переводах денег"" просим вернуть без исполнения " skip
       if doc_type = 2 then " завку на ковертацию " else " платежное поручение "
       "                      N " string(doc.id) " от " string(valdate, "99.99.9999") " на сумму " string(v-summ) " " v-summawrd  " " v-crc skip 
       "                      <br> ИИК отправителя " doc.ordacc skip 
       if doc_type = 2 then " " else "                      <br> ИИК бенефициара " doc.benacc skip 
       "                      <br> КОд " KOD  skip 
       if doc_type = 2 then " " else "                      <br> КБе " KBE  skip .

if doc_type = 2 then
    put  unformatted  
    "                      <br> Назначение платежа " doc.letr[1]   skip. 
else   
    put  unformatted 
    "                      <br> Назначение платежа " doc.beninfo[1] + doc.beninfo[2] + doc.beninfo[3] + doc.beninfo[4] skip. 

put  unformatted 
       "                      <br> Иные сведения " doc.remtrz skip 
       "</TD></TR> " skip.

put  unformatted
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""2"" align=""left""> Руководитель " v-chief     skip 
    "<TD colspan=""4"" align=""right"">     </TD></TR>" skip
    "<TR><TD colspan=""2"" align=""left""> Главный бухгалтер "  v-mainbk skip 
    "<TD colspan=""4"" align=""right"">     </TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip
    "<TR><TD colspan=""6"">&nbsp;</TD></TR>" skip.

put  unformatted 
  "</TABLE> </TABLE>" skip.

put unformatted "</body></html>" skip.
output close.

unix silent value("rcode " + string(doc_id) + ".html "  + string(doc_id) + ".htm"  + " -kw > /dev/null"). 

run mail  ( v-adr, 
            "METROCOMBANK <support@metrocombank.kz>", 
            "Отзыв Платежа ", 
            "Отзыв Платежа См. вложение." , 
            "1", 
            "", 
            string(doc_id) + ".htm"
          ).

unix silent value ("rm " + string(doc_id) + ".htm* 2>  /dev/null").

