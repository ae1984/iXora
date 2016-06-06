/* r-trarp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

define input parameter bname   as char.
define input parameter dt1     as date.
define input parameter dt2     as date.
define input parameter g-comp  as char format 'x(40)'.
define input parameter g-ofc   as char.
define input parameter g-fname as char.
define input parameter g-mdes  as char format 'x(40)'.
define input parameter g-today as date.

def buffer b-jl for txb.jl.
def var v-cif as char.
def var v-sum as deci init 0 format 'zzzzzzzzzzzzzz9.99'.

def temp-table tmp 
    field arp   like txb.arp.arp
    field jdt   like txb.jl.jdt
    field names like txb.cif.name
    field des   like txb.arp.des
    field sum   like txb.jl.cam
    field ofc   like txb.ofc.name
index id  arp
index idx jdt names sum ofc.

for each txb.jl where txb.jl.jdt >= dt1 and txb.jl.jdt <= dt2 and txb.jl.dc = 'c' no-lock break by txb.jl.jh by txb.jl.ln by txb.jl.acc by txb.jl.dc:

    find txb.dealing_doc where txb.dealing_doc.jh = txb.jl.jh
                           and (txb.dealing_doc.doctype = 2 or txb.dealing_doc.doctype = 4) no-lock no-error.

    if not avail txb.dealing_doc then next.
    
    find txb.arp where txb.arp.arp = txb.jl.acc and txb.arp.gl = 287045 no-lock no-error.
    if not avail txb.arp then next.
    
    v-cif = ''.  

    for each b-jl where b-jl.jh = jl.jh and b-jl.jdt = jl.jdt and b-jl.dc = 'd' and string(b-jl.gl) begins '22' no-lock:
        if b-jl.acc = '' then next.
        find txb.aaa where txb.aaa.aaa = b-jl.acc no-lock no-error.
        if not avail txb.aaa then next.
        else do:
            v-cif = txb.aaa.cif.
            leave.
        end.
    end.
    
    find txb.cif where txb.cif.cif = v-cif no-lock no-error.
    if not avail txb.cif then next.
    
    find txb.ofc where txb.ofc.ofc = txb.jl.who no-lock no-error.
    
    create tmp.
    assign tmp.arp   = txb.arp.arp 
           tmp.jdt   = txb.jl.jdt
           tmp.names = txb.cif.name 
           tmp.des   = txb.arp.des
           tmp.sum   = txb.jl.cam
           tmp.ofc   = txb.ofc.name.
   
end.

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.xls.

{html-title.i 
 &stream = " stream vcrpt "
 &title = "Остатки на транзитных счетах"
 &size-add = "xx-"
}

put stream vcrpt unformatted 
   "<P align = ""center""><FONT size=""4""><B>" + bname + "</B><BR>"
   "<B>Остатки на транзитных счетах<BR></FONT>" + 
   "<FONT class=""ttext"" size=""2"">за период с " + string(dt1, "99/99/9999") + 
       " по " + string(dt2, "99/99/9999") + "</B></FONT></P>" skip

"<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
put stream vcrpt unformatted 
   "<TR align=""center"" bgcolor=""#808080"">" skip
     "<TD><FONT size=""2""><B>Дата</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Содержание</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Сумма</B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>Выполнил</B></FONT></TD>" skip
   "</TR>" skip.

for each tmp break by tmp.arp by tmp.jdt by tmp.names by tmp.sum by tmp.ofc:
if first-of(tmp.arp) then do:  
v-sum = 0.
put stream vcrpt unformatted 
   "<TR align=""center"" bgcolor=""#C0C0C0"">" skip
     "<TD colspan=""2""><FONT size=""2""><B> '" tmp.arp "</B></FONT></TD>" skip
     "<TD colspan=""2""><FONT size=""2""><B>" tmp.des "</B></FONT></TD>" skip
   "</TR>" skip.
end.   
   
put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD><FONT size=""2"">" string(tmp.jdt,'99.99.9999') "</FONT></TD>" skip
     "<TD><FONT size=""2"">" tmp.names "</FONT></TD>" skip
     "<TD><FONT size=""2"">" string(tmp.sum, 'zzzzzzzzzzzzzz9.99') "</FONT></TD>" skip
     "<TD><FONT size=""2"">" tmp.ofc "</FONT></TD>" skip
   "</TR>" skip.
   
v-sum = v-sum + tmp.sum.   

if last-of(tmp.arp) then   
put stream vcrpt unformatted 
   "<TR align=""center"">" skip
     "<TD colspan=""2""><FONT size=""2""><B> ИТОГО </B></FONT></TD>" skip
     "<TD><FONT size=""2""><B>" v-sum "</B></FONT></TD>" skip
     "<TD></TD>" skip
   "</TR>" skip.
   

end.

put stream vcrpt unformatted  
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

unix silent value("cptwin vcreestr.xls excel").

pause 0.