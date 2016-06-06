/* vcrptac.p
 * MODULE
        Валютный контроль
        Список контрактов
 * DESCRIPTION
        
 * RUN
        
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        18.02.2006 u00600
 * CHANGES
*/
{vc.i}
{global.i}
{comm-txb.i}

def var v-name as char no-undo.
def var v-nc as char no-undo.
def var v-dt as date no-undo.
def var v-nps as char no-undo.
def var v-sts as char no-undo.

def new shared temp-table rmztmp no-undo
    field rmztmp_name     as char    /* наименование клиента */
    field rmztmp_nc       as char    /* номер контракта */
    field rmztmp_dt       as date    /* дата контракта */
    field rmztmp_nps      as char    /* номер паспорта сделки */
    field rmztmp_sts      as char.   /* статус контракта */

def var vselect as char init "N" no-undo.  
def var v-st as char init "A" no-undo.
def var vvname as char no-undo. 

def var s-vcourbank as char no-undo.

form
skip(1)
   vselect label "Выберите клиента  N) Имя   A) Счет  C) CIF-код  " format "x" skip
   v-st label "Выберите статус контракта: A) Активный  C) Закрытый  V) Все  " format "x" skip
   with centered side-label row 5 title "Выберите данные и статус контракта" frame f-dt.

s-vcourbank = comm-txb().

update vselect v-st with frame f-dt.
vselect = caps(vselect).
v-st = caps(v-st).
displ v-st with frame f-dt.

/* A)счет */
if vselect eq "A"  OR VSELECT EQ "а"  or vselect eq "А"  or vselect eq "ф" or vselect eq "Ф"
then do:

  def var vaaa like aaa.aaa no-undo.
  message ' Введите счет: ' update vaaa.
  find first aaa where aaa.aaa eq vaaa no-lock no-error.
  if not avail aaa then do: message 'Счет' vaaa 'не найден!'. pause 10. return. end.

  else do:  

   /* Наименование клиента */
   for each cif where cif.cif = aaa.cif no-lock: 
    if avail cif then v-name = trim(trim(cif.name) + " " + trim(cif.prefix)). 
       else v-name = ''.

   /* номер, дата, статус контракта */
   for each vccontrs where vccontrs.cif = aaa.cif no-lock: 
    if v-st <> "V" and vccontrs.sts <> v-st then next. 
    if avail vccontrs then do: v-nc = vccontrs.ctnum. v-dt = vccontrs.ctdate. v-sts = vccontrs.sts. end.
       
  find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01'  no-lock no-error. /* номер паспорта сделки */
    if avail vcps then v-nps = vcps.dnnum.
       
 create  rmztmp.
    assign rmztmp.rmztmp_name  =  v-name.
           rmztmp.rmztmp_nc    =  v-nc.
           rmztmp.rmztmp_dt    =  v-dt.
           rmztmp.rmztmp_nps   =  v-nps.
           rmztmp.rmztmp_sts   =  v-sts.
    end.
    end.
  end.
end.

/* C)CIF-код */
if vselect eq "C"  OR VSELECT EQ "c"  or vselect eq "С"  or vselect eq "с"
then do:
    def var vcif like cif.cif no-undo.
    message ' Введите CIF-код: ' update vcif.
    find first cif where cif.cif eq vcif no-lock no-error.
    if not avail cif then do: message 'CIF-код ' vcif 'не найден!'. pause 10. return. end.
    else do:
    for each cif where cif.cif eq vcif no-lock:
 
      /* Наименование клиента */
     v-name = trim(trim(cif.name) + " " + trim(cif.prefix)). 
    
    /* номер, дата, статус контракта */
    for each vccontrs where vccontrs.cif = cif.cif no-lock:
    if v-st <> "V" and vccontrs.sts <> v-st then next.
    if avail vccontrs then do: v-nc = vccontrs.ctnum. v-dt = vccontrs.ctdate. v-sts = vccontrs.sts. end.
           
     find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error. /* номер паспорта сделки */
     if avail vcps then v-nps = vcps.dnnum.                 

 create  rmztmp.
    assign rmztmp.rmztmp_name  =  v-name.
           rmztmp.rmztmp_nc    =  v-nc.
           rmztmp.rmztmp_dt    =  v-dt.
           rmztmp.rmztmp_nps   =  v-nps.
           rmztmp.rmztmp_sts   =  v-sts.
    
    end.
    end.
end.
                        
end. 

/* N)Имя */
else if vselect eq "N" OR VSELECT EQ "н" OR VSELECT EQ "Н" or vselect eq "т" or vselect eq "Т"
then do:
   def var vname like cif.sname no-undo.
   message ' Введите имя: ' update vname.
   vvname = '*' + vname + '*' .

   find first cif where ( caps(trim(trim(cif.prefix) + ' ' + trim(cif.sname)))  MATCHES vvname or
   caps(trim(trim(cif.prefix) + ' ' + trim(cif.name))) matches vvname ) no-lock no-error.

   if not avail cif then do: message 'Клиент ' vname ' не найден!'. pause 10. return. end.
   else do:

   for each cif where ( caps(trim(trim(cif.prefix) + ' ' + trim(cif.sname)))  MATCHES vvname or
   caps(trim(trim(cif.prefix) + ' ' + trim(cif.name))) matches vvname ) no-lock:

    v-name = trim(trim(cif.name) + " " + trim(cif.prefix)).

    /* номер, дата, статус контракта */
    for each vccontrs where vccontrs.cif = cif.cif no-lock:
    if v-st <> "V" and vccontrs.sts <> v-st then next.
    if avail vccontrs then do: v-nc = vccontrs.ctnum. v-dt = vccontrs.ctdate. v-sts = vccontrs.sts. end.
           
  find first vcps where vcps.contract = vccontrs.contract and vcps.dntype = '01' no-lock no-error. /* номер паспорта сделки */
    if avail vcps then v-nps = vcps.dnnum.        

 create  rmztmp.
    assign rmztmp.rmztmp_name  =  v-name.
           rmztmp.rmztmp_nc    =  v-nc.
           rmztmp.rmztmp_dt    =  v-dt.
           rmztmp.rmztmp_nps   =  v-nps.
           rmztmp.rmztmp_sts   =  v-sts. 
   end.
  
end.
end.
end.

 def stream vcrpt.
 output stream vcrpt to vcrptac.html.              

{html-title.i 
 &stream = " stream vcrpt "
 &size-add = "xx-"
 &title = "Отчет по открытым и закрытым контрактам"
}

 put stream vcrpt unformatted
     "<B>" skip
     "<P align = ""center""><FONT size=""4"" face=""Times New Roman Cyr, Verdana, sans"">"
     "Отчет по открытым и закрытым контрактам клиентов</FONT></P>" skip.

 put stream vcrpt unformatted  
     "<B>" skip
     "<table border=""1"" cellpadding=""5"" cellspacing=""0"" style=""border-collapse: collapse""><FONT size = ""3"">" skip. 

 put stream vcrpt unformatted "<tr><B>"
                  "<td align=""center"">Наименование клиента</td>"
                  "<td align=""center"">Номер контракта</td>"
		  "<td align=""center"">Дата контракта</td>"
                  "<td align=""center"">Номер паспорта сделки</td>"
		  "<td align=""center"">Статус</td>"
                  "</FONT></B></tr>" skip. 

  for each rmztmp no-lock:

  put stream vcrpt  unformatted "<tr align=""center""><font size=""3"">"
        "<td>" rmztmp.rmztmp_name "</td>" skip
        "<td>" rmztmp.rmztmp_nc "</td>" skip
        "<td>" string(rmztmp.rmztmp_dt, "99/99/9999") "</td>" skip
        "<td>" rmztmp.rmztmp_nps "</td>" skip
        "<td>" rmztmp.rmztmp_sts "</td>" skip
        "</FONT></tr>" skip.
  end.

put stream vcrpt unformatted  "</FONT></table>".

find bankl where bankl.bank = s-vcourbank no-lock no-error.
if avail bankl then 
  put stream vcrpt unformatted "<B><tr align=""left""><font size=""3"">" bankl.name skip.

find sysc where sysc.sysc = "vc-dep" no-lock no-error.
if avail sysc then
  put stream vcrpt unformatted
    "<BR><BR>" + entry(1, sysc.chval) + "<BR>" + entry(2, sysc.chval) skip.

put stream vcrpt unformatted
  "</B></FONT></P>" skip. 

{html-end.i}

output stream vcrpt close.                         
unix silent cptwin vcrptac.html winword. 
