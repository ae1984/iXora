/* 
*/

{vc.i}

{global.i}

def input parameter p-filename as char.
def input parameter p-printbank as logical.
def input parameter p-bankname as char.
def input parameter p-printdep as logical.
def input parameter p-depname as char.
def input parameter p-printall as logical.

def shared temp-table t-cif 
  field jh as char
  field creditor as char
  field nss as char
  field name as char
  field regdt as date
  field kodbank as char
  field kodgbank as char
  field rnn as char format "x(14)"
  field ur_phis as char format "x(1)"
  field vid_ob as char 
  field datevyd as date
  field datekon as date
  field sum_ob as decimal 
  field val_ob as char 
  field plat_vyd as decimal 
  field vid_obes as char 
  field st_obes as decimal 
  field num_obyz as char 
  field naim_ban as char 
  field naim_ben as char 
  field adr_ben as char    
  field ost_ob as decimal    .

def shared temp-table t-cif2 
  field jh as char
  field nss as char
  field name as char
  field regdt as date
  field rnn as char format "x(14)"
  field sum_ob as decimal. 

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def var v-name as char.
def var v-monthname as char init 
   "январь,февраль,март,апрель,май,июнь,июль,август,сентябрь,октябрь,ноябрь,декабрь".

def var zbal as char init '6555'.

def stream vcrpt.
def shared var prz as integer.

output stream vcrpt to value(p-filename).

find first cmp no-lock no-error.


{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "xx-"}


if prz = 0 then 
  put stream vcrpt unformatted "<b> Список открытых гарантий за " + entry(v-month, v-monthname) + " " +
        string(v-god, "9999") + " года"  ".</b>"  skip.
else 
  put stream vcrpt unformatted " Список открытых кредитов за " + entry(v-month, v-monthname) + " " +
        string(v-god, "9999") + " года"  "."  skip.

/*открытые гарантии*/  
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip 
     "<TD><FONT size=""1""><B>Status</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>N TRX</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>REGDT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>KODBANK</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>KODGBANK</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>RNN</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>NAME</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>UR_PHIS</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>VID_OB</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>sum_OB</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>val_OB</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>nss</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>CREDITOR</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>zbal</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>datevyd</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>datekon</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>vid_obes</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>st_obes</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>plat_vyd</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>naim_ban</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>naim_ben</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>adr_ben</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>num_obyz</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>ost_ob</B></FONT></TD>" skip
     "</TR>" skip.
  
for each t-cif no-lock break by t-cif.regdt  :
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip .

  put stream vcrpt unformatted
     "<TD><FONT size=""1""><B>&nbsp; </B></FONT></TD>" skip
      "<TD>" + string(t-cif.jh) + "</TD>" skip
     "<TD>" + string(t-cif.regdt,'99/99/9999') + "</TD>" skip
      "<TD>" + t-cif.kodbank + "</TD>" skip
      "<TD>" + t-cif.kodgbank + "</TD>" skip
      "<TD>" + (t-cif.rnn) + "</TD>" skip
      "<TD>" + (t-cif.name) + "</TD>" skip
      "<TD>" + (t-cif.ur_phis) + "</TD>" skip
      "<TD>" + string(t-cif.vid_ob,'99') + "</TD>" skip
      "<TD>" + replace(string(t-cif.sum_ob,'zzzzzzzzzzzzz9.99'),".",",") + "</TD>" skip
      "<TD>" + string(t-cif.val_ob,'999') + "</TD>" skip
      "<TD>" + t-cif.nss + "</TD>" skip
      "<TD>" + t-cif.creditor + "</TD>" skip
      "<TD>" + zbal  + "</TD>" skip
      "<TD>"  if t-cif.datevyd = ? then "&nbsp;" else string(t-cif.datevyd,'99/99/9999')  "</TD>" skip
      "<TD>"  if t-cif.datekon = ? then "&nbsp;" else string(t-cif.datekon,'99/99/9999')  "</TD>" skip
      "<TD>" + t-cif.vid_obes + "</TD>" skip
      "<TD>" + replace(string(t-cif.st_obes,'zzzzzzzzzz9.99'),".",",") + "</TD>" skip
      "<TD>" + string(t-cif.plat_vyd) + "</TD>" skip
      "<TD>" + t-cif.naim_ban + "</TD>" skip
      "<TD>" + t-cif.naim_ben + "</TD>" skip
      "<TD>" + t-cif.adr_ben + "</TD>" skip
      "<TD>" + t-cif.num_obyz + "</TD>" skip
      "<TD>" + replace(string(t-cif.ost_ob,'zzzzzzzzzzzzz9.99'),".",",") + "</TD>" skip.

      "<TD align=""right"">".


  put stream vcrpt unformatted
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

/*возвращенные гарантии*/
if prz = 0 then 
  put stream vcrpt unformatted "<b> Список возвращенных гарантий за " + entry(v-month, v-monthname) + " " +
        string(v-god, "9999") + " года"  ".</b>"  skip.
put stream vcrpt unformatted
   "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
   "<TR align=""center"">" skip 
     "<TD><FONT size=""1""><B>Status</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>N TRX</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>REGDT</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>RNN</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>NAME</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>sum_OB</B></FONT></TD>" skip
     "<TD><FONT size=""1""><B>nss</B></FONT></TD>" skip
     "</TR>" skip.
  
for each t-cif2 no-lock break by t-cif2.regdt  :
  put stream vcrpt unformatted
    "<TR valign=""top"">" skip .

  put stream vcrpt unformatted
     "<TD><FONT size=""1""><B>&nbsp; </B></FONT></TD>" skip
      "<TD>" + string(t-cif2.jh) + "</TD>" skip
     "<TD>" + string(t-cif2.regdt,'99/99/9999') + "</TD>" skip
      "<TD>" + (t-cif2.rnn) + "</TD>" skip
      "<TD>" + (t-cif2.name) + "</TD>" skip
      "<TD>" + replace(string(t-cif2.sum_ob,'zzzzzzzzzzzzz9.99'),".",",") + "</TD>" skip
      "<TD>" + t-cif2.nss + "</TD>" skip
      "<TD align=""right"">".


  put stream vcrpt unformatted
    "</TR>" skip.
end.

put stream vcrpt unformatted
  "</TABLE>" skip.

  find ofc where ofc.ofc = g-ofc no-lock no-error.


{html-end.i " stream vcrpt "}
output stream vcrpt close.
unix silent value("cptwin " + p-filename + " excel").

pause 0.
